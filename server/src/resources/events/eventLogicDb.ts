import { get } from "http";
import { getHasura } from "../../config"
import { addHours, toDate, toPST } from "../../helper/time";
import { ASEvent, Category, Interaction } from "../logic/eventLogic";
import { $, events_bool_exp, order_by, timestamp_comparison_exp } from "./../../generated/graphql-zeus";
import { createEmbedding } from "../../third/openai";


export async function updateEvent(id: number, startTime:string | undefined, endTime: string | undefined, metadata: any | undefined, interaction: Interaction) {
    console.log(`Updating event: ${id} ${toPST(startTime)} ${toPST(endTime)} ${JSON.stringify(metadata)}`)
    metadata = metadata || {}
    metadata.notes = metadata.notes || {}
    metadata.notes[interaction.recordedAt] = interaction.statement
    let resp = await getHasura().mutation({
        update_events_by_pk: [
            {
                pk_columns: {
                    id
                },
                _set: {
                    start_time: startTime,
                    end_time: endTime,
                    metadata: $`metadata`
                },
                _append: {
                    logs: $`logs`
                },
            },
            {
                id: true
            }
        ]
    }, {
        metadata: metadata,
        logs: {
            [interaction.recordedAt]: interaction.id
        }
    })
    markInteractionAsTranscoded(interaction.id)
}

export async function getEvent(userId: number, eventId: number) : Promise<{eventType: Category, metadata: any} | undefined> {
    let event = await getHasura().query({
        events: [
            {
                where: {
                    id: {
                        _eq: eventId
                    },
                    user_id: {
                        _eq: userId
                    }
                }
            },
            {
                event_type: true,
                metadata: [{}, true]
            }
        ]
    })
    if(event.events.length == 0) {
        return undefined
    }
    return {
        eventType: event.events[0].event_type as Category,
        metadata: event.events[0].metadata
    }
    
}

export async function createEvent(event: ASEvent, category: Category, interaction: Interaction, parentEventId: number | undefined = undefined) {
    console.log(`Creating event: ${category} ${interaction.recordedAt}`)
    let resp = await getHasura().mutation({
        insert_events_one: [
            {
                object: {
                    user_id: interaction.userId,
                    event_type: category,
                    start_time: event.startTime,
                    end_time: event.endTime,
                    metadata: $`metadata`,
                    interaction_id: interaction.id,
                    logs: $`logs`,
                    parent_id: parentEventId
                }
                   
            },
            {
                id: true
            }
        ]
    }, {
        metadata: {
            [category]: event.metadata[category],
            notes: {
                [interaction.recordedAt]: interaction.statement
            }
        },
        logs: {
            [toPST(new Date().toISOString())]: interaction.id
        }
    })
    markInteractionAsTranscoded(interaction.id)
    console.log(`Event created: ${resp.insert_events_one?.id}`)
}

export async function markInteractionAsTranscoded(interactionId: number) {
    let resp = await getHasura().mutation({
        update_interactions_by_pk: [
            {
                pk_columns: {
                    id: interactionId
                },
                _set: {
                    transcode_version: 1
                }
            },
            {
                id: true
            }
        ]
    })
}

export async function getClosestSleepEvent(user_id: number, startTime: string| null, endTime: string | null) {
    if(startTime == null && endTime == null) {
        return null
    }
    let conditions: events_bool_exp = {
        user_id: {
            _eq: user_id
        },
        event_type: {
            _eq: Category.Sleeping
        },

    }
    let startConditions: timestamp_comparison_exp = {}
    let endConditions: timestamp_comparison_exp = {}


    if(!startTime && endTime) {
        // to catch case where start time is there in old event but no end time like "I just woke up"
        conditions.start_time = {
            _gt: addHours(toDate(endTime), -12).toISOString(),
            _lt: endTime
        }
        let endConditions1: events_bool_exp = {
            end_time: {
                _is_null: true
            }
        }

        // to catch case where start time is there in old event and end time is close to the new event like "actually I am just waking up"
        let endConditions2: events_bool_exp = {
            end_time: {
                _gt: addHours(toDate(endTime), -2.5).toISOString(),
                _lt: addHours(toDate(endTime), 2.5).toISOString()
            }
        }
        conditions._or = [endConditions1, endConditions2]
    } else if(startTime && !endTime) {
        // when updating sleep time, like "actually I am just going to sleep"
        conditions.end_time = {
            _is_null: true
        }
        conditions.start_time = {
            _gt: addHours(toDate(startTime), -5).toISOString(),
            _lt: startTime
        }
    } else if(startTime && endTime) {
        conditions._or = [{
            start_time: {
                _gt: addHours(toDate(startTime), -2.5).toISOString(),
                _lt: addHours(toDate(startTime), 2).toISOString()
            }
        }, {
            end_time: {
                _gt: addHours(toDate(endTime), -2.5).toISOString(),
                _lt: addHours(toDate(endTime), 2.5).toISOString()
            }
        }]
    }
    console.log(`Getting closest sleeping event: ${JSON.stringify(conditions)}`)
    let closestSleepingEvent = await getHasura().query({
        events: [
            {
                limit: 1,
                order_by: [{
                    start_time: order_by.desc
                }],
                where: conditions
            },
            {
                id: true,
                start_time: true,
                end_time: true,
                metadata: [{}, true]
            }
        ]
    })
    return closestSleepingEvent.events[0]
}


