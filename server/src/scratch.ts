import { getHasura } from "./config"
import { toPST } from "./helper/time";
import { breakdown, createEmbeddings, extractCategories, extractEvents } from "./resources/logic/eventLogic";



async function main() {
    await createEmbeddings();
    let interactions = await getInteractions()
    let i = 0

    // await breakdown("All the tests are passing consistently. Tomorrow, have to ingest the data. 10:58 pm")
    for (let interaction of interactions.slice(12)) {
    //     console.log(interactions.indexOf(interaction), interaction.content, extractTime(interaction.timestamp))
        let i = {
            statement: interaction.content,
            recordedAt: extractTime(interaction.timestamp)!
        }
        console.log(`Input: \n${JSON.stringify(i, null, 4)}`);
        
        let event = await extractEvents(i)
        
        // let events = await breakdown(interaction.content)
        // let categories = await extractCategories(interaction.content)
        console.log(`Output: \n ${JSON.stringify(event, null, 4)}`)
        console.log('-------------------')  
    }

    let events 
    // events = await breakdown("I just aimlessly browsed the internet for the last hour")
    // console.log(events)
    // events = await breakdown("I started cooking")
    // console.log(events)
    // events = await breakdown("I finished cooking")
    // console.log(events)
    // events = await breakdown("I am going to sleep now")
    // console.log(events)
    // events = await breakdown("I just got back from dancing")
    // console.log(events)
    // events = await breakdown("I just woke up at 8 a.m. and I am going to make breakfast")
    // console.log(events)
    // events = await breakdown("I just woke up at 8 a.m. I don't feel so great")
    // console.log(events)
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

