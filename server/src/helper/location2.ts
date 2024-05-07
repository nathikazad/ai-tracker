// Import necessary libraries
import * as geolib from 'geolib';
import { Location } from './location';
import { toPST } from './time';
import { get } from 'http';
import { getHasura } from '../config';
import { GraphQLError, $ } from '../generated/graphql-zeus';
import { time } from 'console';


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

interface Cluster {
    points: Location[];
    centroidLat: number;
    centroidLong: number;
    startTime: string;
    endTime: string;
}

export async function updateMovements(userId: number) {
    let client = getHasura();
    let resp = await client.query({
        user_movements: [
            {
                where: {
                    user_id: {
                        _eq: userId
                    },
                    date: {
                        _eq: getStartOfDay(new Date().toISOString())
                    }
                }
            },
            {
                id: true,
                moves: [{}, true]
            }
        ]
    });
    let locations: Location[] = []
    let moves = resp.user_movements[0].moves as any;
    


    for (let key in moves) {
        locations.push({
            lat: moves[key].lat,
            lon: moves[key].lon,
            timestamp: moves[key].timestamp,
            accuracy: moves[key].accuracy
        });
    }
    let centroids = calculateCentroids(locations, 100);
    console.log(centroids);
}

export function calculateCentroids(data: Location[], minDistance: number): Cluster[] {
    let clusters: Cluster[] = [];

    for (const point of data) {
        let added = false;

        for (const cluster of clusters) {
            const distance = geolib.getDistance(
                { latitude: cluster.centroidLat, longitude: cluster.centroidLong },
                { latitude: point.lat, longitude: point.lon }
            );

            if (distance < minDistance) {
                cluster.points.push(point);
                const centroid = geolib.getCenter(cluster.points.map(p => ({ latitude: p.lat, longitude: p.lon })));
                if (centroid) {
                    cluster.centroidLat = centroid.latitude;
                    cluster.centroidLong = centroid.longitude;
                    // convert iso time to seconds since epoch
                    // get minimum and maximum time
                    cluster.startTime = new Date(Math.min.apply(null, cluster.points.map(p => new Date(p.timestamp).getTime()))).toISOString();
                    cluster.endTime = new Date(Math.max.apply(null, cluster.points.map(p => new Date(p.timestamp).getTime()))).toISOString();
                    added = true;
                    break;
                }
            }
        }

        if (!added) {
            clusters.push({
                points: [point],
                centroidLat: point.lat,
                centroidLong: point.lon,
                startTime: point.timestamp,
                endTime: point.timestamp
            });
        }
    }

    return clusters;
}