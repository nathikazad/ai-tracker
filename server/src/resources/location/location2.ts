import * as polyline from '@mapbox/polyline';
import { addHours, getStartOfDay, toDate, toPST } from '../../helper/time';
import { ASLocation, DeviceLocation, PostGISPoint, StationaryPeriod, convertASLocationToPostGISPoint, convertPostGISPointToASLocation, getAverageLocation, getDistance, getDuration, getEventLocation } from './locationUtility';
import { getClosestUserLocation, getLastStayEvents, getStayEventsWithLocation, insertLocation } from './locationDb';
import  { insertStay, updateStay } from './locationDb';
import { getUserMovementByDate, getUserMovements, insertUserMovement, isTimeCollisionError, updateUserMovement } from './userMovement';
import { associateEventWithLocation } from '../associations/associationsDb';


export async function saveLocation(userId: number, location: ASLocation, name: string) {
    let newDBLocation = await insertLocation(userId, location, name);
    console.log(`Location: ${newDBLocation.id}`)
    let stayEvents = await getStayEventsWithLocation(userId)
    console.log(`Events: ${stayEvents.length}`)
    stayEvents = stayEvents.filter(event => event.metadata?.location?.location ?? false)
    console.log(`Events with location: ${stayEvents.length}`)
    // see which ones are within 200m
    stayEvents = stayEvents.filter(event => {
        return getDistance(getEventLocation(event), location) < 200
    })
    console.log(`Events within 500m: ${stayEvents.length}`)
    let eventsWithLocation = stayEvents.filter(event => (event.locations?.length ?? 0) > 0)
    let eventsWithoutLocation = stayEvents.filter(event => (event.locations?.length ?? 0) == 0)
    console.log(`Events with location: ${eventsWithLocation.length}`)
    console.log(`Events without location: ${eventsWithoutLocation.length}`)

    for (let event of eventsWithoutLocation) {
        console.log(`Event(${event.id}) has no location`)
        associateEventWithLocation(userId, event.id, newDBLocation.id!);
    }

    for (let event of eventsWithLocation) {
        console.log(`Event(${event.id}) has location id ${event.locations![0].id} and name ${event.locations![0].name}`)
    }
    return newDBLocation.id!
}


export async function addUserMovement(userId: number, locations: DeviceLocation[], fromBackground: boolean = false) {
    // make time equal start of day
    let timestamp = getStartOfDay(locations[0].timestamp);
    try {
        await insertUserMovement(userId, timestamp, locations, fromBackground);
    } catch (error) {
        if (isTimeCollisionError(error)) {
            let resp = await getUserMovementByDate(userId, timestamp);
            console.log(resp);
            updateUserMovement(resp.user_movements[0].id, locations, fromBackground);
        } else {
            throw error;
        }
    }
    await updateMovements(userId)
}

