// Import necessary libraries
import * as geolib from 'geolib';
import * as polyline from '@mapbox/polyline';
import { getHasura } from '../config';
import { GraphQLError, $, order_by, timestamptz_comparison_exp } from '../generated/graphql-zeus';
import { addHours, getStartOfDay, toDate, toPST } from './time';
import { get } from 'http';
import { stat } from 'fs';
import e from 'express';

export interface Location {
    lat: number;
    lon: number;
    accuracy?: number;
    timestamp: string;
}

interface PostGISPoint {
    type: "Point";
    coordinates: number[];
}

export interface DBLocation {
    id?: number,
    location: PostGISPoint
    name?: string
}

export async function addLocation(userId: number, locations: Location[]) {
    // make time equal start of day
    let timestamp = getStartOfDay(locations[0].timestamp);
    let client = getHasura();
    try {
        let resp = await client.mutation({
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
            location: convertLocationToJSON(locations)
        });
    } catch (error) {
        let gqlError = error as GraphQLError;
        console.log("ERRPR")
        console.log(gqlError.response.errors![0].message);
        if (gqlError.response.errors && gqlError.response.errors[0].message.includes('user_movements_user_id_date_key')) {
            let resp = await client.query({
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
            console.log(resp);
            updateLocation(resp.user_movements[0].id, locations);
        } else {
            throw error;
        }

    }

    async function updateLocation(movementId: number, locations: Location[]) {
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
            location: convertLocationToJSON(locations)
        })

        console.log(resp);
    }

    function convertLocationToJSON(locations: Location[]) {
        return locations.map(location => {
            return {
                lat: location.lat,
                lon: location.lon,
                timestamp: location.timestamp,
                accuracy: location.accuracy
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
}

export async function updateMovements(userId: number) {
    console.log(`start of day ${getStartOfDay(new Date().toISOString())}`)

    let events = await getLastEvents(userId, "stay", 2)
    for(let event of events) {
        console.log(`EVENT: ${event.id} ${toPST(event.start_time)} - ${toPST(event.end_time)} ${event.metadata?.location?.name}`)
    }
    let tzComp: timestamptz_comparison_exp = {}
    if(events.length == 2) {
        tzComp._gte = getStartOfDay(addHours(toDate(events[0].end_time), -24).toISOString())
        deleteStay(events[1].id)
    }

    let client = getHasura();
    let resp = await client.query({
        user_movements: [
            {
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
    
    // console.log(resp);
    // make a single array of all locations by combining all moves
    let moves: { [key: string]: Location } = {};
    for (let key in resp.user_movements) {
        moves = {
            ...moves,
            ...resp.user_movements[key].moves
        }
    }
    
    console.log(`moves ${Object.keys(moves).length}`)
    let locations: Location[] = []
    for (let key in moves) {
        locations.push({
            lat: moves[key].lat,
            lon: moves[key].lon,
            timestamp: moves[key].timestamp,
            accuracy: moves[key].accuracy
        });
    }
    locations.sort((a, b) => new Date(a.timestamp).getTime() - new Date(b.timestamp).getTime());
    let newLocations: Location[] = []
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
    let stationaryPeriods = findStationaryPeriods(newLocations, 3, 20, 60, 60 * 1000)
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
            let distance = geolib.getDistance({ latitude: stationaryPeriods[i].latitude, longitude: stationaryPeriods[i].longitude }, { latitude: stationaryPeriods[j].latitude, longitude: stationaryPeriods[j].longitude })
            if(distance > maxDistance) {
                maxDistance = distance
            }
        }
    }
    console.log(`Max distance: ${maxDistance}`)
    maxDistance = maxDistance == 0 ? 1000 : maxDistance
    let closestLocations = await getClosestUserLocation(userId, {
        lat: stationaryPeriods[0].latitude,
        lon: stationaryPeriods[0].longitude,
        timestamp: stationaryPeriods[0].startTime
    }, maxDistance * 5);
    // console.log(closestLocations)
    // find the closest point for each stationary point
    for (let stationaryPeriod of stationaryPeriods) {
        let minDistance = 500
        for (let location of closestLocations) {
            let distance = geolib.getDistance({ latitude: stationaryPeriod.latitude, longitude: stationaryPeriod.longitude }, { latitude: location.location.coordinates[1], longitude: location.location.coordinates[0] })
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
    
    let periodsToUpdate: [number, StationaryPeriod][] = []
    let periodsToWrite: StationaryPeriod[] = stationaryPeriods

    
    // lengths of each
    console.log(`To update: ${periodsToUpdate.length} \nTo write: ${periodsToWrite.length}`)
    // insert into database
    for(let period of periodsToWrite) {
        console.log(`insert ${toPST(period.startTime)} - ${toPST(period.endTime)} ${period.closestLocation?.name}`)
        let closestLocation = period.closestLocation ?? {
            location: convertLocationToPostGISPoint({
                lat: period.latitude, 
                lon: period.longitude,
                timestamp: period.startTime}),
            name: "Unknown location"
        }
        if(new Date(period.endTime).getTime() - new Date(period.startTime).getTime() > 15 * 60 * 1000) {
            await insertStay(userId, new Date(period.startTime), new Date(period.endTime), closestLocation) 
        }
    }

    for(let [id, period] of periodsToUpdate) {
        console.log(`update ${id} ${period.startTime}`)
        
    }
    // console.log(JSON.stringify(stay, null, 4))
    // fetch last event
    // skip all stationary that have same time before last event
    // insert or update stay event
}

function convertLocationToPostGISPoint(location: Location): PostGISPoint {
    return {
        type: "Point",
        coordinates: [location.lon, location.lat]
    }
}
interface StationaryPeriod {
    startTime: string;
    endTime: string;
    duration: number;
    latitude: number;
    longitude: number;
    points: Location[];
    polyline: string;
    fullPolyline: string;
    range: string;
    closestLocation?: DBLocation;
    closestDistance?: number;

}

function findStationaryPeriods(data: Location[], windowSize: number, thresholdDistance: number, thresholdTime: number, minDuration: number): StationaryPeriod[] {
    console.log(`data ${data.length}`)
    data.sort((a, b) => new Date(a.timestamp).getTime() - new Date(b.timestamp).getTime());
    
    let velocity: number[] = []
    for (let i = 0; i < data.length; i++) {
        const currWindowSize = (windowSize > data.length - i) ? data.length - i : windowSize;
        const window: Location[] = data.slice(i, i + currWindowSize);
        const avgLocation = getAverageLocation(window);
        const distances = window.map(p => geolib.getDistance({ latitude: p.lat, longitude: p.lon }, { latitude: avgLocation.lat, longitude: avgLocation.lon }));
        const distTotal = Math.ceil(distances.reduce((acc, curr) => acc + curr, 0));
        let timeSpan = new Date(window[window.length - 1].timestamp).getTime() - new Date(window[0].timestamp).getTime();
        timeSpan = Math.ceil(timeSpan / 1000); 
        velocity.push(distTotal/timeSpan)
    }
    console.log(`velocity ${velocity.length}`)
    let stationary = false
    let points: Location[] = []
    let stationaryPeriods: StationaryPeriod[] = []
    if(velocity[0] < 0.5) {
        stationary = true
        stationaryPeriods.push(constructStationary(data.slice(0, 2), `${0} - ${1}`))
    }
    console.log(`initial stationary: ${stationary} ${velocity[0].toFixed(2)}`)
    
    for (let i = 0; i < data.length; i++) {
        points.push(data[i])
        let totalPointsTime = 0
        if(points.length > 1)
           totalPointsTime = getDuration(points[0], points[points.length - 1]);

        if(totalPointsTime < 60) {
            continue
        }
        if(stationary) {
            stationaryPeriods[stationaryPeriods.length - 1] = constructStationary(points, `${i - points.length + 1} - ${i-1}`)
            let distance = 0
            if(i < data.length - 1) {
                distance = geolib.getDistance({ latitude: data[i].lat, longitude: data[i].lon }, { latitude: data[i+1].lat, longitude: data[i+1].lon })
            }
            if(velocity[i] > 0.5 || 
                (distance > 200 && data[i].accuracy !== undefined && data[i].accuracy! < 40)) {
                stationary = false
                points = []
            }
        } else {
            if(velocity[i] < 0.5) {
                stationary = true
                stationaryPeriods.push(constructStationary(data.slice(i, i+2), `${i} - ${i+1}`))
                points = []
            }
        }
    }
    // merge points that are less than 100m from each other
    let mergedPoints: StationaryPeriod[] = [stationaryPeriods[0]]
    for(let i = 1; i < stationaryPeriods.length; i++) {
        let last = mergedPoints[mergedPoints.length - 1]
        let distance = geolib.getDistance({ latitude: last.latitude, longitude: last.longitude }, { latitude: stationaryPeriods[i].latitude, longitude: stationaryPeriods[i].longitude })
        if(distance < 100) {
            last.endTime = stationaryPeriods[i].endTime
            last.duration += stationaryPeriods[i].duration
            let newPoints: Location[] = last.points.concat(stationaryPeriods[i].points)
            last.points = newPoints
            last.fullPolyline = polyline.encode(newPoints.map(p => [p.lat, p.lon]))
        } else {
            mergedPoints.push(stationaryPeriods[i])
        }
    }
    return mergedPoints;
}

function constructStationary(initData: Location[], range: string) : StationaryPeriod {
    let last = initData[initData.length - 1]
    let avgLocation = getAverageLocation(initData);
    let poly = polyline.encode(initData.map(p => [p.lat, p.lon]));
    return {
        startTime: initData[0].timestamp,
        endTime: last.timestamp,
        duration: getDuration(initData[0], last),
        latitude: avgLocation.lat,
        longitude: avgLocation.lon,
        points: initData,
        polyline: polyline.encode([[avgLocation.lat, avgLocation.lon]]),
        fullPolyline: poly,
        range: range
    };
}

function getDuration(startPoint: Location, endPoint: Location) {
    return (new Date(endPoint.timestamp).getTime() - new Date(startPoint.timestamp).getTime()) / 1000;
}

function getAverageLocation(points: Location[]): Location {
    // log(points)
    const sumLatitude = points.reduce((acc, curr) => acc + curr.lat, 0);
    const sumLongitude = points.reduce((acc, curr) => acc + curr.lon, 0);
    return {
        timestamp: points[0].timestamp,
        lat: sumLatitude / points.length,
        lon: sumLongitude / points.length,
    };
}

function insertStay(userId: number, startTime: Date | undefined, endTime: Date | undefined, dbLocation?: DBLocation) {
    let chain = getHasura();
    return chain.mutation({
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


function deleteStay(eventId: number) {
    let chain = getHasura();
    return chain.mutation({
        delete_events_by_pk: [{
            id: eventId
        }, {
            id: true
        }]
    })
}

async function getClosestUserLocation(userId: number, currentLocation: Location, radius: number = 100): Promise<DBLocation[]> {
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

async function getLastEvents(userId: number, event_type: string, limit: number) {
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