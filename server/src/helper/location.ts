import * as polyline from '@mapbox/polyline';
import { insertInteraction } from '../resources/interactions';
import { getHasura } from '../config';
import { $, order_by } from '../generated/graphql-zeus';
interface Location {
    lat: number;
    lon: number;
    accuracy: number;
    timestamp: string;
}

interface DBLocation {
    id?: number,
    location: Record<string, any>
    name?: string
}

export interface StopMovementRequest {
    eventType: String,
    locations: Location[],
    numberOfPoints: number,
    timeSinceLastMovement: number,
}

interface StartMovementRequest {
    eventType: String,
    distanceChanged: number,
    threshold: number,
    oldLocation: Location,
    newLocation: Location,
}

export async function processMovement(userId: number, movementRequest: StopMovementRequest | StartMovementRequest) {
    if (movementRequest.eventType === "stoppedMoving") {
        await stopMovementEvent(userId, movementRequest as StopMovementRequest);
    } else if (movementRequest.eventType === "startedMoving") {
        await startMovementEvent(userId, movementRequest as StartMovementRequest);
    } else {
        console.log("Invalid movement event type.")
    }
}

async function stopMovementEvent(userId: number, movementRequest: StopMovementRequest) {
    const encodedPolyline = polyline.encode(movementRequest.locations.map(loc => [loc.lat, loc.lon]))
    console.log(`Stopped moving. Total distance: ${encodedPolyline} ${calculateTotalDistance(movementRequest.locations).toFixed(2)} km`);
    
    let stoppedLocation = movementRequest.locations![movementRequest.locations!.length - 1];
    let stoppedTime = new Date(Date.parse(stoppedLocation.timestamp))
    let dbLocation: DBLocation | undefined = await getClosestUserLocation(userId, stoppedLocation)
    if (dbLocation) {
        console.log(`This location ${dbLocation.name} is already registered by this user`)

    } else {
        dbLocation = {
            location: convertLocationToPostGISPoint(stoppedLocation),
            name: "Unknown location"
        }
    }
    // else {
    //     console.log("This is a new location.")
    //     dbLocation = await insertLocation(userId, stoppedLocation)
    // }
    let interaction = `Entered ${dbLocation?.name ?? "unknown location"}`

    let resp2 = await getIncompleteEvents(userId, "stay", stoppedTime, 24)
    if ((resp2.events?.length ?? 0) > 0) {
        console.log("There is a recent stay event already for this user already ")
        let event = resp2.events![0]
        if (event.metadata?.location.id == dbLocation?.id) {
            console.log("Recent stay event exists for the same location, not doing any db changes")
            return;
        } else {
            console.log("but it exists but for a different location. Creating a new stay event for this location.")
            insertStay(userId, stoppedTime, dbLocation)
            await finishCommute(userId, movementRequest.locations!)
        }
    } else {
        console.log("No stay event found for this user. Creating a new one.");
        insertStay(userId, stoppedTime, dbLocation)
        await finishCommute(userId, movementRequest.locations!)
    }

    console.log("Interaction: ", interaction);
    insertInteraction(userId, interaction, "event", {location: dbLocation})
}

export async function startMovementEvent(userId: number, movementRequest: StartMovementRequest) {
    console.log("Started moving");
    let startedTime = new Date(Date.parse(movementRequest.newLocation.timestamp))
    startCommute(userId, movementRequest.newLocation, startedTime)
    let resp2 = await getIncompleteEvents(userId, "stay", startedTime, 24)
    if (resp2.events.length > 0) {
        let stayEvent = resp2.events[0]
        updateEvent(stayEvent.id, startedTime, {})
        let interaction = `Left ${stayEvent?.metadata?.location?.name ? stayEvent.metadata.location.name : "location"}`
        insertInteraction(userId, interaction, "event", {location: stayEvent.metadata})
    } else {    
        console.log("No recent stay event found. Creating a new one.")
        let interaction = `Left unknown location`
        insertInteraction(userId, interaction, "event")
    }
}