export async function updateMovements(userId: number) {
    console.log(`start of day ${getStartOfDay(new Date().toISOString())}`)

    let events = await getLastStayEvents(userId, 2)
    for(let event of events) {
        console.log(`EVENT: ${event.id} ${toPST(event.start_time)} - ${toPST(event.end_time)} ${event.metadata?.location?.name}`)
    }
    let resp = await getUserMovements(events, userId);
    
    // make a single array of all locations by combining all moves
    
    let locations: DeviceLocation[] = []
    for (let key in resp.user_movements) {
        console.log(`key ${key} ${resp.user_movements[key].moves.length}`)
        // length of moves
        for(let i in resp.user_movements[key].moves) {
            let move = resp.user_movements[key].moves[i]
            // console.log(`moves ${toPST(resp.user_movements[key].moves[i].timestamp)}`)
            locations.push({
                lat: move.lat,
                lon: move.lon,
                timestamp: move.timestamp,
                accuracy: move.accuracy
            });
        }
    }
    
    // console.log(`moves ${Object.keys(moves).length}`)
    console.log(`locations ${locations.length}`)
    locations.sort((a, b) => new Date(a.timestamp).getTime() - new Date(b.timestamp).getTime());
    let newLocations: DeviceLocation[] = []
    if(events.length == 2) {
        let startDate = toDate(events[0].end_time)
        console.log(`start date ${toPST(startDate.toISOString())}`)
        startDate = addHours(startDate, -1)
        console.log(`start date ${toPST(startDate.toISOString())}`)
        for(let location of locations) {
            if(new Date(location.timestamp) > startDate) {
                newLocations.push(location)
            }
        }
    }
    if(locations.length == 0) {
        return;
    }
    console.log(`locations ${locations.length}`)
    console.log(`new locations ${newLocations.length}`)
    let stationaryPeriods = findStationaryPeriods(newLocations, 3, 20, 60, 5)
    console.log(`stationary periods ${stationaryPeriods.length}`)
    if(events.length == 2) {
        for(let i = 0; i < stationaryPeriods.length; i++) {
            let sp = stationaryPeriods[i]
            console.log(toDate(sp.endTime).getTime(), toDate(events[0].end_time).getTime())
            if(toDate(sp.endTime).getTime() == toDate(events[0].end_time).getTime()) {
                console.log(`removing ${i}`)
                stationaryPeriods = stationaryPeriods.slice(i+1)
                break
            }
            
        }
    }
    if(stationaryPeriods.length == 0) {
        return
    }
    // find max distance between points
    let maxDistance = 0
    for (let i = 0; i < stationaryPeriods.length - 1; i++) {
        for(let j = i + 1; j < stationaryPeriods.length; j++) {
            let distance = getDistance(stationaryPeriods[i].location, stationaryPeriods[j].location)
            if(distance > maxDistance) {
                maxDistance = distance
            }
        }
    }
    console.log(`Max distance: ${maxDistance}`)
    maxDistance = maxDistance == 0 ? 1000 : maxDistance
    let closestLocations = await getClosestUserLocation(userId, stationaryPeriods[0].location, maxDistance * 5);
    // console.log(closestLocations)
    // find the closest point for each stationary point
    for (let stationaryPeriod of stationaryPeriods) {
        let minDistance = 200
        for (let location of closestLocations) {
            // let distance = geolib.getDistance({ latitude: stationaryPeriod, longitude: stationaryPeriod.longitude }, { latitude: location.location.coordinates[1], longitude: location.location.coordinates[0] })
            let distance = getDistance(stationaryPeriod.location, convertPostGISPointToASLocation(location.location))
            if(distance < minDistance) {
                minDistance = distance
                stationaryPeriod.closestLocation = location
                stationaryPeriod.closestDistance = distance
            }
        }
    }
    // print closest location for each point and the distance
    for(let stationaryPeriod of stationaryPeriods) {
        console.log(`STATIONARY 2: ${toPST(stationaryPeriod.startTime)} - ${toPST(stationaryPeriod.endTime)} ${stationaryPeriod.closestLocation?.name} ${stationaryPeriod.closestDistance}`)
    }
    // hash start and end timestamp into a single string

    console.log(stationaryPeriods.length)
    
    let periodsToWrite: StationaryPeriod[] = stationaryPeriods

    if(events.length == 2) {
        periodsToWrite = stationaryPeriods.slice(1)
        let period = stationaryPeriods[0]
        let closestLocation = period.closestLocation ?? {
            location: convertASLocationToPostGISPoint(period.location),
            name: "Unknown location"
        }
        console.log(`update ${events[1].id} ${toPST(period.startTime)} ${toPST(period.endTime)} ${closestLocation.name}`)
        updateStay(events[1].id, new Date(period.startTime), new Date(period.endTime), closestLocation)
        // update event triggers
    }

    
    // lengths of each
    console.log(`To write: ${periodsToWrite.length}`)
    // insert into database
    for(let period of periodsToWrite) {
        console.log(`insert ${toPST(period.startTime)} - ${toPST(period.endTime)} ${period.closestLocation?.name}`)
        let closestLocation = period.closestLocation ?? {
            location: convertASLocationToPostGISPoint(period.location),
            name: "Unknown location"
        }
        
        let stayEvent = await insertStay(userId, new Date(period.startTime), new Date(period.endTime), closestLocation) 
        // inside event triggers

        if(closestLocation.id && stayEvent.insert_events_one) {
            await associateEventWithLocation(userId, stayEvent.insert_events_one!.id, closestLocation.id);
        }
    }
}

