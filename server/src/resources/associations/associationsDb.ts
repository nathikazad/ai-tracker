import { getHasura } from "../../config";


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