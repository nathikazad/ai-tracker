//
//  SquadMembersC.swift
//  History
//
//  Created by Nathik Azad on 8/19/24.
//

import Foundation
class SquadMemebersController {
    static func addMember(groupId: Int, userId: Int, metadata: [String: Any]? = nil) async -> Bool {
        var hasuraStruct: HasuraMutation = HasuraMutation(
            mutationFor: "insert_group_members_one",
            mutationName: "AddGroupMemberMutation",
            mutationType: .create)
        hasuraStruct.addParameter(name: "chat_id", type: .int, value: groupId)
        hasuraStruct.addParameter(name: "user_id", type: .int, value: userId)
        if let metadata = metadata {
            hasuraStruct.addParameter(name: "metadata", type: .jsonb, value: metadata)
        }
        
        let (graphqlQuery, variables) = hasuraStruct.getMutationAndVariables
        struct AddMemberResponse: GraphQLData {
            var insert_group_members_one: AddedMember
            struct AddedMember: Decodable {
                var id: Int
            }
        }
        
        do {
            let _: GraphQLResponse<AddMemberResponse> = try await Hasura.shared.sendGraphQL(
                query: graphqlQuery,
                variables: variables,
                responseType: GraphQLResponse<AddMemberResponse>.self
            )
            return true
        } catch {
            print("Failed to add member to group: \(error.localizedDescription)")
            return false
        }
    }
    
    static func removeMember(groupId: Int, userId: Int) async -> Bool {
        let hasuraMutation: HasuraMutation = HasuraMutation(
            mutationFor: "delete_group_members",
            mutationName: "RemoveGroupMemberMutation",
            mutationType: .delete
        )
        let (graphqlQuery, variables) = hasuraMutation.getMutationAndVariables
        
        struct RemoveMemberResponse: GraphQLData {
            var delete_group_members: DeletedMembers
            struct DeletedMembers: Decodable {
                var affected_rows: Int
            }
        }
        
        do {
            let response: GraphQLResponse<RemoveMemberResponse> = try await Hasura.shared.sendGraphQL(
                query: graphqlQuery,
                variables: variables,
                responseType: GraphQLResponse<RemoveMemberResponse>.self
            )
            return response.data.delete_group_members.affected_rows > 0
        } catch {
            print("Failed to remove member from group: \(error.localizedDescription)")
            return false
        }
    }
}
