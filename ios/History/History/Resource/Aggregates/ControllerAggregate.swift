//
//  AggregateController.swift
//  History
//
//  Created by Nathik Azad on 8/1/24.
//

import Foundation

class AggregateController {
    static func createAggregate(aggregate: AggregateModel) async -> Int? {
        var hasuraStruct: HasuraMutation = HasuraMutation(
            mutationFor: "insert_v2_aggregates_one",
            mutationName: "AggregateMutation",
            mutationType: .create)
        
        hasuraStruct.addParameter(name: "action_type_id", type: .int, value: aggregate.actionTypeId)
        hasuraStruct.addParameter(name: "metadata", type: .jsonb, value: aggregate.metadata.toJson)
        
        let (graphqlQuery, variables) = hasuraStruct.getMutationAndVariables

        struct CreateAggregateResponse: GraphQLData {
            var insert_v2_aggregates_one: CreatedObject
            struct CreatedObject: Decodable {
                var id: Int
            }
        }
        
        do {
            let responseData: GraphQLResponse<CreateAggregateResponse> = try await Hasura.shared.sendGraphQL(query: graphqlQuery, variables: variables, responseType: GraphQLResponse<CreateAggregateResponse>.self)
            return responseData.data.insert_v2_aggregates_one.id
        } catch {
            print("Failed to create aggregate: \(error.localizedDescription)")
            return nil
        }
    }
    
    static func updateAggregate(aggregate: AggregateModel) async {
        guard let id = aggregate.id else {
            print("Cannot update aggregate without an id")
            return
        }
        
        var hasuraMutation: HasuraMutation = HasuraMutation(
            mutationFor: "update_v2_aggregates_by_pk",
            mutationName: "UpdateAggregateMutation",
            mutationType: .update,
            id: id
        )
        
        hasuraMutation.addParameter(name: "action_type_id", type: .int, value: aggregate.actionTypeId)
        hasuraMutation.addParameter(name: "metadata", type: .jsonb, value: aggregate.metadata.toJson)
        
        let (graphqlQuery, variables) = hasuraMutation.getMutationAndVariables
        struct UpdateAggregateResponse: GraphQLData {
            var update_v2_aggregates_by_pk: UpdatedObject
            struct UpdatedObject: Decodable {
                var id: Int
            }
        }
        
        do {
            let _: GraphQLResponse<UpdateAggregateResponse> = try await Hasura.shared.sendGraphQL(
                query: graphqlQuery,
                variables: variables,
                responseType: GraphQLResponse<UpdateAggregateResponse>.self
            )
        } catch {
            print("Failed to update aggregate: \(error.localizedDescription)")
        }
    }
    
    static func deleteAggregate(id: Int) async {
        let hasuraMutation: HasuraMutation = HasuraMutation(
            mutationFor: "delete_v2_aggregates_by_pk",
            mutationName: "DeleteAggregateMutation",
            mutationType: .delete,
            id: id
        )
        
        let (graphqlQuery, variables) = hasuraMutation.getMutationAndVariables
        
        struct DeleteAggregateResponse: GraphQLData {
            var delete_v2_aggregates_by_pk: DeletedObject
            struct DeletedObject: Decodable {
                var id: Int
            }
        }
        
        do {
            let _: GraphQLResponse<DeleteAggregateResponse> = try await Hasura.shared.sendGraphQL(
                query: graphqlQuery,
                variables: variables,
                responseType: GraphQLResponse<DeleteAggregateResponse>.self
            )
        } catch {
            print("Failed to delete aggregate: \(error.localizedDescription)")
        }
    }
    
    static func fetchAggregates(actionTypeId: Int? = nil, userId: Int? = nil) async -> [AggregateModel] {
        let (graphqlQuery, variables) = generateQueryForAggregates(actionTypeId: actionTypeId, userId: userId)
        struct AggregateData: GraphQLData {
            var v2_aggregates: [AggregateModel]
        }
        do {
            let responseData: GraphQLResponse<AggregateData> = try await Hasura.shared.sendGraphQL(query: graphqlQuery, variables: variables, responseType: GraphQLResponse<AggregateData>.self)
            return responseData.data.v2_aggregates
        } catch {
            print("Failed to fetch aggregates: \(error.localizedDescription)")
            return []
        }
    }
    
    static private func generateQueryForAggregates(actionTypeId: Int?, userId: Int? = nil) -> (String, [String: Any]) {
        var hasuraStruct: HasuraQuery = HasuraQuery(queryFor: "v2_aggregates", queryName: "AggregatesQuery", queryType: .query)
        if let actionTypeId = actionTypeId {
            hasuraStruct.addWhereClause(name: "action_type_id", type: .int, value: actionTypeId, op: .equals)
        }
        if let userId = userId {
            hasuraStruct.addWhereClause(name: "user_id", type: .int, value: userId, op: .equals)
        }
        hasuraStruct.setSelections(selections: aggregateSelections)
        return hasuraStruct.getQueryAndVariables
    }
    
    static var aggregateSelections: String {
        return """
            id
            action_type_id
            metadata
        """
    }
}
