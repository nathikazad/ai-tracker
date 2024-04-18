// import * as polyline from '@mapbox/polyline';
// import { insertInteraction } from '../resources/interactions';
// import { getHasura } from '../config';
// import { order_by } from '../generated/graphql-zeus';
// interface Location {
//     lat: number;
//     lon: number;
// }

// interface StopMovementRequest {
//     locations?: Location[];
//     timeStopped?: Date;
//     debugInfo: Record<string, string>
// }

// interface StartMovementRequest {
//     lastStoppedLocation?: Location;
//     timeStarted?: Date;
//     debugInfo: Record<string, string>
// }

// export async function stopMovementEvent(movementRequest: StopMovementRequest, userId: number) {
//     let interaction = "Stopped at unknown location"
//     let stoppedLocation = movementRequest.locations![movementRequest.locations!.length - 1];
//     let timeStopped = movementRequest.timeStopped!;
//     let resp = await getClosestUserLocations(userId, stoppedLocation)
//     if ((resp.users_by_pk?.closest_user_location?.length ?? 0) > 0) {
//         console.log("Closest user location found.")
//         let resp2 = await getStayEvents(userId)
//         if ((resp2.events?.length ?? 0) > 0) {
//             console.log("Stay event found.")
//             let event = resp2.events![0]
//             if (event.metadata?.location_id == resp.users_by_pk!.closest_user_location![0].id) {
//                 console.log("Recent stay event already exists for this location. Not creating a new one.")
//                 return;
//             }
//         } else {
//             console.log("No stay event found for this user. Creating a new one.");
//             insertStay(resp.users_by_pk!.closest_user_location![0].id, userId, timeStopped)
//             // find commute event, update end time and polyline
//             let locationName = resp.users_by_pk!.closest_user_location![0].name
//             interaction = `stopped at ${locationName ? locationName : "unknown location"}`
//         }
//     } else {
//         console.log("No closest user location found.")
//         let locationId = await insertLocation(stoppedLocation)
//         insertStay(locationId, userId, timeStopped)
//         // find commute event, update end time and polyline
//         interaction = "stopped at unknown location"
//     }
//     insertInteraction(userId, interaction, "event", movementRequest.debugInfo)
// }

// // export async function startMovementEvent(movementRequest: StopMovementRequest, userId: number) {
// //         if (movementRequest.locations && movementRequest.locations.length > 0) {
// //             const encodedPolyline = polyline.encode(movementRequest.locations.map(loc => [loc.lat, loc.lon]));
// //             const textPolyline = movementRequest.locations.map(loc => `${loc.lat},${loc.lon}`).join('|');
// //             console.log(`Encoded Polyline: ${encodedPolyline}`);
// //             movementRequest.debugInfo = {
// //                 ...movementRequest.debugInfo,
// //                 locations: textPolyline,
// //                 polyline: encodedPolyline
// //             }
// //         } else {
// //             console.log('No locations provided or locations array is empty.');
// //         }
// //     }
// //     console.log(movementRequest.debugInfo)
// //     insertInteraction(userId, interaction, "event", movementRequest.debugInfo)
// // }


// async function getClosestUserLocations(userId: number, currentLocation: Location) {
//     return await getHasura().query({
//         users_by_pk: [{
//             id: userId
//         }, {
//             closest_user_location: [{
//                 args: {
//                     radius: 200,
//                     ref_point: `POINT(${currentLocation.lat} ${currentLocation.lon})`
//                 }
//             }, {
//                 id: true,
//                 location: true,
//                 name: true
//             }]
//         }]
//     });
// }

// async function getStayEvents(userId: number) {
//     return await getHasura().query({
//         events: [{
//             limit: 1,
//             order_by: [{
//                 end_time: order_by.desc
//             }],
//             where: {
//                 _and: [{
//                     user_id: {
//                         _eq: userId
//                     },
//                     event_type: {
//                         _eq: "stay"
//                     },
//                     end_time: {
//                         _gt: new Date(Date.now() - 8 * 60 * 60 * 1000)
//                     }
//                 }]
//             }
//         }, {
//             id: true,
//             metadata: [{}, true]
//         }]
//     });
// }

// function insertStay(locationId: number, userId: number, start_time: Date) {
//     let chain = getHasura();
//     chain.mutation({
//         insert_events: [{
//             objects: [{
//                 event_type: "stay",
//                 metadata: {
//                     location_id: locationId
//                 },
//                 start_time: start_time,
//                 user_id: userId
//             }]
//         }, {
//             returning: {
//                 id: true
//             }
//         }]
//     })
// }

// function insertCommute(polyline: number, userId: number) {
//     let chain = getHasura();
//     chain.mutation({
//         insert_events: [{
//             objects: [{
//                 event_type: "stay",
//                 metadata: {
//                     polyline: polyline
//                 },
//                 user_id: userId
//             }]
//         }, {
//             returning: {
//                 id: true
//             }
//         }]
//     })
// }

// async function insertLocation(location: Location) {
//     let chain = getHasura();
//     let resp = await chain.mutation({
//         insert_locations: [{
//             objects: [{
//                 location: `POINT(${location.lat} ${location.lon})`
//             }]
//         }, {
//             returning: {
//                 id: true
//             }
//         }]
//     })
//     return resp.insert_locations!.returning![0].id;
// }