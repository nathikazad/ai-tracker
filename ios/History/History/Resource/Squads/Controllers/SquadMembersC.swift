//
//  SquadMembersC.swift
//  History
//
//  Created by Nathik Azad on 8/19/24.
//

import Foundation
class SquadMembersController {
    static func addMember(squadId: Int, userId: Int, metadata: [String: AnyCodable]? = nil) async -> Bool {
        var hasuraStruct: HasuraMutation = HasuraMutation(
            mutationFor: "insert_group_members_one",
            mutationName: "AddGroupMemberMutation",
            mutationType: .create)
        hasuraStruct.addParameter(name: "chat_id", type: .int, value: squadId)
        hasuraStruct.addParameter(name: "user_id", type: .int, value: userId)
        if let metadata = metadata {
            hasuraStruct.addParameter(name: "metadata", type: .jsonb, value: metadata.toJson)
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
    
    static func updateMember(id: Int, metadata: [String: AnyCodable]) async {
        var hasuraMutation = HasuraMutation(
            mutationFor: "update_group_members_by_pk",
            mutationName: "UpdateGroupMemberMutation",
            mutationType: .update,
            id: id
        )
        hasuraMutation.addParameter(name: "metadata", type: .jsonb, value: metadata.toJson)
        
        let (graphqlQuery, variables) = hasuraMutation.getMutationAndVariables
        print(graphqlQuery, variables)
        struct UpdateMemberResponse: GraphQLData {
            var update_group_members_by_pk: UpdatedMember
            struct UpdatedMember: Decodable {
                var id: Int
            }
        }
        
        do {
            let _: GraphQLResponse<UpdateMemberResponse> = try await Hasura.shared.sendGraphQL(
                query: graphqlQuery,
                variables: variables,
                responseType: GraphQLResponse<UpdateMemberResponse>.self
            )
        } catch {
            // Log error details for debugging purposes
            print("Failed to update group member: \(error.localizedDescription)")
        }
    }
    
    static func removeMember(id: Int) async -> Bool {
        let hasuraMutation: HasuraMutation = HasuraMutation(
            mutationFor: "delete_group_member_by_pk",
            mutationName: "RemoveGroupMemberMutation",
            mutationType: .delete,
            id: id
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
    
    static func memberSelections() -> String {
        return """
            id
            user {
                id
                name
            }
            metadata
        """
    }
}