async function getClosestUserLocation(userId: number, currentLocation: Location): Promise<DBLocation | undefined> {
    console.log(`POINT(${currentLocation.lat} ${currentLocation.lon})`);
    let locs = await getHasura().query({
        users_by_pk: [{
            id: userId
        }, {
            closest_user_location: [{
                args: {
                    radius: 100,
                    ref_point: `SRID=4326;POINT(${currentLocation.lon} ${currentLocation.lat})`
                }
            }, {
                id: true,
                location: true,
                name: true
            }]
        }]
    });
    if (locs.users_by_pk?.closest_user_location?.length == 0) {
        return;
    } else {
        return locs.users_by_pk!.closest_user_location![0];
    }   
}

async function getIncompleteEvents(userId: number, event_type: string, date: Date, hours: number = 0) {
    let checkDate = new Date(date.getTime() - hours * 60 * 60 * 1000)
    return await getHasura().query({
        events: [{
            limit: 1,
            order_by: [{
                end_time: order_by.desc
            }],
            where: {
                _and: [{
                    user_id: {
                        _eq: userId
                    },
                    event_type: {
                        _eq: event_type
                    },
                    start_time: {
                        _gt: checkDate.toISOString()
                    },
                    end_time: {
                        _is_null: true
                    }
                }]
            }
        }, {
            id: true,
            metadata: [{}, true],
            start_time: true
        }]
    });
}

function insertStay(userId: number, startTime: Date, dbLocation?: DBLocation) {
    let chain = getHasura();
    chain.mutation({
        insert_events: [{
            objects: [{
                event_type: "stay",
                start_time: startTime.toISOString(),
                user_id: userId,
                metadata: $`metadata`,
            }]
        }, {
            returning: {
                id: true
            }
        }]
    }, {
        "metadata": {
            location: dbLocation
        }

    })
}



function updateEvent(id: number, endTime: Date, metadata: any) {
    let chain = getHasura();
    chain.mutation({
        update_events_by_pk: [{
            pk_columns: {
                id: id
            },
            _set: {
                end_time: endTime.toISOString()
            },
            _append: {
                metadata: $`metadata`
            }
        }, {
            id: true
        }]
    }, {
        "metadata": metadata
    })
}

async function startCommute(userId: number, startLocation: Location, startTime: Date) {
    let commuteEvents = await getIncompleteEvents(userId, "commute", startTime, 8)
    if (commuteEvents.events?.length == 0) {
        console.log("No recent commute event found. Creating a new one.")
        insertNewCommute(userId, startTime, undefined, startLocation);
    } else {
        let commuteEvent = commuteEvents.events![0]
        if (calculateDistance(startLocation, commuteEvent.metadata.start_location) < 0.2) {
            console.log("Recent commute event found for the same location.")
            return;
        } else {
            insertNewCommute(userId, startTime, undefined, startLocation);
        }

    }
}
async function finishCommute(userId: number, locations: Location[]) {
    let totalDistance = calculateTotalDistance(locations)
    if(totalDistance < 0.3) {
        console.log(`Not enough distance to create a commute event. ${totalDistance.toFixed(2)}`);
        return
    }
    const encodedPolyline = polyline.encode(locations.map(loc => [loc.lat, loc.lon]))
    const textPolyline = locations.map(loc => `${loc.lat.toFixed(0)},${loc.lon.toFixed(0)}`).join('|');
    let endTime = new Date(Date.parse(locations[locations.length - 1].timestamp))
    let commuteEvents = await getIncompleteEvents(userId, "commute", endTime, 8)
    let timeDiff
    if (commuteEvents.events?.length == 0) {
        console.log("No recent commute event found. Creating a new one.")
        let startTime = new Date(Date.parse(locations[0].timestamp))
        insertNewCommute(userId, startTime, endTime, locations[0], locations);
    } else {
        console.log("Recent commute event found.")
        let commuteEvent = commuteEvents.events![0]
        if (calculateDistance(locations[0], commuteEvent.metadata.start_location) < 0.5) {
            console.log("Commute event found for the same location. Updating the end time and polyline.")
            updateEvent(commuteEvent.id, endTime, { polyline: encodedPolyline, locations: textPolyline });
            let startTime = new Date(Date.parse(commuteEvent.start_time))
            timeDiff = endTime.getTime() - startTime.getTime()
        } else {
            console.log("Commute event found but for a different location. Creating a new one.")
            let startTime = new Date(Date.parse(locations[0].timestamp))
            insertNewCommute(userId, startTime, undefined, locations[0]);
        }
    }
    
    let timeDiffText = timeDiff ? `Time taken: ${secondsToMMSS(timeDiff)}` : ""
    await insertInteraction(userId, `Finished Commute. ${totalDistance.toFixed(0)}km ${timeDiffText}`, "event", {
        polyline: encodedPolyline
    })
}

