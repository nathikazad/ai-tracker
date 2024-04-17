import * as polyline from '@mapbox/polyline';
import { insertInteraction } from '../resources/interactions';
interface Location {
    lat: number;
    lon: number;
}

interface MovementRequest {
    eventName: string;
    locations?: Location[];
    debugInfo: Record<string, string>
}

export function updateMovement(movementRequest:MovementRequest, userId: number) {
    console.log(`Event Received: ${movementRequest.eventName} from User ${userId}`);
    if (movementRequest.locations && movementRequest.locations.length > 0) {
        const encodedPolyline = polyline.encode(movementRequest.locations.map(loc => [loc.lat, loc.lon]));
        const textPolyline = movementRequest.locations.map(loc => `${loc.lat},${loc.lon}`).join('|');
        console.log(`Encoded Polyline: ${encodedPolyline}`);
        movementRequest.debugInfo = {
            ...movementRequest.debugInfo,
            locations: textPolyline,
            polyline: encodedPolyline
        }
    } else {
        console.log('No locations provided or locations array is empty.');
    }
    console.log(movementRequest.debugInfo)
    insertInteraction(userId, movementRequest.eventName, "event", movementRequest.debugInfo)
}