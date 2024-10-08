//
//  SquadMessagesC.swift
//  History
//
//  Created by Nathik Azad on 8/19/24.
//

import Foundation
class SquadMessagesController {
    static func sendMessage(groupId: Int, memberId: Int, payload: [String: Any]) async -> Bool {
        var hasuraStruct: HasuraMutation = HasuraMutation(
            mutationFor: "insert_group_messages_one",
            mutationName: "AddMessageMutation",
            mutationType: .create)
        hasuraStruct.addParameter(name: "chat_id", type: .int, value: groupId)
        hasuraStruct.addParameter(name: "member_id", type: .int, value: memberId)
        hasuraStruct.addParameter(name: "payload", type: .jsonb, value: payload)
        
        
        let (graphqlQuery, variables) = hasuraStruct.getMutationAndVariables
        struct AddedMessageResponse: GraphQLData {
            var insert_group_messages_one: AddedMessage
            struct AddedMessage: Decodable {
                var id: Int
            }
        }
        
        do {
            let _: GraphQLResponse<AddedMessageResponse> = try await Hasura.shared.sendGraphQL(
                query: graphqlQuery,
                variables: variables,
                responseType: GraphQLResponse<AddedMessageResponse>.self
            )
            return true
        } catch {
            print("Failed to add member to group: \(error.localizedDescription)")
            return false
        }
    }
    
    static func listenToMessages(subscriptionId: String, squadId: Int, messagesReceivedCallback: @escaping ([MessageModel]) -> Void) {
        Hasura.shared.stopListening(subscriptionId: subscriptionId)
        let (subscriptionQuery, variables) = generateQueryForMessages(squadId: squadId, onlyNew: true, isSubscription: true)
        struct GroupData: GraphQLData {
            var group_messages: [MessageModel]
        }
        
        Hasura.shared.startListening(subscriptionId: subscriptionId, subscriptionQuery: subscriptionQuery, responseType: GraphQLResponse<GroupData>.self, variables: variables) { result in
            switch result {
            case .success(let responseData):
                let messages = responseData.data.group_messages
                messagesReceivedCallback(messages)
            case .failure(let error):
                print("Error processing Group update: \(error.localizedDescription)")
            }
        }
    }
    
    static func fetchMesssages(squadId: Int, offset: Int) async -> [MessageModel] {
        var (graphqlQuery, variables) = generateQueryForMessages(squadId: squadId)
        
        // hack
        graphqlQuery = graphqlQuery.replacingOccurrences(of: "$chat_id}})", with: "$chat_id}}, order_by: {time: desc}, offset: \(offset), limit: 5)")
        
        struct GroupData: GraphQLData {
            var group_messages: [MessageModel]
        }
        do {
            let responseData: GraphQLResponse<GroupData> = try await Hasura.shared.sendGraphQL(query: graphqlQuery, variables: variables, responseType: GraphQLResponse<GroupData>.self)
            return responseData.data.group_messages
        } catch {
            print(graphqlQuery, variables)
            print("Failed to fetch Squad: \(error.localizedDescription)")
            return []
        }
    }
    
    static private func generateQueryForMessages(squadId: Int, onlyNew: Bool = false, isSubscription: Bool = false) -> (String, [String: Any]) {
        var hasuraStruct: HasuraQuery = HasuraQuery(queryFor: "group_messages", queryName: "GroupsQuery", queryType: isSubscription ? .subscription : .query)
        hasuraStruct.addWhereClause(name: "chat_id", type: .int, value: squadId, op: .equals)
        if onlyNew {
            hasuraStruct.addWhereClause(name: "time", type: .timestamp, value: Date().toUTCString, op: .greaterThan)
        }
        hasuraStruct.setSelections(selections: messageSelection)
        var (query, variables) = hasuraStruct.getQueryAndVariables
        return (query, variables)
    }
    
    static var messageSelection: String {
        """
        payload
        member_id
        id
        time
        """
    }
}