function findStationaryPeriods(deviceLocations: DeviceLocation[], windowSize: number, thresholdDistance: number, thresholdTime: number, minDuration: number): StationaryPeriod[] {
    console.log(`data ${deviceLocations.length}`)
    deviceLocations.sort((a, b) => new Date(a.timestamp).getTime() - new Date(b.timestamp).getTime());
    // filter out points with accuracy less than 40 except if it is the last point
    deviceLocations = deviceLocations.filter((p, i) => (p.accuracy && p.accuracy < 40) || i == deviceLocations.length - 1)
    let velocity: number[] = []
    for (let i = 0; i < deviceLocations.length; i++) {
        const currWindowSize = (windowSize > deviceLocations.length - i) ? deviceLocations.length - i : windowSize;
        const window: DeviceLocation[] = deviceLocations.slice(i, i + currWindowSize);
        const avgLocation = getAverageLocation(window);
        const distances = window.map(p => getDistance(p, avgLocation));
        const distTotal = Math.ceil(distances.reduce((acc, curr) => acc + curr, 0));
        let timeSpan = new Date(window[window.length - 1].timestamp).getTime() - new Date(window[0].timestamp).getTime();
        timeSpan = Math.ceil(timeSpan / 1000); 
        velocity.push(distTotal/timeSpan)
    }
    console.log(`velocity ${velocity.length}`)
    let stationary = false
    let points: DeviceLocation[] = []
    let stationaryPeriods: StationaryPeriod[] = []
    if(velocity[0] < 0.5) {
        stationary = true
        stationaryPeriods.push(constructStationary(deviceLocations.slice(0, 2), `${0} - ${1}`))
    }
    console.log(`initial stationary: ${stationary} ${velocity[0].toFixed(2)}`)
    
    for (let i = 0; i < deviceLocations.length; i++) {
        let distance = 0
        if(i < deviceLocations.length - 1) {
            distance = getDistance(deviceLocations[i], deviceLocations[i+1])
        }
        console.log(`i: ${i} ${toPST(deviceLocations[i].timestamp)} d:${distance} v:${velocity[i].toFixed(2)} a:${deviceLocations[i].accuracy?.toFixed(2)} `)
        points.push(deviceLocations[i])
        let totalPointsTime = 0
        if(points.length > 1)
           totalPointsTime = getDuration(points[0], points[points.length - 1]);

        // if(totalPointsTime < 60) {
        //     continue
        // }
        if(stationary) {
            stationaryPeriods[stationaryPeriods.length - 1] = constructStationary(points, `${i - points.length + 1} - ${i-1}`)
            if(velocity[i] > 0.5 || 
                (distance > 150)) {
                stationary = false
                console.log(`\tSTART MOVING velThresh: ${velocity[i] > 0.5}, distThresh: ${distance > 150}`)
                points = []
            }
        } else {
            if(velocity[i] < 0.5) {
                stationary = true
                console.log(`\tSTOP MOVING ${stationaryPeriods.length} velThresh: ${velocity[i] < 0.5}`)
                points = deviceLocations.slice(i, i+2)
                stationaryPeriods.push(constructStationary(points, `${i} - ${i+1}`))
            }
        }
    }
    // merge points that are less than 100m from each other
    let mergedPoints: StationaryPeriod[] = [stationaryPeriods[0]]
    for(let i = 1; i < stationaryPeriods.length; i++) {
        
        let last = mergedPoints[mergedPoints.length - 1]
        let distance = getDistance(last.location, stationaryPeriods[i].location)
        if(distance < 100) {
            last.endTime = stationaryPeriods[i].endTime
            last.duration += stationaryPeriods[i].duration
            let newPoints: DeviceLocation[] = last.points.concat(stationaryPeriods[i].points)
            last.points = newPoints
            last.fullPolyline = polyline.encode(newPoints.map(p => [p.lat, p.lon]))
        } else {
            mergedPoints.push(stationaryPeriods[i])
        }
    }
    // filter out periods that are less than 5 minutes
    return mergedPoints.filter(p => new Date(p.endTime).getTime() - new Date(p.startTime).getTime() > minDuration * 60 * 1000)
}

function constructStationary(initData: DeviceLocation[], range: string) : StationaryPeriod {
    let last = initData[initData.length - 1]
    let avgLocation = getAverageLocation(initData);
    let poly = polyline.encode(initData.map(p => [p.lat, p.lon]));
    return {
        startTime: initData[0].timestamp,
        endTime: last.timestamp,
        duration: getDuration(initData[0], last),
        // latitude: avgLocation.lat,
        location: avgLocation,
        // longitude: avgLocation.lon,
        points: initData,
        polyline: polyline.encode([[avgLocation.lat, avgLocation.lon]]),
        fullPolyline: poly,
        range: range
    };
}
