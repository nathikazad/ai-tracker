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

interface PostGISPoint {
    type: "Point";
    coordinates: number[];
}

interface DBLocation {
    id?: number,
    location: PostGISPoint
    name?: string
}

export interface StopMovementRequest {
    eventType: string,
    locations: Location[],
    numberOfPoints: number,
    timeSinceLastMovement: number,
    timeStopped: string
}

interface StartMovementRequest {
    eventType: string,
    distanceChanged: number,
    threshold: number,
    oldLocation: Location,
    newLocation: Location,
}

export async function setNameForLocation(userId: number, lon: number, lat: number, name: string) {
    let closestLocation = await getClosestUserLocation(userId, { lat: lat, lon: lon, accuracy: 0, timestamp: "" }, 200)
    if (!closestLocation) {
        console.log("No location found for this user. Creating a new one.");

        let newLocation = await insertLocation(userId, { lat: lat, lon: lon, accuracy: 0, timestamp: "" }, name)
        closestLocation = newLocation
    } else {
        // update the name of the location
    }
    // update all locations that fall into this location
    let resp = await getHasura().query({
        events: [{
            where: {
                user_id: {
                    _eq: userId
                },
                event_type: {
                    _eq: "stay"
                }
            }
        }, {
            id: true,
            metadata: [{}, true]
        }]
    })
    // filter all locations that are less than 0.2km from lat and lon
    let eventsWithCloseLocations = resp.events.filter((event) => {
        // if(event.metadata?.location?.name != "Unknown location") {
        //     return false
        // }
        try {
            let location = event.metadata.location.location
            let distance = calculateDistance(
                { lat: location.coordinates[1], lon: location.coordinates[0], accuracy: 0, timestamp: "" },
                { lat: lat, lon: lon, accuracy: 0, timestamp: "" }
            )
            return distance < 0.2
        } catch (e) {
            console.log("Error");
            return false
        }
    })
    eventsWithCloseLocations.forEach(async (loc) => {
        try {
            console.log(`Event ${loc.id} ${JSON.stringify(loc.metadata.location.location)} is close to ${name}`)
        } catch (e) {
            console.log("Error");

        }
        await getHasura().mutation({
            update_events_by_pk: [{
                pk_columns: {
                    id: loc.id
                },
                _append: {
                    metadata: $`metadata`
                }
            }, {
                id: true
            }]
        }, {
            "metadata": {
                location: {
                    ...loc.metadata.location,
                    name: name,
                    id: closestLocation!.id
                }
            }
        })

    })
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


// save commute polyline
// mark stay event as finished
// check if start location of commute is the same as the end location of the stay event
// if yes, update the stay event with the end time
// if no, create a new stay event
async function stopMovementEvent(userId: number, movementRequest: StopMovementRequest) {
    const encodedPolyline = polyline.encode(movementRequest.locations.map(loc => [loc.lat, loc.lon]))
    console.log(`Stopped moving. Total distance: ${encodedPolyline} ${calculateTotalDistance(movementRequest.locations).toFixed(2)} km`);

    let endLocation = movementRequest.locations![movementRequest.locations!.length - 1];
    let stoppedTime = new Date(Date.parse(endLocation.timestamp))
    let endDbLocation: DBLocation | undefined = await getClosestUserLocation(userId, endLocation)
    if (endDbLocation) {
        console.log(`End location ${endDbLocation.name} is already registered by this user`)
    } else {
        endDbLocation = {
            location: convertLocationToPostGISPoint(endLocation),
            name: "Unknown location"
        }
    }

    let startLocation = movementRequest.locations![movementRequest.locations!.length - 1];
    let startedTime = new Date(Date.parse(startLocation.timestamp))
    let startDbLocation: DBLocation | undefined = await getClosestUserLocation(userId, startLocation)
    if (startDbLocation) {
        console.log(`Start location ${startDbLocation.name} is already registered by this user`)
    } else {
        startDbLocation = {
            location: convertLocationToPostGISPoint(endLocation),
            name: "Unknown location"
        }
    }
    let interaction = `Entered ${endDbLocation?.name ?? "unknown location"}`

    let lastEvent = await getLastUnfinishedEvent(userId, "stay", stoppedTime, 24)
    if (lastEvent) {
        console.log("There is a recent stay event for this user")
        if (lastEvent.metadata?.location?.id == startDbLocation?.id) {
            console.log("Start location of commute is same as the location of last stay event, so stay event is correct.")
            if (lastEvent.metadata?.location?.id == endDbLocation?.id) {
                console.log("End location is also same, so don't do anything, means user didn't move. Dont do anything")
                return
            } else {
                console.log("End location is different, means user moved, so updating the end time.")
                updateEvent(lastEvent.id, stoppedTime, {})
                await finishCommute(userId, movementRequest.locations!)
            }
        } else {
            console.log("But stay event exists but for a different location. Creating a new stay event for this location.")
            insertStay(userId, startedTime, undefined, startDbLocation)
            await finishCommute(userId, movementRequest.locations!)
        }
    } else {
        console.log("No stay event found for this user. Creating a new event without end.");
        insertStay(userId, startedTime, undefined, startDbLocation)
        console.log();
        
        await finishCommute(userId, movementRequest.locations!)
    }

    console.log("Interaction: ", interaction);
    insertInteraction(userId, interaction, "event", { location: endDbLocation }, movementRequest.timeStopped)
}

export async function startMovementEvent(userId: number, movementRequest: StartMovementRequest) {
    console.log("Started moving");
    let movementStartedTime = new Date(Date.parse(movementRequest.newLocation.timestamp))
    startCommute(userId, movementRequest.newLocation, movementStartedTime)
    let lastEvent = await getLastUnfinishedEvent(userId, "stay", movementStartedTime, 24)
    if (lastEvent) {
        console.log(`Recent stay event found with id ${lastEvent} name ${lastEvent.metadata?.location?.name}. Updating the end time.`);
        
        let timeAtLocation = movementStartedTime.getTime() - Date.parse(lastEvent.start_time)
        let interaction = `Left ${lastEvent?.metadata?.location?.name ? lastEvent.metadata.location.name : "location"} after ${secondsToMMSS(timeAtLocation)}`
        updateEvent(lastEvent.id, movementStartedTime, {
            total_time: secondsToMMSS(timeAtLocation)
        })
        insertInteraction(userId, interaction, "event", { location: lastEvent.metadata })
    } else {
        console.log("No recent stay event found. Creating a new one.")
        let dbLocation: DBLocation | undefined = await getClosestUserLocation(userId, movementRequest.oldLocation)
        if (dbLocation) {
            console.log(`This location ${dbLocation.name} is already registered by this user`)

        } else {
            dbLocation = {
                location: convertLocationToPostGISPoint(movementRequest.oldLocation),
                name: "Unknown location"
            }
        }
        insertInteraction(userId, `Left ${dbLocation.name}`, "event", { location: dbLocation })
    }
}


async function getClosestUserLocation(userId: number, currentLocation: Location, radius: number = 100): Promise<DBLocation | undefined> {
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
    if (locs.users_by_pk?.closest_user_location?.length == 0) {
        return;
    } else {
        return locs.users_by_pk!.closest_user_location![0];
    }
}

// get only last event of same type within last n hours only if end_time is null
async function getLastUnfinishedEvent(userId: number, event_type: string, date: Date, hours: number = 0) {
    let checkDate = new Date(date.getTime() - hours * 60 * 60 * 1000)
    let lastEvents = await getHasura().query({
        events: [{
            limit: 1,
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
                    start_time: {
                        _gt: checkDate.toISOString()
                    }
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
    if (lastEvents.events.length > 0 && lastEvents.events[0].end_time == null) {
        return lastEvents.events[0]
    } else {
        return null;
    }
}

function insertStay(userId: number, startTime: Date | undefined, endTime: Date | undefined, dbLocation?: DBLocation) {
    let chain = getHasura();
    chain.mutation({
        insert_events: [{
            objects: [{
                event_type: "stay",
                end_time: endTime?.toISOString(),
                start_time: startTime?.toISOString(),
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
    console.log("Creating a new commute one.")
    insertNewCommute(userId, [startLocation]);
}

async function finishCommute(userId: number, locations: Location[]) {
    let totalDistance = calculateTotalDistance(locations)
    const encodedPolyline = polyline.encode(locations.map(loc => [loc.lat, loc.lon]))
    let endTime = new Date(Date.parse(locations[locations.length - 1].timestamp))
    let lastCommuteEvent = await getLastUnfinishedEvent(userId, "commute", endTime, 8)
    console.log("Last commute event", lastCommuteEvent, " ", locations[0])
    let timeDiff
    if (lastCommuteEvent) {
        console.log(`Recent commute event found with distance difference ${calculateDistance(locations[0], lastCommuteEvent.metadata.start_location).toFixed(2)}`)
        // check if the last commute's start location is within 5 km of the first location of this commute
        if (calculateDistance(locations[0], lastCommuteEvent.metadata.start_location) < 0.7) {
            console.log("Commute event found for the same location. Updating the end time and polyline.")
            let startTime = new Date(Date.parse(locations[0].timestamp))
            timeDiff = secondsToMMSS(endTime.getTime() - startTime.getTime())
            updateEvent(lastCommuteEvent.id, endTime, { polyline: encodedPolyline, time_taken: timeDiff, distance: totalDistance.toFixed(2) });
        } else {
            console.log("Commute event found but for a different location. Creating a new one.")
            insertNewCommute(userId, locations);
        }
    } else {
        console.log("No recent commute event found. Creating a new one.")
        let startTime = new Date(Date.parse(locations[0].timestamp))
        timeDiff = secondsToMMSS(endTime.getTime() - startTime.getTime())
        insertNewCommute(userId, locations);
    }

    let timeDiffText = timeDiff ? `Time taken: ${timeDiff}` : ""
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

function insertNewCommute(userId: number, locations: Location[]) {
    // if length is greater than 1, means it end commute and in that case if distance is less than 0.2km, don't create a new event
    // if its 1, means it is start commute event, so create a new event
    if (locations.length > 1 && calculateTotalDistance(locations) < 0.5) {
        console.log(`End commute and Commute distance ${calculateTotalDistance(locations).toFixed(2)} is less than 0.5 km. Not creating a new event.`)
        return;
    }
    let startTime = new Date(Date.parse(locations[0].timestamp))
    let metadata, endTime
    if(locations.length > 1) {
        let encodedPolyline = polyline.encode(locations.map(loc => [loc.lat, loc.lon]))
        endTime = new Date(Date.parse(locations[locations.length - 1].timestamp))
        let timeDiff = secondsToMMSS(endTime.getTime() - startTime.getTime())
        let totalDistance = calculateTotalDistance(locations)
        metadata = { polyline: encodedPolyline, time_taken: timeDiff, distance: totalDistance.toFixed(2) }
    } else {
        metadata = { start_location: locations[0]}
        endTime = undefined
    }
    console.log("Creating a new commute event. ", metadata);
    
    let chain = getHasura();
    chain.mutation({
        insert_events: [{
            objects: [{
                event_type: "commute",
                metadata: $`metadata`,
                user_id: userId,
                start_time: startTime.toISOString(),
                end_time:  endTime?.toISOString()
            }]
        }, {
            returning: {
                id: true
            }
        }]
    }, {
        "metadata": metadata
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

export async function insertLocation(userId: number, location: Location, name: string): Promise<DBLocation> {
    let chain = getHasura();
    let resp = await chain.mutation({
        insert_locations: [{
            objects: [{
                location: $`location`,
                user_id: userId,
                name: name
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


function convertLocationToPostGISPoint(location: Location): PostGISPoint {
    return {
        type: "Point",
        coordinates: [location.lon, location.lat]
    }
}

