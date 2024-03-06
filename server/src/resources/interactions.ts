import { getHasura } from "../config";
import { $ } from "../generated/graphql-zeus";
import { createEmbedding } from "../third/openai";


export async function insertInteraction(user_id: number, content: string) {
    const embedding = await createEmbedding(content)
    let chain = getHasura();
    let resp = await chain.mutation({
        insert_interactions_one: [{
            object: {
                content: content,
                embedding: $`embedding`,
                user_id: user_id,
                content_type: "query"
            }
        }, {
            id: true
        }]
    }, {
        "embedding": JSON.stringify(embedding)
    })
    return resp.insert_interactions_one?.id;
}

export async function getMatchingInteractions(user_id: number, content: string): Promise<{ id: number; content: string; }[]> {
    const embedding = await createEmbedding(content)
    const chain = getHasura();
    const resp = await chain.query({
        match_interactions: [{
            args: {
                target_user_id: user_id,
                match_threshold: 0.8,
                query_embedding: $`embedding`,
            }
        }, {
            id: true,
            content: true
        }]
    }, {
        "embedding": JSON.stringify(embedding)
    })
    return resp.match_interactions
}