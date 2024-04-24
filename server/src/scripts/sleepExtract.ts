// import { getHasura } from "./config"
// import { createEmbedding } from "./third/openai"
import { $, order_by } from "../generated/graphql-zeus"
import fs from 'fs'
import { createEmbedding } from '../third/openai';
import { getHasura } from '../config';
import { secondsToHHMM } from "../helper/location";
// import { getHasura } from './config';
// import { secondsToMMSS } from './helper/location';

interface Event {
    id: number;
    timestamp: string;
    content?: string;
}

async function main() {
    // getEvents(1, "wake up", 'wake.json')
    // getEvents(1, "going to sleep", 'sleep.json')
    // findMatches()
    writeToDatabase(1)
}
main()


export function getCostTimeInSeconds(start: string, end: string): number {
    const startTime = new Date(start);
    const endTime = new Date(end);
    return Math.floor((endTime.getTime() - startTime.getTime()) / 1000);
}

export function findMatches() {
    const wakeData = JSON.parse(fs.readFileSync('wake.json', 'utf-8'));
    const sleepData = JSON.parse(fs.readFileSync('sleep.json', 'utf-8'));
    const matchedEvents = matchEvents(sleepData.match_interactions, wakeData.match_interactions);
    fs.writeFileSync('matchedEvents.json', JSON.stringify(matchedEvents, null, 2), 'utf-8');
}

function matchEvents(sleepEvents: Event[], wakeEvents: Event[]): { wake?: Event | null, sleep?: Event | null}[] {
    const matchedData: { wake?: Event | null, sleep?: Event | null}[] = [];
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
        } else {
            // No appropriate sleep event found; push wake event with no matching sleep
            matchedData.push({ wake, sleep: null });
        }
    });

    // Add sleep events that were not matched to any wake event
    sleepEvents.forEach(sleep => {
        if (!sleepEventsUsed.has(sleep.id)) {
            matchedData.push({ wake: null, sleep });
        }
    });

    return matchedData;
}

export async function getEvents(userId:number, phrase: string, filename: string) {
    let embedding = await createEmbedding(phrase)
    // get interactions for user id 1 only after 2024-04-24T13:13:48.215+00:00
    let matches = await getHasura().query({
        match_interactions: [{
            args: {
                target_user_id: userId,
                query_embedding: $`embedding`,
                match_threshold: 0.35,
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
    fs.writeFileSync(filename, JSON.stringify(matches));
}

export async function writeToDatabase(userId:number) {
    const matches: { sleep?: Event, wake?: Event }[] = JSON.parse(fs.readFileSync('matchedEvents.json', 'utf-8'));
    const objectsToInsert = [];  // Array to hold all objects for a single mutation

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

        objectsToInsert.push({
            user_id: userId,
            event_type: 'sleep',
            start_time: start_time,
            end_time: end_time,
            cost_time: cost_time,
            metadata: metadata
        });
    }    
}


// export async function writeToDatabase() {
//     const matches: { sleep: Event, wake?: Event }[] = JSON.parse(fs.readFileSync('matchedEvents.json', 'utf-8'));
//     

//     for (const match of matches) {
//         const start_time = match.sleep.timestamp;
//         let end_time = match.sleep.timestamp; // Default to the same if no wake event
//         let cost_time = 0;

//         // If there is a matching wake event, calculate the actual cost_time
//         if (match.wake) {
//             end_time = match.wake.timestamp;
//             cost_time = getCostTimeInSeconds(start_time, end_time);
//         }




//     }
// }