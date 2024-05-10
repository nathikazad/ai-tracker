import e from "express";
import { getHasura } from "./config"
import { $, events_bool_exp, order_by, timestamp_comparison_exp } from "./generated/graphql-zeus";
import { addLocation, updateMovements } from "./helper/location2";
import { addHours, toDate, toPST } from "./helper/time";
import { ASEvent, Category, breakdown, createEmbeddings, extractCategories, extractEvents } from "./resources/logic/eventLogic";
import { getUserTimeZone } from "./resources/user";



async function main() {
    // Example usage:
    // await createEmbeddings();
    let userId = 1
    await updateMovements(userId)
    // let interactions = (await getInteractions(userId)).slice(0, 1)
    // console.log(`Interactions: ${interactions.length}`)
    // let timezone = await getUserTimeZone(userId)
    // let idsToCheck =  [1639, 1640, 1651]
    // for (let interaction of interactions) {
    //     let i = {
    //         statement: interaction.content,
    //         recordedAt: interaction.timestamp, 
    //         timezone,
    //     }
    //     console.log(`Interaction(${interaction.id}) at  ${toPST(interaction.timestamp)}: \n ${JSON.stringify(i, null, 4)}`)
    //     let event = await extractEvents(i)
    //     console.log(`Event: \n ${JSON.stringify(event, null, 4)}`)
    //     console.log(`\t start_time: ${toPST(event.startTime)} \n\t end_time: ${toPST(event.endTime)}`);
    //     for (let category of event.categories) {
    //         if(category == Category.Sleeping) {
    //             let closestSleepingEvent = await getClosestSleepEvent(userId, event.startTime, event.endTime)
    //             if(closestSleepingEvent != null) {
    //                 console.log(`Closest Sleeping Event: \n ${closestSleepingEvent.id} ${toPST(closestSleepingEvent.start_time)}  ${toPST(closestSleepingEvent.end_time)}`)
    //                 event.metadata.locks = closestSleepingEvent?.metadata?.locks || {}
    //                 if(event.startTime != null) {
    //                     event.metadata.locks.start_time = true
    //                 }
    //                 if(event.endTime != null) {
    //                     event.metadata.locks.end_time = true
    //                 }
    //                 await updateEvent(closestSleepingEvent.id, event.startTime ?? closestSleepingEvent.start_time, event.endTime ?? closestSleepingEvent.end_time, event.metadata, interaction.id)
    //                 continue
    //             } else {
    //                 console.log(`Creating new sleep event`)
    //                 await createEvent(event, category, userId, interaction.id)
                
    //             }
    //         }
    //         else if([Category.Learning, Category.Shopping, Category.Cooking].includes(category) 
    //             && event.startTime == null && event.endTime != null) {
    //             let lastEvent = await getLastEvent(userId, category, event.endTime)
    //             if(lastEvent != null && lastEvent.end_time == null) {
    //                 console.log(`Last Event: \n ${JSON.stringify(lastEvent, null, 4)}`)
    //                 console.log(`Updating end time of last event`)
    //                 await updateEvent(lastEvent.id, lastEvent.start_time, event.endTime, {
    //                     ...lastEvent.metadata,
    //                     ...event.metadata
    //                 }, interaction.id)
    //             } else {
    //                 console.log(`Creating new event 1`)
    //                 await createEvent(event, category, userId, interaction.id)
    //             }
    //         } else {
    //             console.log(`Creating new event 2`)
    //             await createEvent(event, category, userId, interaction.id)
    //         }
    //     }
    //     console.log('-------------------')  
    //     console.log('-------------------')  
    //     console.log('-------------------')  

    // }

    async function updateEvent(id: number, startTime:string | undefined, endTime: string | undefined, metadata: any | undefined, interactionId: number) {
        console.log(`Updating event: ${id} ${toPST(startTime)} ${toPST(endTime)} ${JSON.stringify(metadata)}`)
        let resp = await getHasura().mutation({
            update_events_by_pk: [
                {
                    pk_columns: {
                        id
                    },
                    _set: {
                        start_time: startTime,
                        end_time: endTime,
                        metadata: $`metadata`,
                    },
                    _append: {
                        logs: $`logs`
                    }
                },
                {
                    id: true
                }
            ]
        }, {
            metadata: metadata,
            logs: {
                [toPST(new Date().toISOString())]: interactionId
            }
        })
        markInteractionAsTranscoded(interactionId)
    }

    async function createEvent(event: ASEvent, category: Category, userId: number, interactionId: number) {
        console.log(`Creating event: ${category}`)
        let resp = await getHasura().mutation({
            insert_events_one: [
                {
                    object: {
                        user_id: userId,
                        event_type: category,
                        start_time: event.startTime,
                        end_time: event.endTime,
                        metadata: $`metatadata`,
                        interaction_id: interactionId,
                        logs: $`logs`
                    }
                       
                },
                {
                    id: true
                }
            ]
        }, {
            metatadata: event.metadata,
            logs: {
                [toPST(new Date().toISOString())]: interactionId
            }
        })
        markInteractionAsTranscoded(interactionId)
        console.log(`Event created: ${resp.insert_events_one?.id}`)
    }

    async function markInteractionAsTranscoded(interactionId: number) {
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

    async function getClosestSleepEvent(user_id: number, startTime: string| null, endTime: string | null) {
        if(startTime == null && endTime == null) {
            return null
        }
        let conditions: events_bool_exp = {
            user_id: {
                _eq: user_id
            },
            event_type: {
                _eq: Category.Sleeping
            }
        }
        let startConditions: timestamp_comparison_exp = {}
        let endConditions: timestamp_comparison_exp = {}
        if(startTime) {
            startConditions._gt = addHours(toDate(startTime), -2.5).toISOString()
            startConditions._lt = addHours(toDate(startTime), 2).toISOString()
        }
        if(endTime) {
            endConditions._gt = addHours(toDate(endTime), -2.5).toISOString()
            endConditions._lt = addHours(toDate(endTime), 2.5).toISOString()
        }

        if(startTime && endTime) {
            conditions._or = [{
                start_time: startConditions
            }, {
                end_time: endConditions
            }]
        } else if(startTime) {
            conditions.start_time = startConditions
        } else if(endTime) {
            conditions.end_time = endConditions
        }
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


    async function getLastEvent(user_id: number, category:Category, endTime: string) : Promise<any | null> {
        let endTimeAsDate = toDate(endTime)
        let lastProbableStartTime = addHours(endTimeAsDate, -12)
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
                            _gte: lastProbableStartTime.toISOString()
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


    async function getInteractions(user_id: number, transcode_version: number = 0) {
        let resp = await getHasura().query({
            interactions: [
                {
                    order_by: [{
                        timestamp: order_by.asc
                    }],
                    where: {
                        user_id: {
                            _eq: user_id
                        },
                        timestamp: {
                            _gte: "2024-05-08",
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
}
main()

