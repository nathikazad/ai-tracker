import { getHasura } from "../../config";
import { GraphQLError, $, order_by, timestamptz_comparison_exp } from "../../generated/graphql-zeus";
import { DeviceLocation } from "./locationUtility";
import { addHours, getStartOfDay, toDate, toPST } from '../../helper/time';

export async function getUserMovements(events: { id: number; metadata: any; start_time: any; end_time: any; }[], userId: number) {
    let tzComp: timestamptz_comparison_exp = {};
    if (events.length == 2) {
        tzComp._gte = getStartOfDay(addHours(toDate(events[0].end_time), -24).toISOString());
    }

    let client = getHasura();
    let resp = await client.query({
        user_movements: [
            {
                order_by: [{
                    date: order_by.asc
                }],
                where: {
                    user_id: {
                        _eq: userId
                    },
                    date: tzComp
                }
            },
            {
                id: true,
                moves: [{}, true]
            }
        ]
    });
    return resp;
}

export async function getUserMovementByDate(userId: number, timestamp: string) {
    let client = getHasura();
    return await client.query({
        user_movements: [
            {
                where: {
                    user_id: {
                        _eq: userId
                    },
                    date: {
                        _eq: timestamp,
                    }
                }
            }, {
                id: true
            }
        ]
    });
}

export async function insertUserMovement(userId: number, timestamp: string, locations: any[], fromBackground: boolean) {
    let client = getHasura();
    return await client.mutation({
        insert_user_movements_one: [
            {
                object: {
                    date: timestamp,
                    user_id: userId,
                    moves: $`location`
                }
            }, {
                id: true
            }
        ]
    }, {
        location: convertLocationToJSON(locations, fromBackground)
    });
}
export async function updateUserMovement(movementId: number, locations: DeviceLocation[], fromBackground: boolean = false) {
    let resp = await getHasura().mutation({
        update_user_movements_by_pk: [
            {
                pk_columns: {
                    id: movementId
                },
                _append: {
                    moves: $`location`
                }
            },
            {
                id: true
            }]
    }, {
        location: convertLocationToJSON(locations, fromBackground)
    })

    console.log(resp);
}

function convertLocationToJSON(locations: DeviceLocation[], fromBackground: boolean = false) {
    return locations.map(location => {
        return {
            lat: location.lat,
            lon: location.lon,
            timestamp: location.timestamp,
            accuracy: location.accuracy,
            fromBackground: fromBackground
        }
    })
    
    // {
    //     [location.timestamp]: {
    //         lat: location.lat,
    //         lon: location.lon,
    //         timestamp: location.timestamp,
    //         accuracy: location.accuracy
    //     }
    // }
}

export function isTimeCollisionError(error: any) : boolean {
    error = error as GraphQLError;
    return error.response.errors && error.response.errors[0].message.includes('user_movements_user_id_date_key');
}