export async function getLastEvent(user_id: number, category:Category, endTime: string) : Promise<any | null> {
    let endTimeAsDate = toDate(endTime)
    let lastProbableStartTime = addHours(endTimeAsDate, -12)
    if(category != Category.Sleeping) {
        lastProbableStartTime = addHours(endTimeAsDate, -4)
    }
    let lastEvent = await getHasura().query({
        events: [
            {
                limit: 1,
                order_by: [{
                    start_time: order_by.desc
                }],
                where: {
                    user_id: {
                        _eq: user_id
                    },
                    event_type: {
                        _eq: category
                    },
                    start_time: {
                        _gte: lastProbableStartTime.toISOString(),
                        _lt: endTime
                    }
                }
            },
            {
                id: true,
                start_time: true,
                end_time: true,
                metadata: [{}, true]
            }
        ]
    })
    if(lastEvent.events.length == 0) {
        return null
    }
    return lastEvent.events[0]

}


export async function getInteractions(userId: number, date: string, transcode_version: number = 0) {
    let resp = await getHasura().query({
        interactions: [
            {
                order_by: [{
                    timestamp: order_by.asc
                }],
                where: {
                    user_id: {
                        _eq: userId
                    },
                    timestamp: {
                        _gte: date,
                    },
                    transcode_version: {
                        _lte: transcode_version
                    }
                }
            },
            {
                id: true,
                content: true,
                timestamp: true
            }
        ]
    })

    return resp.interactions
}


export async function writeDescriptionToDb(category: Category, description: string) {
    console.log(`Updating description for ${category} to ${description}`)
    let resp = await getHasura().mutation({
        update_event_types_by_pk: [
            {
                pk_columns: {
                    name: category
                },
                _set: {
                    metadata: $`metadata`
                }
            },
            {
                name: true
            }
        ]
    }, {
        metadata: {
            description
        }
    })
    if (resp.update_event_types_by_pk == null) {
        console.log(`Category ${category} does not exist. Creating it. `)
        await getHasura().mutation({
            insert_event_types_one: [{
                object: {
                    name: category,
                    metadata: $`metadata`,
                    parent: 'root'
                }
            }, {
                name: true
            }]
        }, {
            metadata: {
                description
            }

        })
    }
    await createCategoryEmbedding(description, category);
    console.log(`Updated description for ${category}`)
}

export async function createEmbeddings() {
    let categories = await getHasura().query({
        event_types: [{}, {
            name: true,
            metadata: [{}, true]
        }]
    })

    for (let category of Object.values(Category)) {
        let description = categories.event_types.find((et: any) => et.name == category)?.metadata?.description;
        if(description) {
            await createCategoryEmbedding(description, category);
        }
    }
}

async function createCategoryEmbedding(description: any, category: Category) {
    console.log(`Creating embedding for ${category}`)
    let embedding = await createEmbedding(description);
    getHasura().mutation({
        update_event_types_by_pk: [{
            pk_columns: {
                name: category
            },
            _set: {
                embedding: $`embedding`
            }
        }, {
            name: true
        }]
    },{
        embedding: JSON.stringify(embedding)
    });
    console.log(`Created embedding for ${category}`)
}

export async function getCategories(): Promise<{categoryEmbeddings: { [key in Category]?: Number[] }, categoryDescriptions: { [key in Category]?: string | null }}> {
    // get from database
    let eventTypes = await getHasura().query({
        event_types: [{}, {
            embedding: true,
            name: true,
            metadata: [{}, true]
        }]
    })
    let categoryEmbeddings: { [key in Category]?: Number[] } = {};
    let categoryDescriptions: { [key in Category]?: string | null } = {};
    for (let eventType of eventTypes.event_types) {
        if(eventType.embedding == null) {
            continue
        }
        let category: Category = eventType.name as Category;
        categoryEmbeddings[category] = JSON.parse(eventType.embedding);
        categoryDescriptions[category] = eventType.metadata?.description;
    }
    return {categoryEmbeddings, categoryDescriptions};
}