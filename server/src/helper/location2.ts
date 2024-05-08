// Import necessary libraries
import * as geolib from 'geolib';
import * as polyline from '@mapbox/polyline';
import { getHasura } from '../config';
import { GraphQLError, $, order_by } from '../generated/graphql-zeus';
import { toPST } from './time';
import { stat } from 'fs';

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

export async function addLocation(userId: number, location: Location) {
    // make time equal start of day
    let timestamp = getStartOfDay(location.timestamp);
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
            location: convertLocationToJSON(location)
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
            updateLocation(resp.user_movements[0].id, location);
        } else {
            throw error;
        }

    }

    async function updateLocation(movementId: number, location: Location) {
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
            location: convertLocationToJSON(location)
        })

        console.log(resp);
    }

    function convertLocationToJSON(location: Location) {
        return {
            [location.timestamp]: {
                lat: location.lat,
                lon: location.lon,
                timestamp: location.timestamp,
                accuracy: location.accuracy
            }
        }
    }
}


function getStartOfDay(timestamp: string): string {
    let date = new Date(timestamp);
    date.setUTCHours(0, 0, 0, 0);
    return date.toISOString();
}

function addHours(date: Date, hours: number): Date {
    return new Date(date.getTime() + hours * 60 * 60 * 1000)
}

export async function updateMovements(userId: number) {
    console.log(`start of day ${getStartOfDay(new Date().toISOString())}`)
    let client = getHasura();
    let resp = await client.query({
        user_movements: [
            {
                where: {
                    user_id: {
                        _eq: userId
                    },
                    // date: {
                    //     _eq: getStartOfDay(new Date().toISOString())
                    // }
                }
            },
            {
                id: true,
                moves: [{}, true]
            }
        ]
    });
    
    console.log(resp);
    // make a single array of all locations by combining all moves
    let moves: { [key: string]: Location } = {};
    for (let key in resp.user_movements) {
        moves = {
            ...moves,
            ...resp.user_movements[key].moves
        }
    }
    let locations: Location[] = []
    for (let key in moves) {
        locations.push({
            lat: moves[key].lat,
            lon: moves[key].lon,
            timestamp: moves[key].timestamp,
            accuracy: moves[key].accuracy
        });
    }
    let stationaryPeriods = findStationaryPeriods(locations, 3, 20, 60, 60 * 1000)
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
    let closestLocations = await getClosestUserLocation(userId, {
        lat: stationaryPeriods[0].latitude,
        lon: stationaryPeriods[0].longitude,
        timestamp: stationaryPeriods[0].startTime
    }, maxDistance * 5);
    // console.log(closestLocations)
    // find the closest point for each stationary point
    for (let stationaryPeriod of stationaryPeriods) {
        let minDistance = 1000000000
        for (let location of closestLocations) {
            let distance = geolib.getDistance({ latitude: stationaryPeriod.latitude, longitude: stationaryPeriod.longitude }, { latitude: location.location.coordinates[1], longitude: location.location.coordinates[0] })
            if(distance < minDistance) {
                minDistance = distance
                stationaryPeriod.closestLocation = location
            }
        }
    }
    // print closest location for each point and the distance
    for(let stationaryPeriod of stationaryPeriods) {
        let distance = geolib.getDistance({ latitude: stationaryPeriod.latitude, longitude: stationaryPeriod.longitude }, { latitude: stationaryPeriod.closestLocation!.location.coordinates[1], longitude: stationaryPeriod.closestLocation!.location.coordinates[0] })
        console.log(`Stationary: ${toPST(stationaryPeriod.startTime)} - ${toPST(stationaryPeriod.endTime)} ${stationaryPeriod.closestLocation?.name} ${distance}`)
    }
    // hash start and end timestamp into a single string
    let startDate = new Date();
    startDate = addHours(startDate, -48)
    let events = await getLastEvents(userId, "stay", startDate)

    console.log(stationaryPeriods.length)
    let periodsAlreadyWritten: StationaryPeriod[] = []
    for(let event of events) {
        console.log(`event ${event.id} ${event.start_time}`)
        for(let stationaryPeriod of stationaryPeriods) {
            let t1 = new Date(event.start_time+'Z').getTime()
            let t2 = new Date(stationaryPeriod.startTime).getTime()
            if( Math.abs(t1 - t2) < 1000) {
                console.log(`hit $${event.id} ${event.start_time+'Z'} ${stationaryPeriod.startTime} ${Math.abs(t1 - t2)}`)
                periodsAlreadyWritten.push(stationaryPeriod)
            }
        }
        for(let period of periodsAlreadyWritten) {
            stationaryPeriods = stationaryPeriods.filter(p => p.startTime !== period.startTime)
        }
    }
    console.log(stationaryPeriods.length)
    // insert into database
    for(let period of stationaryPeriods) {
        console.log(period.startTime)
        // await insertStay(userId, new Date(period.startTime), new Date(period.endTime), period.closestLocation)
    }
    // console.log(JSON.stringify(stay, null, 4))
    // fetch last event
    // skip all stationary that have same time before last event
    // insert or update stay event
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

}

function findStationaryPeriods(data: Location[], windowSize: number, thresholdDistance: number, thresholdTime: number, minDuration: number): StationaryPeriod[] {
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
            if(velocity[i] > 0.5) {
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
    console.log(stationaryPeriods.length)
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
    console.log(`change ${stationaryPeriods.length} -> ${mergedPoints.length}`)
    // mergedPoints = stationaryPeriods
    for(let i = 0; i < mergedPoints.length; i++) {
        console.log(`${i} ${toPST(mergedPoints[i].startTime)} - ${toPST(mergedPoints[i].endTime)} ${mergedPoints[i].duration} ${mergedPoints[i].polyline} ||  ${mergedPoints[i].fullPolyline} ${mergedPoints[i].range}`)
    }
    // console.log(velocity)
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

async function getLastEvents(userId: number, event_type: string, date: Date) {
    let lastEvents = await getHasura().query({
        events: [{
            order_by: [{
                start_time: order_by.asc
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
                        _gt: date.toISOString()
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
    for(let event of lastEvents.events) {
        console.log(`event ${event.id} ${event.start_time}`)
    }
    return lastEvents.events
}