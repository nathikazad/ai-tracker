//
//  ActionController.swift
//  History
//
//  Created by Nathik Azad on 7/25/24.
//

import Foundation

class ActionController {
    static func createActionModel(model: ActionModel) async -> Int? {
        var hasuraStruct: HasuraMutation = HasuraMutation(
            mutationFor: "insert_v2_actions_one",
            mutationName: "ActionModelMutation",
            mutationType: .create)
        hasuraStruct.addParameter(name: "user_id", type: .int, value: Authentication.shared.userId!)
        hasuraStruct.addParameter(name: "action_type_id", type: .int, value: model.actionTypeId)
        hasuraStruct.addParameter(name: "start_time", type: .timestamp, value: model.startTime)
        hasuraStruct.addParameter(name: "end_time", type: .timestamp, value: model.endTime)
        hasuraStruct.addParameter(name: "parent_id", type: .int, value: model.parentId)
        hasuraStruct.addParameter(name: "dynamic_data", type: .jsonb, value: model.dynamicData.toJson())
        
        let (graphqlQuery, variables) = hasuraStruct.getMutationAndVariables
        struct CreateActionResponse: GraphQLData {
            var insert_v2_actions_one: CreatedObject
            struct CreatedObject: Decodable {
                var id: Int
            }
        }
        
        do {
            let responseData: GraphQLResponse<CreateActionResponse> = try await Hasura.shared.sendGraphQL(query: graphqlQuery, variables: variables, responseType: GraphQLResponse<CreateActionResponse>.self)
            return responseData.data.insert_v2_actions_one.id
        } catch {
            print(error)
            print("Failed to create action: \(error.localizedDescription)")
            return nil
        }
    }
    
    static func updateActionModel(model: ActionModel) async {
        guard let id = model.id else {
            print("Cannot update action without an id")
            return
        }
        
        var hasuraMutation: HasuraMutation = HasuraMutation(
            mutationFor: "update_v2_actions_by_pk",
            mutationName: "UpdateActionModelMutation",
            mutationType: .update,
            id: id
        )
        
        hasuraMutation.addParameter(name: "action_type_id", type: .int, value: model.actionTypeId)
        hasuraMutation.addParameter(name: "start_time", type: .timestamp, value: model.startTime)
        hasuraMutation.addParameter(name: "end_time", type: .timestamp, value: model.endTime)
        hasuraMutation.addParameter(name: "parent_id", type: .int, value: model.parentId)
        hasuraMutation.addParameter(name: "dynamic_data", type: .jsonb, value: model.dynamicData.toJson())
        
        let (graphqlQuery, variables) = hasuraMutation.getMutationAndVariables
        struct UpdateActionResponse: GraphQLData {
            var update_v2_actions_by_pk: UpdatedObject
            struct UpdatedObject: Decodable {
                var id: Int
            }
        }
        
        do {
            let _: GraphQLResponse<UpdateActionResponse> = try await Hasura.shared.sendGraphQL(
                query: graphqlQuery,
                variables: variables,
                responseType: GraphQLResponse<UpdateActionResponse>.self
            )
        } catch {
            print(error)
            print("Failed to update action: \(error.localizedDescription)")
        }
    }
    
    static func deleteActionModel(id: Int) async {
        let hasuraMutation: HasuraMutation = HasuraMutation(
            mutationFor: "delete_v2_actions_by_pk",
            mutationName: "DeleteActionModelMutation",
            mutationType: .delete,
            id: id
        )
        
        let (graphqlQuery, variables) = hasuraMutation.getMutationAndVariables
        
        struct DeleteActionResponse: GraphQLData {
            var delete_v2_actions_by_pk: DeletedObject
            struct DeletedObject: Decodable {
                var id: Int
            }
        }
        
        do {
            let _: GraphQLResponse<DeleteActionResponse> = try await Hasura.shared.sendGraphQL(
                query: graphqlQuery,
                variables: variables,
                responseType: GraphQLResponse<DeleteActionResponse>.self
            )
        } catch {
            print("Failed to delete action: \(error.localizedDescription)")
        }
    }
    
    static func fetchActions(userId: Int, actionId: Int? = nil, actionTypeId: Int? = nil) async -> [ActionModel] {
        let (graphqlQuery, variables) = generateQueryForActions(userId: userId, actionId: actionId, actionTypeId: actionTypeId)
        struct ActionData: GraphQLData {
            var v2_actions: [ActionForHasura]
        }
        do {
            let responseData: GraphQLResponse<ActionData> = try await Hasura.shared.sendGraphQL(query: graphqlQuery, variables: variables, responseType: GraphQLResponse<ActionData>.self)
            return responseData.data.v2_actions.map { $0.toActionModel() }
        } catch {
            print(error)
            print("Failed to fetch actions: \(error.localizedDescription)")
            return []
        }
    }
    
    static private func generateQueryForActions(userId: Int, actionId: Int?, actionTypeId: Int? = nil) -> (String, [String: Any]) {
        var hasuraStruct: HasuraQuery = HasuraQuery(queryFor: "v2_actions", queryName: "ActionsQuery", queryType: .query)
        hasuraStruct.addParameter(name: "user_id", type: .int, value: userId, op: .equals)
        if let actionId = actionId {
            hasuraStruct.addParameter(name: "id", type: .int, value: actionId, op: .equals)
        }
        if let actionTypeId = actionTypeId {
            hasuraStruct.addParameter(name: "action_type_id", type: .int, value: actionTypeId, op: .equals)
        }
        hasuraStruct.setSelections(selections: actionSelections)
        return hasuraStruct.getQueryAndVariables
    }
    
    static private var actionSelections: String {
        return """
            id
            created_at
            updated_at
            user_id
            action_type_id
            start_time
            end_time
            parent_id
            dynamic_data
            action_type {
                \(ActionTypesController.actionTypeSelections)
            }
        """
    }
}
