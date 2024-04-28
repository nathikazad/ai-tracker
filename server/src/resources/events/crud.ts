import { config, getFullHasuraUrl, getHasura } from "../../config";
import { order_by } from "../../generated/graphql-zeus";


export async function getEvents({ user_id, limit = 10 }: { user_id: number; limit?: number; }) {
    const chain = getHasura();
    const resp = await chain.query({
        events: [{
            limit: limit,
            order_by: [{
                id: order_by.desc
            }],
            where: {
                user_id: {
                    _eq: user_id
                }
            }
        }, {
            status: true,
            start_time: true,
            metadata: [{}, true],
            id: true,
            end_time: true,
            event_type: true,
            event_type_object: {
                parent_tree: true
            }
        }]
    })
    return resp.events;
}

export async function deleteEvent(id: number) {
    const chain = getHasura();
    await chain.mutation({
        delete_events_by_pk: [{
            id: id

        }, {
            id: true
        }]
    })
    return "success"
}

export async function mutateEvents(mutation: string) {
    const fetchFunction = require('node-fetch');
    const requestOptions = {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'x-hasura-admin-secret': config.hasuraAdminSecret, // Use x-hasura-admin-secret for authentication
        },
        body: JSON.stringify({
            query: mutation,
        }),
    };


    fetchFunction(getFullHasuraUrl(), requestOptions)
        .then((response: { json: () => any; }) => response.json())
        .then((data: any) => console.log(data))
        .catch((error: any) => console.error('Error:', error));
}

