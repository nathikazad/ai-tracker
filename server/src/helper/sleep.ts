import { getHasura } from "../config";
import { $, timestamp_comparison_exp } from "../generated/graphql-zeus";
import { toPST } from "../scratch";
import { getCostTimeInSeconds } from "../scripts/sleepExtract";
import { addHoursToTimestamp, secondsToHHMM, toDate } from "./time";

export async function uploadSleep(userId: number, matches: { sleep?: string, wake?: string }[]) {
    for (const match of matches) {

        let start_time
        let end_time
        let cost_time = 0;

        if (match.sleep) {
            start_time = match.sleep;
            // skip if start time is before yesterday
            if(toDate(start_time) < new Date(new Date().setDate(new Date().getDate() - 2))) {
                console.log(`Skipping event with start time ${toPST(start_time)}`);
                continue;
            }
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
            // console.log(`Event already exists for ID ${resp.events[0].id}`);
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

