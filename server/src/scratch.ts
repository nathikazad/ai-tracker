import { updateMovements } from "./resources/location/location2";
import { Category, Interaction, interactionToEvent } from "./resources/logic/eventLogic";
import { getUserTimeZone } from "./resources/user";
import { getInteractions, writeDescriptionToDb } from "./resources/events/eventLogicDb";
import { toPST } from "./helper/time";
import { getHasura } from "./config";
import { $ } from "./generated/graphql-zeus";
import { ASLocation, DBLocation, convertPostGISPointToASLocation, convertToDBLocation, getDistance } from "./resources/location/locationUtility";
import { get } from "http";
import { associateEventWithLocation } from "./resources/associations/associationsDb";



async function main() {
    let currentLocation: ASLocation = {
        lat: 37.79849171174564,
        lon: -122.40915880094475
    }
    let resp = await getHasura().query({
        // users_by_pk: [{
        //     id: 1
        // }, {
        //     closest_user_location: [{
        //         args: {
        //             radius: 500,
        //             ref_point: `SRID=4326;POINT(${currentLocation.lon} ${currentLocation.lat})`
        //         }
        //     }, {
        //         id: true,
        //         location: true,
        //         name: true
        //     }]
        // }],
        events: [{
            where: {
                event_type: {
                    _eq: "stay"
                },
                user_id: {
                    _eq: 1
                },
                // metadata: {
                //     _contains: $`metadata`
                // }
            },
            // limit: 2
        }, {
            id: true,
            metadata: [{}, true],
            locations: [
                {}, 
                {
                    id: true,
                    location: true,
                    name: true
                }
            ]
        }]
    }, 
    )

    // All the closes locations
    // console.log(`Locations: ${resp?.users_by_pk?.closest_user_location?.length}`)
    // let locations: DBLocation[] = []
    // resp?.users_by_pk?.closest_user_location?.forEach((location) => {
    //     let dbLocation = convertToDBLocation(location)
    //     let aslocation = convertPostGISPointToASLocation(dbLocation.location)
    //     let distance = getDistance(currentLocation, aslocation)
    //     // console.log(`Location(${location.id}) ${location.name} at ${aslocation.lat}, ${aslocation.lon} is ${distance} meters away`)
    //     locations.push({
    //         name: location.name,
    //         id: location.id,
    //         location: dbLocation.location
    //     })
    // })
    console.log(`Events: ${resp.events.length}`)
    for (let event of resp.events) {
        let metadata = event.metadata
        let locationAlreadyExists = (event.locations?.length ?? 0) > 0
        if(metadata?.location?.id && !locationAlreadyExists) {
            // let eventLocation = convertPostGISPointToASLocation(metadata.location.location)
            // let closestLocationFromLocations = getClosestLocation(locations, eventLocation)
            console.log(`Event(${event.id}) has location id ${metadata.location.id} and name ${metadata.location.name} and location ${event.locations?.length}`)
            await associateEventWithLocation(event.id, metadata!.location!.id);
        }
        //  else {
        //     console.log(event.id, metadata)
        //     console.log(`Event(${event.id}) has no location`)
        // }
    }

    function getClosestLocation(locations: DBLocation[], eventLocation: ASLocation): DBLocation {
        let closestLocation: DBLocation = locations[0]
        let closestDistance = getDistance(eventLocation, convertPostGISPointToASLocation(closestLocation.location))
        for (let location of locations) {
            let distance = getDistance(eventLocation, convertPostGISPointToASLocation(location.location))
            if (distance < closestDistance) {
                closestDistance = distance
                closestLocation = location
            }
        }
        return closestLocation
    }
}
main()

// async function testLocationUpdater() {
//     await updateMovements(1)
// }
// testLocationUpdater()
// async function convertInteractions() {
//     let userId = 1
//     let interactions = (await getInteractions(userId, "2024-05-06")).slice(0, 5)
//     console.log(`Interactions: ${interactions.length}`)
//     let timezone = await getUserTimeZone(userId)
//     for (let interaction of interactions) {
//         let i:Interaction = {
//             id: interaction.id,
//             userId,
//             statement: interaction.content,
//             recordedAt: interaction.timestamp, 
//             timezone,
//         }
//         console.log(`Interaction(${i.id}) at  ${toPST(i.recordedAt)}: \n ${JSON.stringify(i, null, 4)}`)
//         await interactionToEvent(i)
//         console.log('-------------------')  
//         console.log('-------------------')  
//         console.log('-------------------')  
//     }
// }

// convertInteractions()


