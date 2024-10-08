import { getHasura } from "../config";
import { $, timestamp_comparison_exp } from "../generated/graphql-zeus";
import { Category } from "../resources/logic/eventLogic";
import { addHoursToTimestamp, secondsToHHMM, toDate, getCostTimeInSeconds, toPST } from "./time";

export async function uploadSleep(userId: number, stream: { sleep?: string, wake?: string }[]) {
    for (const event of stream) {

        let start_time
        let end_time
        let cost_time = 0;

        if (event.sleep) {
            start_time = event.sleep;
            // skip if start time is before yesterday
            if(toDate(start_time) < new Date(new Date().setDate(new Date().getDate() - 1))) {
                console.log(`Skipping event with start time ${toPST(start_time)}`);
                continue;
            }
        }

        if (event.wake) {
            end_time = event.wake;
        }
        console.log(`${toPST(start_time)} ${toPST(end_time)}`)
        if (event.sleep && event.wake) {
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
                _gt: addHoursToTimestamp(start_time!, -3),
                _lt: addHoursToTimestamp(start_time!, 3)
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
                        _eq: Category.Sleeping
                    }
                }
            }, {
                id: true,
                start_time: true,
                end_time: true,
                metadata: [{}, true]
            }]
        })
        if (resp.events.length > 0) {
            let metadata: any = resp.events[0].metadata;
            let isLocked = metadata?.locks?.end_time;
            console.log(`Event already exists for ID ${resp.events[0].id} and isLocked: ${isLocked}`);
            if(end_time != `${resp.events[0].end_time}Z` && !isLocked) { // add Z because watch UTC encode adds Z
                client.mutation({
                    update_events_by_pk: [{
                        pk_columns: {
                            id: resp.events[0].id
                        },
                        _set: {
                            end_time: end_time
                        },
                        _append: {
                            logs: $`logs`
                        }
                        
                    }, {
                        id: true
                    }]
                },{
                    logs: {
                        [toPST(new Date().toISOString())]: "Sensor updated end time of sleep event"
                    }
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
                        event_type: Category.Sleeping,
                        start_time: start_time,
                        end_time: end_time,
                        cost_time: cost_time,
                        metadata: $`metadata`,
                        logs: $`logs`
                    }
                }, {
                    id: true
                }]
            }, {
                "metadata": metadata,
                "logs": {
                    [toPST(new Date().toISOString())]: "Sensor created new sleep event"
                }
            });
        }
    }
}

