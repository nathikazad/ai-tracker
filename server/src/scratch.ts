import { saveLocation, updateMovements } from "./resources/location/location2";
import { Category, Interaction, interactionToEvent } from "./resources/logic/eventLogic";
import { getUserTimeZone } from "./resources/user";
import { getInteractions, writeDescriptionToDb } from "./resources/events/eventLogicDb";
import { toPST } from "./helper/time";
import { parseUserRequest } from "./resources/logic";
import { getHasura } from "./config";
import { $ } from "./generated/graphql-zeus";



async function main() {
    let resp = await getHasura().query({
        events: [{
            where: {
                event_type: {
                    _eq: "meeting"
                }
            }
        }, {
            id: true,
            metadata: [{}, true]
        }]
    })
    for (let event of resp.events) {
        if(event.metadata.meeting.people.length == 0) {
            continue
        }
        let newPeople = []
        for (let person of event.metadata.meeting.people) {
            let newPerson = {
                name: person
            }
            newPeople.push(newPerson)
        }
        event.metadata.meeting.people = newPeople

        let r = await getHasura().mutation( {
            update_events_by_pk: [{
                pk_columns: {
                    id: event.id
                },
                _append: {
                    metadata: $`metadata`
                }
            }, {
                id: true,
                metadata: [{}, true]
            }]
        }, {
            metadata: event.metadata
        })
        console.log(`Event(${event.id})`)
        console.log(JSON.stringify(event.metadata.meeting.people, null, 4))
        // console.log(JSON.stringify(newPeople, null, 4))
        console.log(JSON.stringify(r.update_events_by_pk?.metadata.meeting.people, null, 4))
    }
    
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


