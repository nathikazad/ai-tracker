// import { parseGoal } from "./resources/logic/goalLogic";

import { secondsToMMSS } from "./helper/location";



// import { StopMovementRequest, processMovement } from "./helper/location"

// parseGoal("Drink 1.5 liters of water everyday", 3)
// parseGoal("Practice french everyday for 30 minutes", 3)
// parseGoal("Wake up at 6:30 am everyday", 3)


async function main() {
//     let stopMovementRequest: StopMovementRequest = {
//         eventType: 'stoppedMoving',
//         numberOfPoints: 1,
//         timeSinceLastMovement: 10.063171029090881,
//         locations: [ {
//             lat: 37.792811065941684,
//             lon: -122.40529245967804,
//             accuracy: 10,
//             timestamp: '2024-04-18T18:23:45.840Z'
//         }]
//     }
//     await processMovement(1, stopMovementRequest)
    // await setNameForLocation(1,-122.0312186,
    //     37.33233141, "Apple")
    // console.log(locs)
    let end = new Date(Date.parse("2024-04-24T05:15:52")).getTime() 
    let start = new Date(Date.parse("2024-04-24T05:06:59")).getTime()
    console.log(end - start);
    let timeDiff = secondsToMMSS((end - start)/1000)
    console.log(timeDiff)
}
main()

