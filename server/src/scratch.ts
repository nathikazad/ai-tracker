import { getHasura } from "./config"
import { addLocation, calculateCentroids } from "./helper/location2";
import { toPST } from "./helper/time";
import { breakdown, createEmbeddings, extractCategories, extractEvents } from "./resources/logic/eventLogic";



async function main() {
    // Example usage
// const gpsData: GPSPoint[] = [
//     { lat: 34.0522, long: -118.2437, horizontalAccuracy: 10, timestamp: 1609459200000 },
//     { lat: 34.0525, long: -118.2450, horizontalAccuracy: 10, timestamp: 1609459260000 },
    // Add more data points as needed
    addLocation(1, { lat: 34.0522, lon: -118.2437, timestamp: "2024-05-05T00:00:00Z", accuracy: 10 })

    // await createEmbeddings();
    // let interactions = await getInteractions()
    // let i = 0

    // for (let interaction of interactions.slice(17, 18)) {
    // // //     console.log(interactions.indexOf(interaction), interaction.content, extractTime(interaction.timestamp))
    //     let i = {
    //         statement: "I practiced french for 30 minutes",
    //         recordedAt: extractTime(interaction.timestamp)!
    //     }
    //     console.log(`Input: \n${JSON.stringify(i, null, 4)}`);
        
    //     let event = await extractEvents(i)
    //     console.log(`Output: \n ${JSON.stringify(event, null, 4)}`)
    //     console.log('-------------------')  
    // }

    function extractTime(input: string): string | null {
        input = toPST(input);
        const [date, h, m, s, period] = input.split(/[\s,:]+/);
        return `${h}:${m} ${period.toLowerCase()}`;
    };

    async function getInteractions() {
        let resp = await getHasura().query({
            interactions: [
                {
                    where: {
                        user_id: {
                            _eq: 1
                        },
                        timestamp: {
                            _gte: "2024-05-05",
                        
                        }
                    }
                },
                {
                    content: true,
                    timestamp: true
                }
            ]
        })
        return resp.interactions
    }
}
main()

