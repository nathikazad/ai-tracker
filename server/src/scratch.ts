import { saveLocation, updateMovements } from "./resources/location/location2";
import { Category, Interaction, interactionToEvent } from "./resources/logic/eventLogic";
import { getUserTimeZone } from "./resources/user";
import { getInteractions, writeDescriptionToDb } from "./resources/events/eventLogicDb";
import { toPST } from "./helper/time";
import { parseUserRequest } from "./resources/logic";
import { getHasura } from "./config";
import { $ } from "./generated/graphql-zeus";



async function main() {
    saveLocation(1, {
        lat: 40.75880364453059,
        lon: -73.99375170128275
    }, "NY Pod")
}
main()

async function testLocationUpdater() {
    await updateMovements(1)
}
// testLocationUpdater()
async function convertInteractions() {
    let userId = 1
    let interactions = (await getInteractions(userId, "2024-05-06")).slice(0, 5)
    console.log(`Interactions: ${interactions.length}`)
    let timezone = await getUserTimeZone(userId)
    for (let interaction of interactions) {
        let i:Interaction = {
            id: interaction.id,
            userId,
            statement: interaction.content,
            recordedAt: interaction.timestamp, 
            timezone,
        }
        console.log(`Interaction(${i.id}) at  ${toPST(i.recordedAt)}: \n ${JSON.stringify(i, null, 4)}`)
        await interactionToEvent(i)
        console.log('-------------------')  
        console.log('-------------------')  
        console.log('-------------------')  
    }
}

// convertInteractions()


