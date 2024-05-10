import { getHasura } from "../config";

export async function getUserLanguage(userId: number) : Promise<string> {
    let chain = getHasura();
    let resp = await chain.query({
        users_by_pk: [{
            id: userId
        }, {
            id: true,
            name: true,
            language: true
        }]
    });
    return resp.users_by_pk!.language
}

export async function getUserTimeZone(userId: number) : Promise<string> {
    let chain = getHasura();
    let resp = await chain.query({
        users_by_pk: [{
            id: userId
        }, {
            id: true,
            name: true,
            timezone: true
        }]
    });
    return resp.users_by_pk!.timezone!
}

export async function updateUserFields(user: { id: number; name: string; language: string; }, username: string | null, language: string | null) {
    let chain = getHasura();
    if (user.name != username || user.language != language) {
        chain.mutation({
            update_users_by_pk: [
                {
                    pk_columns: {
                        id: user.id
                    },
                    _set: {
                        name: username ?? user.name,
                        language: language ?? user.language
                    }
                }, {
                    id: true
                },
            ]
        });
    }
}