function secondsToMMSS(seconds: number): string {
    const minutes: number = Math.floor(seconds / 60000);
    const remainingSeconds: number = seconds % 60;
    const formattedMinutes: string = String(minutes).padStart(2, '0');
    const formattedSeconds: string = String(remainingSeconds).padStart(2, '0');
    return `${formattedMinutes}:${formattedSeconds}`;
}

function insertNewCommute(userId: number, startTime?: Date, endTime?: Date, startLocation?: Location, locations?: Location[]) {
    let encodedPolyline: String | null = null
    let textPolyline: String | null = null
    if (locations) {
        if(calculateTotalDistance(locations) < 0.5) {
            console.log(`Commute distance ${calculateTotalDistance(locations).toFixed(2)} is less than 0.5 km. Not creating a new event.`)
            return;
        }
        encodedPolyline = polyline.encode(locations.map(loc => [loc.lat, loc.lon]))
        textPolyline = locations.map(loc => `${loc.lat},${loc.lon}`).join('|');
        
    }
    let chain = getHasura();
    chain.mutation({
        insert_events: [{
            objects: [{
                event_type: "commute",
                metadata: $`metadata`,
                user_id: userId,
                start_time: startTime?.toISOString(),
                end_time: endTime?.toISOString(),
            }]
        }, {
            returning: {
                id: true
            }
        }]
    }, {
        "metadata": {
            start_location: startLocation,
            polyline: encodedPolyline,
            locations: textPolyline
        }
    });
}
function calculateTotalDistance(locations: Location[]): number {
    let totalDistance = 0;

    for (let i = 0; i < locations.length - 1; i++) {
        const firstLocation = locations[i];
        const secondLocation = locations[i + 1];
        const distance = calculateDistance(firstLocation, secondLocation);
        totalDistance += distance;
    }

    return totalDistance;
}

function calculateDistance(firstLocation: Location, secondLocation: Location): number {
    const earthRadius = 6371; // Radius of the Earth in kilometers

    const dLat = toRadians(secondLocation.lat - firstLocation.lat);
    const dLon = toRadians(secondLocation.lon - firstLocation.lon);

    const a =
        Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos(toRadians(firstLocation.lat)) * Math.cos(toRadians(secondLocation.lat)) * Math.sin(dLon / 2) * Math.sin(dLon / 2);

    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

    const distance = earthRadius * c;
    return distance;
}

function toRadians(degrees: number): number {
    return degrees * (Math.PI / 180);
}

export async function insertLocation(userId: number, location: Location) {
    let chain = getHasura();
    let resp = await chain.mutation({
        insert_locations: [{
            objects: [{
                location: $`location`,
                user_id: userId,
            }]
        }, {
            returning: {
                id: true,
                location: true,
                name: true
            }
        }]
    }, {
        "location": convertLocationToPostGISPoint(location)
    })
    return resp.insert_locations!.returning![0];
}


function convertLocationToPostGISPoint(location: Location) {
    return {
        type: "Point",
        coordinates: [location.lon, location.lat]
    }
}

