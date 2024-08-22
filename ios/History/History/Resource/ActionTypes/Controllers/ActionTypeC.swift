//
//  ActionController.swift
//  History
//
//  Created by Nathik Azad on 7/22/24.
//

import Foundation

let externalDataTypes: [String] = [] //["Expense", "Organization", "Item"]

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

    static func fetchActionType(userId: Int, actionTypeId: Int, withAggregates:Bool = false, withObjectConnections: Bool = false) async -> ActionTypeModel? {
        let (graphqlQuery, variables) = generateQueryForActionTypes(userId: userId, actionTypeId: actionTypeId, withAggregates: withAggregates, withObjectConnections: withObjectConnections)
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
    
    static private func generateQueryForActionTypes(userId: Int, actionTypeId: Int?, withAggregates: Bool = false, withObjectConnections: Bool = false) -> (String, [String: Any]) {
        var hasuraStruct:HasuraQuery = HasuraQuery(queryFor: "v2_action_types", queryName: "ActionTypesQuery", queryType: .query)
        hasuraStruct.addWhereClause(name: "user_id", type: .int, value: userId, op: .equals)
        if (actionTypeId != nil) {
            hasuraStruct.addWhereClause(name: "id", type: .int, value: actionTypeId, op: .equals)
        }
        hasuraStruct.setSelections(selections:actionTypeSelections(withAggregates: withAggregates, withObjectConnections: withObjectConnections))
        return hasuraStruct.getQueryAndVariables
    }
    
    static func actionTypeSelections(withAggregates:Bool = false, withObjectConnections: Bool = false) -> String {
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
                    \(AggregateController.aggregateSelections())
                }
                """: "")
            \(withObjectConnections ? """
                object_t_action_ts {
                    \(ActionTypeObjectTypeController.actionTypeObjectTypeSelections())
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
// finished: goal tab
// RELASE

// finished: fix apple issues
// finished: add candle sticks
// finished: Add voice notes

// CANDLES
// finished: grouped by days or actionTypes with time actions 
// finished: Add time info to candles
// finshed: change color permanently from candle

// GOALS
// fixed: Make goals show by week and 
// finished: duration min/sec goal
// finished: cumulative for week goal.

// finished: aggregate on daily too
// finished: cumulative count for week
// finished: Support dark mode
// finished: add goal button
// finished: goal field be currency, number

// ACTION VIEWS
// finished: add object connection
// finished: children

// traction, super simple, messages, settings(which 3 goals to share) and goals
// cool demo
// How much have I slept last week? how much have I spent on Amazon? 

// BUGS
// sleep into next day problem, add a custom cut off
// RELEASE & SELL SELL SELL

// -----------------------------------------------------------
// V2 COMMUNITIES
// finished: Add groups tab, list all groups, create group
// finished: break group view into three tabs
// finished: show messages, send message
// finished: goals view
// settings view 
//     finished: view members
//     finished: admin can switch users
//     finished: goals to share
// finished: notifications
// finished: auto scroll only if already in bottom, other wise show smtn with down arrow
// RELEASE

// -----------------------------------------------------------
// V3
// RELATIONAL DB
// finished: internal objects
// finished: work on object view
// finished: work on object create/edit
// finished: put object into database and then fetch it
// create connections between objects and actions
// integrate contacts
// RELASE

// Finished: timezone support for viewing across timezone
// Streak
// monthly goals
// Onboard Mom, Tito, Dane, Tipu, Nivedh, Alisha, Paty
// Dropdown and short string, 
// AI or 3rd party integration?


// skip: list actions(inside object) 
// skip: filter for actions and objects, only enum, bool and object connection.name
// goals
//  skip: goal field be unit or other similar datatypes also
//  skip: actual/expected value and streak
//  skip: Support conditions only for enum
//  skip: first and last to compare
// routine
//  skip: routine creator
//  skip: add preferred hours with marks

//  skip: three tabs, events, candles, aggregates
//  skip: list actions filter by enum
//  skip: list objects filter by enum
// skip: create segments

// skipped: Add hour and minute when choosing duration
// skipped: add conditions only for enums (for Nivedh)
// add arrays
// add todos

// THIRD PARTY
// integrate saaha
// RELASE
// integrate plaid
// RELEASE


// work on reminders, schedules
// RELASE



