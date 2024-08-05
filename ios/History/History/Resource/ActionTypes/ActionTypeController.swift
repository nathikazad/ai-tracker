//
//  ActionController.swift
//  History
//
//  Created by Nathik Azad on 7/22/24.
//

import Foundation

let externalDataTypes: [String] = ["Expense", "Organization", "Item"]

class ActionTypesController {
    static func createActionTypeModel(model: ActionTypeModel) async -> Int? {
        var hasuraStruct:HasuraMutation = HasuraMutation(
            mutationFor: "insert_v2_action_types_one",
            mutationName: "ActionTypeModelMutation",
            mutationType: .create)
        hasuraStruct.addParameter(name: "user_id", type: .int, value: Authentication.shared.userId!)
        hasuraStruct.addParameter(name: "name", type: .string, value: model.name)
        hasuraStruct.addParameter(name: "has_duration", type: .bool, value: model.meta.hasDuration)
        hasuraStruct.addParameter(name: "description", type: .string, value: model.meta.description)
        hasuraStruct.addParameter(name: "metadata", type: .jsonb, value: model.getMetadataJson)
        
        let (graphqlQuery, variables) = hasuraStruct.getMutationAndVariables
        struct CreateActionTypeResponse: GraphQLData {
            var insert_v2_action_types_one: CreatedObject
            struct CreatedObject: Decodable {
                var id: Int
            }
        }
        
        do {
            let responseData: GraphQLResponse<CreateActionTypeResponse> = try await Hasura.shared.sendGraphQL(query: graphqlQuery, variables: variables, responseType: GraphQLResponse<CreateActionTypeResponse>.self)
            return responseData.data.insert_v2_action_types_one.id
        } catch {
            print(graphqlQuery)
            print(variables)
            // Log error details for debugging purposes
            print("Failed to create object: \(error.localizedDescription)")
            return nil
        }
    }
    
    static func updateActionTypeModel(model: ActionTypeModel) async {
        var hasuraMutation: HasuraMutation = HasuraMutation(
            mutationFor: "update_v2_action_types_by_pk",
            mutationName: "UpdateActionTypeModelMutation",
            mutationType: .update,
            id: model.id
        )
        
        hasuraMutation.addParameter(name: "name", type: .string, value: model.name)
        hasuraMutation.addParameter(name: "has_duration", type: .bool, value: model.meta.hasDuration)
        hasuraMutation.addParameter(name: "description", type: .string, value: model.meta.description)
        

        hasuraMutation.addParameter(name: "metadata", type: .jsonb, value: model.getMetadataJson)
        
        let (graphqlQuery, variables) = hasuraMutation.getMutationAndVariables
        struct UpdateActionTypeResponse: GraphQLData {
            var update_v2_action_types_by_pk: UpdatedObject
            struct UpdatedObject: Decodable {
                var id: Int
            }
        }
        
        do {
            let _: GraphQLResponse<UpdateActionTypeResponse> = try await Hasura.shared.sendGraphQL(
                query: graphqlQuery,
                variables: variables,
                responseType: GraphQLResponse<UpdateActionTypeResponse>.self
            )
        } catch {
            print(graphqlQuery)
            print(variables)
            print(error)
            print("Failed to update action type: \(error.localizedDescription)")
        }
    }
    
