import * as geolib from 'geolib';
export interface ASLocation {
    lat: number;
    lon: number;
}

export interface DeviceLocation extends ASLocation {
    accuracy?: number;
    timestamp: string;
}

export interface PostGISPoint {
    type: "Point";
    coordinates: number[];
}

export interface DBLocation {
    id?: number,
    location: PostGISPoint
    name?: string
}

export interface StationaryPeriod {
    startTime: string;
    endTime: string;
    duration: number;
    location: ASLocation;
    points: DeviceLocation[];
    polyline: string;
    fullPolyline: string;
    range: string;
    closestLocation?: DBLocation;
    closestDistance?: number;
}

export function getEventLocation(event: any): ASLocation {
    const eventLocationPostGIS: PostGISPoint = event.metadata!.location!.location
    return convertPostGISPointToASLocation(eventLocationPostGIS)
}

export function convertASLocationToPostGISPoint(location: ASLocation): PostGISPoint {
    return {
        type: "Point",
        coordinates: [location.lon, location.lat]
    }
}

export function convertPostGISPointToASLocation(location: PostGISPoint): ASLocation {
    // console.log(location)
    return {
        lat: location.coordinates[1],
        lon: location.coordinates[0],
    }
}

export function convertToDBLocation(location: any): DBLocation {
    // console.log(location)
    return {
        name: location.name ?? "Unknown",
        location: location.location,
        id: location.id
    }
}

export function getDistance(i: ASLocation, j: ASLocation) {
    return geolib.getDistance({ latitude: i.lat, longitude: i.lon }, { latitude: j.lat, longitude: j.lon })
}



export function getDuration(startPoint: DeviceLocation, endPoint: DeviceLocation) {
    return (new Date(endPoint.timestamp).getTime() - new Date(startPoint.timestamp).getTime()) / 1000;
}

export function getAverageLocation(points: DeviceLocation[]): ASLocation {
    // log(points)
    const sumLatitude = points.reduce((acc, curr) => acc + curr.lat, 0);
    const sumLongitude = points.reduce((acc, curr) => acc + curr.lon, 0);
    return {
        // timestamp: points[0].timestamp,
        lat: sumLatitude / points.length,
        lon: sumLongitude / points.length,
    };
}
