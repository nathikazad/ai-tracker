import { updateMovements } from "./helper/location2";
import { Category, Interaction, interactionToEvent } from "./resources/logic/eventLogic";
import { getUserTimeZone } from "./resources/user";
import { getInteractions, writeDescriptionToDb } from "./resources/events/eventLogicDb";
import { toPST } from "./helper/time";



async function convertInteractions() {
    let userId = 1
    // await updateMovements(userId)
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
        // await interactionToEvent(i)
        console.log('-------------------')  
        console.log('-------------------')  
        console.log('-------------------')  
    }
}

convertInteractions()


