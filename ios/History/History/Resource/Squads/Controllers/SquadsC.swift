//
//  SquadsC.swift
//  History
//
//  Created by Nathik Azad on 8/19/24.
//

import Foundation

class SquadController {
    // MARK: - Squad Chat Operations
    
    static func createSquad(name: String, ownerId: Int) async -> Int? {
        var hasuraStruct: HasuraMutation = HasuraMutation(
            mutationFor: "insert_group_chat_one",
            mutationName: "CreateSquadMutation",
            mutationType: .create)
        hasuraStruct.addParameter(name: "name", type: .string, value: name)
        hasuraStruct.addParameter(name: "owner_id", type: .int, value: ownerId)
        
        var (graphqlQuery, variables) = hasuraStruct.getMutationAndVariables
        // hack
        graphqlQuery = graphqlQuery.replacingOccurrences(of:"$owner_id}) {",
                                                         with: "$owner_id, members: {data: {user_id: $owner_id}}}) {")
        struct CreateSquadResponse: GraphQLData {
            var insert_group_chat_one: CreatedSquad
            struct CreatedSquad: Decodable {
                var id: Int
            }
        }
        
        do {
            let responseData: GraphQLResponse<CreateSquadResponse> = try await Hasura.shared.sendGraphQL(query: graphqlQuery, variables: variables, responseType: GraphQLResponse<CreateSquadResponse>.self)
            return responseData.data.insert_group_chat_one.id
        } catch {
            print("Failed to create Squad: \(error.localizedDescription)")
            return nil
        }
    }
    
    static func updateSquad(id: Int, name: String) async {
        var hasuraMutation: HasuraMutation = HasuraMutation(
            mutationFor: "update_group_chat_by_pk",
            mutationName: "UpdateSquadMutation",
            mutationType: .update,
            id: id
        )
        
        hasuraMutation.addParameter(name: "name", type: .string, value: name)
        
        let (graphqlQuery, variables) = hasuraMutation.getMutationAndVariables
        struct UpdateSquadResponse: GraphQLData {
            var update_group_chat_by_pk: UpdatedSquad
            struct UpdatedSquad: Decodable {
                var id: Int
            }
        }
        
        do {
            let _: GraphQLResponse<UpdateSquadResponse> = try await Hasura.shared.sendGraphQL(
                query: graphqlQuery,
                variables: variables,
                responseType: GraphQLResponse<UpdateSquadResponse>.self
            )
        } catch {
            print("Failed to update Squad: \(error.localizedDescription)")
        }
    }
    
    static func deleteSquad(id: Int) async {
        let hasuraMutation: HasuraMutation = HasuraMutation(
            mutationFor: "delete_group_chat_by_pk",
            mutationName: "DeleteSquadMutation",
            mutationType: .delete,
            id: id
        )
        
        let (graphqlQuery, variables) = hasuraMutation.getMutationAndVariables
        
        struct DeleteSquadResponse: GraphQLData {
            var delete_group_chat_by_pk: DeletedSquad
            struct DeletedSquad: Decodable {
                var id: Int
            }
        }
        
        do {
            let _: GraphQLResponse<DeleteSquadResponse> = try await Hasura.shared.sendGraphQL(
                query: graphqlQuery,
                variables: variables,
                responseType: GraphQLResponse<DeleteSquadResponse>.self
            )
        } catch {
            print("Failed to delete Squad: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Fetch and Subscribe Operations
    static func fetchSquads(userId: Int? = nil, squadId: Int? = nil, includeMessages:Bool = false) async -> [SquadModel] {
        let (graphqlQuery, variables) = generateQueryForSquads(userId: userId, squadId: squadId, includeMessages: includeMessages)
        struct SquadData: GraphQLData {
            var group_chat: [SquadModel]
        }
        do {
            let responseData: GraphQLResponse<SquadData> = try await Hasura.shared.sendGraphQL(query: graphqlQuery, variables: variables, responseType: GraphQLResponse<SquadData>.self)
            return responseData.data.group_chat
        } catch {
            print(graphqlQuery, variables)
            print("Failed to fetch Squad: \(error.localizedDescription)")
            return []
        }
    }
    
    static func listenToSquads(subscriptionId: String, userId: Int? = nil, squadId: Int? = nil, squadUpdateCallback: @escaping ([SquadModel]) -> Void) {
        Hasura.shared.stopListening(subscriptionId: subscriptionId)
        let (subscriptionQuery, variables) = generateQueryForSquads(userId: userId, squadId: squadId, isSubscription: true)
        struct SquadData: GraphQLData {
            var group_chat: [SquadModel]
        }
        
        Hasura.shared.startListening(subscriptionId: subscriptionId, subscriptionQuery: subscriptionQuery, responseType: GraphQLResponse<SquadData>.self, variables: variables) { result in
            switch result {
            case .success(let responseData):
                let squads = responseData.data.group_chat
                squadUpdateCallback(squads)
            case .failure(let error):
                print("Error processing Squad update: \(error.localizedDescription)")
            }
        }
    }
    
    static private func generateQueryForSquads(userId: Int?, squadId: Int?, isSubscription: Bool = false, includeMessages:Bool = false) -> (String, [String: Any]) {
        var hasuraStruct: HasuraQuery = HasuraQuery(queryFor: "group_chat", queryName: "SquadsQuery", queryType: isSubscription ? .subscription : .query)
        
        if let userId = userId {
            hasuraStruct.addWhereClause(name: "user_id", type: .int, value: userId, op: .equals)
        }
        if let squadId = squadId {
            hasuraStruct.addWhereClause(name: "id", type: .int, value: squadId, op: .equals)
        }
        hasuraStruct.setSelections(selections: squadSelections(includeMessages: includeMessages))
        var (query, variables) = hasuraStruct.getQueryAndVariables
        if userId != nil {
            // hack
            query = query.replacingOccurrences(of: "user_id: {_eq: $user_id}", with: "members: {user_id: {_eq: $user_id}}")
        }
        return (query, variables)
    }
    
    static func squadSelections(includeMessages:Bool = false) -> String {
        return """
            id
            name
            owner_id
            members {
                id
                user {
                    id
                    name
                }
                metadata
            }
            \(includeMessages ? """
                messages(order_by: {time: desc}, limit: 10) {
                    \(SquadMessagesController.messageSelection)
            }
            """: "")
        """
    }
}
