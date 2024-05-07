import { getHasura } from "./config"
import { toPST } from "./helper/time";
import { breakdown, createEmbeddings, extractCategories, extractEvents } from "./resources/logic/eventLogic";



async function main() {
    await createEmbeddings();
    let interactions = await getInteractions()
    let i = 0

    for (let interaction of interactions.slice(17, 18)) {
    // //     console.log(interactions.indexOf(interaction), interaction.content, extractTime(interaction.timestamp))
        let i = {
            statement: "I practiced french for 30 minutes",
            recordedAt: extractTime(interaction.timestamp)!
        }
        console.log(`Input: \n${JSON.stringify(i, null, 4)}`);
        
        let event = await extractEvents(i)
        console.log(`Output: \n ${JSON.stringify(event, null, 4)}`)
        console.log('-------------------')  
    }

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

