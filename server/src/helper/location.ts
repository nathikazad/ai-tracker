import * as polyline from '@mapbox/polyline';
interface Location {
    lat: number;
    lon: number;
}

interface MovementRequest {
    eventName: string;
    locations?: Location[];
}

export function updateMovement(movementRequest:MovementRequest, userId: number) {
    console.log(`Event Received: ${movementRequest.eventName} from User ${userId}`);
    if (movementRequest.locations && movementRequest.locations.length > 0) {
        const encodedPolyline = polyline.encode(movementRequest.locations.map(loc => [loc.lat, loc.lon]));
        console.log(`Encoded Polyline: ${encodedPolyline}`);
    // if (movementRequest.locations) {
    //     const polyline = movementRequest.locations.map(loc => `${loc.lat},${loc.lon}`).join('|');
    //     console.log(`Polyline: ${polyline}`);
    } else {
        console.log('No locations provided or locations array is empty.');
    }
}