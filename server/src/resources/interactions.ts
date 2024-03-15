import { getHasura } from "../config";
import { $ } from "../generated/graphql-zeus";
import { createEmbedding } from "../third/openai";
import { order_by } from "../generated/graphql-zeus";


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

export async function getInteractions({ user_id, limit = 10, date = new Date().toISOString().split('T')[0] }: { user_id: number; limit?: number; date?: string; }) {
    const chain = getHasura();
    const resp = await chain.query({
        interactions: [{
            limit: limit,
            order_by: [{
                id: order_by.asc
            }],
            where: {
                user_id: {
                    _eq: user_id
                },
                timestamp: {
                    _gte: date,
                    _lt: `${date}T23:59:59Z`
                }
            }
        }, {
            content: true, 
            timestamp: true,
            id: true
        }]
    })
    return resp.interactions;
}

export async function deleteInteraction(id: number) {
    const chain = getHasura();
    await chain.mutation({
        delete_interactions_by_pk: [{
            id: id

        }, {
            id: true
        }]
    })
    return "success"
}
