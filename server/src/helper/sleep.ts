import { getHasura } from "../config";
import { $, timestamp_comparison_exp } from "../generated/graphql-zeus";
import { secondsToHHMM } from "./location";

export async function uploadSleep(userId: number, matches: { sleep?: string, wake?: string }[]) {
    for (const match of matches) {
        let start_time
        let end_time
        let cost_time = 0;

        if (match.sleep) {
            start_time = match.sleep;
        }
        if (match.wake) {
            end_time = match.wake;
        }
        console.log(`${toPST(start_time)} ${toPST(end_time)}`)
        if (match.sleep && match.wake) {
            cost_time = getCostTimeInSeconds(start_time!, end_time!);
        }
        let metadata = {}
        if (cost_time != 0) {
            metadata = {
                time_taken: secondsToHHMM(cost_time)
            };
        }
        let startConditions: timestamp_comparison_exp = {}
        if (start_time) {
            startConditions = {
                _gt: addHoursToTimestamp(start_time!, -1),
                _lt: addHoursToTimestamp(start_time!, 1)
            }
        }
        const client = getHasura();
        let resp = await client.query({
            events: [{
                where: {
                    user_id: {
                        _eq: userId
                    },
                    start_time: startConditions,
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
            if(end_time != `${resp.events[0].end_time}Z`) { // add Z because watch UTC encode adds Z
                client.mutation({
                    update_events_by_pk: [{
                        pk_columns: {
                            id: resp.events[0].id
                        },
                        _set: {
                            end_time: end_time
                        }
                    }, {
                        id: true
                    }]
                })
            } else {
                console.log(`End time is same`)
            }
        } else {
            // create new event with start_time and end_time
            client.mutation({
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
        }
    }
}

function toPST(dateString: string | undefined): string {
    if (!dateString) {
        return 'N/A';
    }
    // dateString += 'Z'
    // Create a new Date object from the UTC timestamp
    const date = new Date(dateString);

    // Convert the date to PST by specifying the timeZone in toLocaleString options
    const pstDate = date.toLocaleString('en-US', {
        timeZone: 'America/Los_Angeles',
        hour12: true, // Use 12-hour format
        month: '2-digit',
        day: '2-digit',
        hour: 'numeric',
        minute: '2-digit',
        second: '2-digit'
    });

    // Replace commas with spaces and adjust AM/PM casing
    // return pstDate.replace(',', '').replace('AM', 'a.m.').replace('PM', 'p.m.');
    return pstDate
}

function getCostTimeInSeconds(start: string, end: string): number {
    const startTime = new Date(start);
    const endTime = new Date(end);
    return Math.floor((endTime.getTime() - startTime.getTime()) / 1000);
}

function addHoursToTimestamp(timestamp: string, hours: number): string {
    if (!timestamp) {
        undefined
    }
    const date = new Date(timestamp!);
    date.setHours(date.getHours() + hours);
    return date.toISOString();
}