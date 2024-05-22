import { getHasura } from '../../config';
import { GraphQLError, $, order_by, timestamptz_comparison_exp } from '../../generated/graphql-zeus';
import { ASLocation, DBLocation, DeviceLocation } from './locationUtility';

export function insertStay(userId: number, startTime: Date | undefined, endTime: Date | undefined, dbLocation?: DBLocation) {
    let chain = getHasura();
    return chain.mutation({
        insert_events_one: [{
            object: {
                event_type: "stay",
                end_time: endTime?.toISOString(),
                start_time: startTime?.toISOString(),
                user_id: userId,
                metadata: $`metadata`,
            },
        }, {
          id: true  
        }]
    }, {
        "metadata": {
            location: dbLocation
        }

    })
}

export function updateStay(id: number, startTime: Date | undefined, endTime: Date | undefined, dbLocation?: DBLocation) {
    let chain = getHasura();
    return chain.mutation({
        update_events_by_pk: [{
            pk_columns: {
                id: id
            },
            _set: {
                start_time: startTime?.toISOString(),
                end_time: endTime?.toISOString(),
                metadata: $`metadata`
            }
        }, {
            id: true
        }]
    }, {
        "metadata": {
            location: dbLocation
        }
    })
}


export function deleteStay(eventId: number) {
    let chain = getHasura();
    return chain.mutation({
        delete_events_by_pk: [{
            id: eventId
        }, {
            id: true
        }]
    })
}

export async function getClosestUserLocation(userId: number, currentLocation: ASLocation, radius: number = 100): Promise<DBLocation[]> {
    console.log(`POINT(${currentLocation.lat} ${currentLocation.lon})`);
    let locs = await getHasura().query({
        users_by_pk: [{
            id: userId
        }, {
            closest_user_location: [{
                args: {
                    radius: radius,
                    ref_point: `SRID=4326;POINT(${currentLocation.lon} ${currentLocation.lat})`
                }
            }, {
                id: true,
                location: true,
                name: true
            }]
        }]
    });

    return locs.users_by_pk!.closest_user_location!;
}

export async function getLastEvents(userId: number, event_type: string, limit: number) {
    let lastEvents = await getHasura().query({
        events: [{
            limit: limit,
            order_by: [{
                start_time: order_by.desc
            }],
            where: {
                _and: [{
                    user_id: {
                        _eq: userId
                    },
                    event_type: {
                        _eq: event_type
                    },
                    // start_time: {
                    //     _gte: date.toISOString()
                    // }
                    // ,
                    // end_time: {
                    //     _is_null: true
                    // }
                }]
            }
        }, {
            id: true,
            metadata: [{}, true],
            start_time: true,
            end_time: true
        }]
    });
    // for(let event of lastEvents.events) {
    //     console.log(`event ${event.id} ${event.start_time}`)
    // }
    // reverse the order
    lastEvents.events.reverse();
    return lastEvents.events
}