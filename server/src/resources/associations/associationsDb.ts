import { getHasura } from "../../config";
import { associations_set_input } from "../../generated/graphql-zeus";


export async function associateEventWithLocation(userId: number, eventId: number, locationId: number) {
    await getHasura().mutation({
        insert_associations_one: [
            {
                object: {
                    ref_one_id: eventId,
                    ref_one_table: "events",
                    ref_two_id: locationId,
                    ref_two_table: "locations",
                    user_id: userId
                }
            },
            {
                id: true
            }
        ]
    });
}

export async function associateEventAssociationWithLocation(associationId: number, locationId: number) {
    let resp = await getHasura().query({
        associations_by_pk: [
            {
                id: associationId                
            },
            {
                id: true,
                ref_one_id: true,
                ref_one_table: true,
                ref_two_id: true,
                ref_two_table: true,
            }
        ]
    })
    let associationInput: associations_set_input = {}
    if(resp.associations_by_pk?.ref_one_table == "locations" ) {
        associationInput = {
            ref_one_id: locationId
        }
    } else if (resp.associations_by_pk?.ref_one_table == "locations" ) {
        associationInput = {
            ref_two_id: locationId
        }
    }

    await getHasura().mutation({
        update_associations_by_pk: [
            {
                pk_columns: {
                id: associationId
            }, ...associationInput
        },
        {
            id: true
        }
        ]
    });
}