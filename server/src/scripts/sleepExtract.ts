
import { $, order_by, timestamp_comparison_exp } from "../generated/graphql-zeus"
import fs from 'fs'
import { createEmbedding } from '../third/openai';
import { getHasura } from '../config';
import { addHoursToTimestamp, getCostTimeInSeconds, secondsToHHMM, toPST } from "../helper/time";

interface Event {
    id: number;
    timestamp: string;
    content?: string;
}

async function main() {
    // getEvents(1, "trader joes", 'office.json', 0.2)
    // getEvents(1, "going to sleep", 'sleep.json')
    // findMatches()
    // writeToDatabase(1)
    readWatchData(1)
    // readWatchData2(1)
}
main()


function findMatches() {
    const wakeData = JSON.parse(fs.readFileSync('wake.json', 'utf-8'));
    const sleepData = JSON.parse(fs.readFileSync('sleep.json', 'utf-8'));
    const matchedEvents = matchEvents(sleepData.match_interactions, wakeData.match_interactions);
    fs.writeFileSync('matchedEvents.json', JSON.stringify(matchedEvents, null, 2), 'utf-8');
}

function matchEvents(sleepEvents: Event[], wakeEvents: Event[]): { wake?: Event | null, sleep?: Event | null }[] {
    const matchedData: { wake?: Event | null, sleep?: Event | null }[] = [];
    const sleepEventsUsed: Set<number> = new Set();

    wakeEvents.forEach(wake => {
        const wakeTime = new Date(wake.timestamp);
        const matchedSleep = sleepEvents.find(sleep => {
            const sleepTime = new Date(sleep.timestamp);
            // Ensure the sleep time is before the wake time and within 14 hours prior
            return sleepTime.getTime() < wakeTime.getTime() &&
                (wakeTime.getTime() - sleepTime.getTime()) <= 50400000 &&
                !sleepEventsUsed.has(sleep.id);
        });

        if (matchedSleep) {
            sleepEventsUsed.add(matchedSleep.id);
            matchedData.push({ wake, sleep: matchedSleep });
        } 
        // else {
        //     // No appropriate sleep event found; push wake event with no matching sleep
        //     matchedData.push({ wake, sleep: null });
        // }
    });

    // Add sleep events that were not matched to any wake event
    sleepEvents.forEach(sleep => {
        if (!sleepEventsUsed.has(sleep.id)) {
            matchedData.push({ wake: null, sleep });
        }
    });

    return matchedData;
}

async function getEvents(userId: number, phrase: string, filename: string, threshold: number) {
    let embedding = await createEmbedding(phrase)
    // get interactions for user id 1 only after 2024-04-24T13:13:48.215+00:00
    let matches = await getHasura().query({
        match_interactions: [{
            args: {
                target_user_id: userId,
                query_embedding: $`embedding`,
                match_threshold: threshold,
            },
            order_by: [{
                timestamp: order_by.desc
            }]
        }, {
            content: true,
            timestamp: true,
            id: true
        }]
    }, {
        "embedding": JSON.stringify(embedding)
    });
    matches.match_interactions.forEach((match) => {
        console.log(match.content)
    })
    fs.writeFileSync("data/"+filename, JSON.stringify(matches));
}



async function readWatchData(userId: number) {
    console.log('Reading watch data');
    
    const matches: { sleep?: Event, wake?: Event }[] = JSON.parse(fs.readFileSync('data/matchedEvents.json', 'utf-8'));
    // const objectsToInsert = [];  // Array to hold all objects for a single mutation

    for (const match of matches) {

        let start_time
        let end_time

        if (match.sleep) {
            start_time = match.sleep.timestamp;
        }
        if (match.wake) {
            end_time = match.wake.timestamp;
        }

        let startConditions: timestamp_comparison_exp = {}
        if (start_time) {
            startConditions = {
                _gt: addHoursToTimestamp(start_time!, -4),
                _lt: addHoursToTimestamp(start_time!, 4)
            }
        }
        // let endConditions: timestamp_comparison_exp = {}
        // if (start_time) {
        //     endConditions = {
        //         _gt: addHoursToTimestamp(end_time!, -4),
        //         _lt: addHoursToTimestamp(end_time!, 4)
        //     }
        // }
       
        
        const client = getHasura();
        let resp = await client.query({
            events: [{
                where: {
                    user_id: {
                        _eq: userId
                    },
                    _or: [
                        { start_time: startConditions },
                        // { end_time: endConditions },
                    ],
                    event_type: {
                        _eq: 'sleep'
                    }
                }
            }, {
                id: true,
                start_time: true,
                end_time: true
            }]
        })
        if (resp.events.length > 0) {
            console.log(`Event already exists for ID ${resp.events[0].id}`);
            let actual_start_time = resp.events[0].start_time
            let actual_end_time = resp.events[0].end_time
            let str = ``
            if (actual_start_time && start_time) {
                str = `\tsleep time: \n\t\tme:${toPST(start_time)}\n\t\twatch:${toPST(actual_start_time)}`
                // str += `\n\tstart diff: ${differnceInMinutes(actual_start_time, start_time)}`
            }

            if (actual_end_time && end_time) {
                str += `\n\twake time: \n\t\tme:${toPST(end_time)}\n\t\twatch:${toPST(actual_end_time)}`
            //     str += `\n\tend diff: ${differnceInMinutes(actual_end_time, end_time)}\n`
            }
            console.log(str)
            await getHasura().mutation({
                update_events_by_pk: [{
                    pk_columns: {
                        id: resp.events[0].id
                    },
                    _set: {
                        end_time: end_time,
                        start_time: start_time
                    }
                }, {
                    id: true
                }]
            })
            // continue;
        } else {
            console.log(`Event does not exist`)
        }
    }
}


export async function writeToDatabase(userId:number) {
    const matches: { sleep?: Event, wake?: Event }[] = JSON.parse(fs.readFileSync('matchedEvents.json', 'utf-8'));
    // const objectsToInsert = [];  // Array to hold all objects for a single mutation

    for (const match of matches) {
        let start_time
        let end_time  
        let cost_time = 0;

        if (match.sleep) {
            start_time = match.sleep.timestamp;
        }

        if (match.wake) {
            end_time = match.wake.timestamp;
        }

        if (match.sleep && match.wake) {
            cost_time = getCostTimeInSeconds(start_time!, end_time!);
        } else {
            continue
        }
        let metadata = {}
        if(cost_time != 0) {
            metadata = {
                time_taken: secondsToHHMM(cost_time)
            };
        }
        try {
            const client = getHasura();
            let resp = await client.mutation({
                insert_events_one: [{

                    object: {
                        user_id: userId,
                        event_type: 'sleep',
                        start_time: start_time,
                        end_time: end_time,
                        cost_time: cost_time,
                        metadata: $`metadata`
                    }
                }, {
                    id: true

                }]
            }, {
                "metadata": metadata
            });
            console.log(`Inserted event for ID ${resp.insert_events_one?.id} with cost_time: ${cost_time} seconds`);
        } catch (error) {
            console.error('Error inserting event', error);
        }

        // objectsToInsert.push({
        //     user_id: userId,
        //     event_type: 'sleep',
        //     start_time: start_time,
        //     end_time: end_time,
        //     cost_time: cost_time,
        //     metadata: metadata
        // });
    }    
}
