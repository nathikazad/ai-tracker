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
        hasuraStruct.addParameter(name: "start_time", type: .timestamp, value: model.startTime.toUTCString)
        if let endTime = model.endTime {
            hasuraStruct.addParameter(name: "end_time", type: .timestamp, value: endTime.toUTCString)
        }
        hasuraStruct.addParameter(name: "parent_id", type: .int, value: model.parentId)
        hasuraStruct.addParameter(name: "timezone", type: .string, value: TimeZone.current.identifier)
        hasuraStruct.addParameter(name: "dynamic_data", type: .jsonb, value: model.dynamicData.toJson)
        
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
        hasuraMutation.addParameter(name: "start_time", type: .timestamp, value: model.startTime.toUTCString)
        if let endTime = model.endTime {
            hasuraMutation.addParameter(name: "end_time", type: .timestamp, value: endTime.toUTCString)
        }
        hasuraMutation.addParameter(name: "parent_id", type: .int, value: model.parentId)
        hasuraMutation.addParameter(name: "dynamic_data", type: .jsonb, value: model.dynamicData.toJson)
        
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
    
    static func fetchActions(
        userId: Int,
        actionId: Int? = nil,
        actionTypeId: Int? = nil,
        startDate: Date? = nil,
        endDate: Date? = nil,
        forDate: Date? = nil,
        withObjectConnections: Bool = false,
        withChildren: Bool = false,
        withParent: Bool = false,
        actionTypeIds: [Int]? = nil) async -> [ActionModel] {
        let (graphqlQuery, variables) = generateQueryForActions(userId: userId, actionId: actionId, actionTypeId: actionTypeId, forDate: forDate, startDate: startDate, endDate: endDate, withObjectConnections: withObjectConnections, withChildren: withChildren, withParent: withParent, actionTypeIds: actionTypeIds)
        struct ActionData: GraphQLData {
            var v2_actions: [ActionModel]
        }
        do {
            let responseData: GraphQLResponse<ActionData> = try await Hasura.shared.sendGraphQL(query: graphqlQuery, variables: variables, responseType: GraphQLResponse<ActionData>.self)
            return responseData.data.v2_actions
        } catch {
            print(error)
            print("Failed to fetch actions: \(error.localizedDescription)")
            return []
        }
    }
    
    static func listenToActions(userId: Int, subscriptionId: String, actionId: Int? = nil, actionTypeId: Int? = nil, forDate: Date? = nil, actionUpdateCallback: @escaping ([ActionModel]) -> Void) {
        Hasura.shared.stopListening(subscriptionId: subscriptionId)
        let (subscriptionQuery, variables) = generateQueryForActions(userId: userId, actionId: actionId, actionTypeId: actionTypeId, isSubscription: true, forDate: forDate)
        struct ActionData: GraphQLData {
            var v2_actions: [ActionModel]
        }
        
        Hasura.shared.startListening(subscriptionId: subscriptionId, subscriptionQuery: subscriptionQuery, responseType: GraphQLResponse<ActionData>.self, variables: variables) { result in
            switch result {
            case .success(let responseData):
                let actions = responseData.data.v2_actions
                actionUpdateCallback(actions)
            case .failure(let error):
                print("Error processing action update: \(error.localizedDescription)")
            }
        }
    }
    
    static private func generateQueryForActions(
        userId: Int,
        actionId: Int?,
        actionTypeId: Int? = nil,
        isSubscription:Bool = false,
        forDate: Date? = nil,
        startDate: Date? = nil,
        endDate: Date? = nil,
        withObjectConnections: Bool = false,
        withChildren: Bool = false,
        withParent: Bool = false,
        actionTypeIds: [Int]? = nil) -> (String, [String: Any]) {
        var hasuraStruct: HasuraQuery = HasuraQuery(queryFor: "v2_actions", queryName: "ActionsQuery", queryType: isSubscription ? .subscription : .query)
        hasuraStruct.addWhereClause(name: "user_id", type: .int, value: userId, op: .equals)
        if let actionId = actionId {
            hasuraStruct.addWhereClause(name: "id", type: .int, value: actionId, op: .equals)
        }
        if let gteDate = forDate {
            let calendar = Calendar.current
            let startOfTodayUTCString = calendar.date(byAdding: .day, value: -1, to: gteDate)!.toUTCString
            let dayAfterUTCString = calendar.date(byAdding: .day, value: +1, to: gteDate)!.toUTCString
            let startTimeConditions = "_and: {start_time: {_gt: $start_time, _lt: $end_time}}"
            let endTimeConditions = "_and: {end_time: {_gt: $start_time, _lt: $end_time}}"
            let combinedConditions = "_or: [{\(startTimeConditions)},{\(endTimeConditions)}]"
            hasuraStruct.addWhereClause(clause: combinedConditions)
            hasuraStruct.addParameter(name: "start_time", type: .timestamp, value: startOfTodayUTCString)
            hasuraStruct.addParameter(name: "end_time", type: .timestamp, value: dayAfterUTCString)
        }
        if let startDate = startDate, let endDate = endDate {
            let startOfStartDateUTCString = startDate.toUTCString
            let endOfEndDateUTCString = endDate.toUTCString
            let startTimeConditions = "_and: {start_time: {_gte: $start_time, _lt: $end_time}}"
            let endTimeConditions = "_and: {end_time: {_gt: $start_time, _lte: $end_time}}"
            let nullEndTimeConditions = "_and: {start_time: {_gte: $start_time}, end_time: {_is_null: true}}"
            let combinedConditions = "_or: [{\(startTimeConditions)},{\(endTimeConditions)},{\(nullEndTimeConditions)}]"
            
            hasuraStruct.addWhereClause(clause: combinedConditions)
            hasuraStruct.addParameter(name: "start_time", type: .timestamp, value: startOfStartDateUTCString)
            hasuraStruct.addParameter(name: "end_time", type: .timestamp, value: endOfEndDateUTCString)
        }
        if let actionTypeId = actionTypeId {
            hasuraStruct.addWhereClause(name: "action_type_id", type: .int, value: actionTypeId, op: .equals)
        }
        if let actionTypeIds = actionTypeIds {
            hasuraStruct.addWhereClause(name: "action_type_id", type: .intArray, value: actionTypeIds, op: .inArray)
        }
        hasuraStruct.setSelections(selections: actionSelections(withObjectConnections: withObjectConnections, withChildren: withChildren, withParent: withParent))
        return hasuraStruct.getQueryAndVariables
    }
    
    static func actionSelections(withObjectConnections: Bool = false, withChildren: Bool = false, withParent: Bool = false) -> String {
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
            timezone
            action_type {
                \(ActionTypesController.actionTypeSelections(withObjectConnections: withObjectConnections))
            }
            \(withObjectConnections ? """
                object_actions {
                    \(ObjectActionController.objectActionSelections())
                }
            """ : "")
            \(withChildren ? """
                children {
                    \(actionSelections())
                }
            """ : "")
            \(withParent ? """
                parent {
                    \(actionSelections())
                }
            """ : "")
        """
    }
}