    static func deleteActionTypeModel(id: Int) async {
        let hasuraMutation: HasuraMutation = HasuraMutation(
            mutationFor: "delete_v2_action_types_by_pk",
            mutationName: "DeleteActionTypeModelMutation",
            mutationType: .delete,
            id: id
        )
        
        let (graphqlQuery, variables) = hasuraMutation.getMutationAndVariables
        
        struct DeleteActionTypeResponse: GraphQLData {
            var delete_v2_action_types_by_pk: DeletedObject
            struct DeletedObject: Decodable {
                var id: Int
            }
        }
        
        do {
            let _: GraphQLResponse<DeleteActionTypeResponse> = try await Hasura.shared.sendGraphQL(
                query: graphqlQuery,
                variables: variables,
                responseType: GraphQLResponse<DeleteActionTypeResponse>.self
            )
        } catch {
            print("Failed to delete action type: \(error.localizedDescription)")
        }
    }
    
    
    static func fetchActionTypes(userId: Int, actionTypeId: Int? = nil) async -> [ActionTypeModel] {
        let (graphqlQuery, variables) = generateQueryForActionTypes(userId: userId, actionTypeId: actionTypeId)
        struct ActionTypeData: GraphQLData {
            var v2_action_types: [ActionTypeModel]
        }
        do {
            let responseData: GraphQLResponse<ActionTypeData> = try await Hasura.shared.sendGraphQL(query: graphqlQuery, variables: variables, responseType: GraphQLResponse<ActionTypeData>.self)
            return responseData.data.v2_action_types
        } catch {
            print(graphqlQuery)
            print(variables)
            print(error)
            print("Failed to fetch object: \(error.localizedDescription)")
            return []
        }
    }

    static func fetchActionType(userId: Int, actionTypeId: Int, withAggregates:Bool = false) async -> ActionTypeModel? {
        let (graphqlQuery, variables) = generateQueryForActionTypes(userId: userId, actionTypeId: actionTypeId, withAggregates: withAggregates)
        struct ActionTypeData: GraphQLData {
            var v2_action_types: [ActionTypeModel]
        }
        do {
            let responseData: GraphQLResponse<ActionTypeData> = try await Hasura.shared.sendGraphQL(query: graphqlQuery, variables: variables, responseType: GraphQLResponse<ActionTypeData>.self)
            return responseData.data.v2_action_types.first
        } catch {
            print(graphqlQuery)
            print(variables)
            print(error)
            print("Failed to fetch action type: \(error.localizedDescription)")
            return nil
        }
    }
    
    static private func generateQueryForActionTypes(userId: Int, actionTypeId: Int?, withAggregates: Bool = false) -> (String, [String: Any]) {
        var hasuraStruct:HasuraQuery = HasuraQuery(queryFor: "v2_action_types", queryName: "ActionTypesQuery", queryType: .query)
        hasuraStruct.addWhereClause(name: "user_id", type: .int, value: userId, op: .equals)
        if (actionTypeId != nil) {
            hasuraStruct.addWhereClause(name: "id", type: .int, value: actionTypeId, op: .equals)
        }
        hasuraStruct.setSelections(selections:actionTypeSelections(withAggregates: withAggregates))
        return hasuraStruct.getQueryAndVariables
    }
    
    static func actionTypeSelections(withAggregates:Bool = false) -> String {
        return """
            id
            created_at
            description
            has_duration
            metadata
            name
            updated_at
            user_id
            short_desc_syntax
            \(withAggregates ? """
                aggregates {
                    \(AggregateController.aggregateSelections)
                }
                """: "")
        """
    }
}

// finished: work on action view
// finished: work on action type view
// finished: work on action type create/edit
// finished: put action type into database and then
// finished: fetch action type
// finished: fetch action
// finished: displaying dynamic primitives
// finished: on create/modify/delete action
// finished: put action action into database and then fetch it
// finished: formatting short view
// finished: tabs: timeline, data navigator
// SKIPPED: time stamped string
// RELEASE

// finished: work on aggregates
// RELASE
// finished: work on goals 
// RELASE
// working: goal tab
// RELASE

// COMMUNITY
// work on sharing goals incl tabs for groups
// RELEASE

// RELATIONAL DB
// internal objects
// work on object view
// work on object create/edit
// put object into database and then fetch it
// RELASE

// THIRD PARTY
// integrate location
// RELASE
// integrate saaha
// RELASE
// integrate plaid
// RELEASE


// work on reminders, schedules
// RELASE



