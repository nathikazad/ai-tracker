//
//  ActionTypeObjectTypeC.swift
//  History
//
//  Created by Nathik Azad on 8/15/24.
//

import Foundation
import Foundation

class ActionTypeObjectTypeController {
    
    static func createActionTypeObjectType(actionTypeId: Int, objectTypeId: Int, metadata: ActionTypeConnectionMetadataForHasura) async -> Int? {
        var hasuraStruct = HasuraMutation(
            mutationFor: "insert_v2_object_t_action_t_one",
            mutationName: "CreateActionTypeObjectTypeMutation",
            mutationType: .create
        )
        
        hasuraStruct.addParameter(name: "action_type_id", type: .int, value: actionTypeId)
        hasuraStruct.addParameter(name: "object_type_id", type: .int, value: objectTypeId)
        hasuraStruct.addParameter(name: "metadata", type: .jsonb, value: metadata.toJson)
        
        let (graphqlQuery, variables) = hasuraStruct.getMutationAndVariables
        struct CreateActionTypeObjectTypeResponse: GraphQLData {
            var insert_v2_object_t_action_t_one: CreatedObject
            struct CreatedObject: Decodable {
                var id: Int
            }
        }
        
        do {
            let responseData: GraphQLResponse<CreateActionTypeObjectTypeResponse> = try await Hasura.shared.sendGraphQL(query: graphqlQuery, variables: variables, responseType: GraphQLResponse<CreateActionTypeObjectTypeResponse>.self)
            return responseData.data.insert_v2_object_t_action_t_one.id
        } catch {
            print("Failed to create action type object type: \(error.localizedDescription)")
            return nil
        }
    }
    
    static func updateActionTypeObjectType(id: Int, metadata: ActionTypeConnectionMetadataForHasura) async {
        var hasuraMutation = HasuraMutation(
            mutationFor: "update_v2_object_t_action_t_by_pk",
            mutationName: "UpdateActionTypeObjectTypeMutation",
            mutationType: .update,
            id: id
        )
        hasuraMutation.addParameter(name: "metadata", type: .jsonb, value: metadata.toJson)
        
        let (graphqlQuery, variables) = hasuraMutation.getMutationAndVariables
        
        struct UpdateActionTypeObjectTypeResponse: GraphQLData {
            var update_v2_object_t_action_t_by_pk: UpdatedObject
            struct UpdatedObject: Decodable {
                var id: Int
            }
        }
        
        do {
            let _: GraphQLResponse<UpdateActionTypeObjectTypeResponse> = try await Hasura.shared.sendGraphQL(
                query: graphqlQuery,
                variables: variables,
                responseType: GraphQLResponse<UpdateActionTypeObjectTypeResponse>.self
            )
        } catch {
            print("Failed to update action type object type: \(error.localizedDescription)")
        }
    }
    
    static func deleteActionTypeObjectType(id: Int) async {
        let hasuraMutation = HasuraMutation(
            mutationFor: "delete_v2_object_t_action_t_by_pk",
            mutationName: "DeleteActionTypeObjectTypeMutation",
            mutationType: .delete,
            id: id
        )
        
        let (graphqlQuery, variables) = hasuraMutation.getMutationAndVariables
        
        struct DeleteActionTypeObjectTypeResponse: GraphQLData {
            var delete_v2_object_t_action_t_by_pk: DeletedObject
            struct DeletedObject: Decodable {
                var id: Int
            }
        }
        
        do {
            let _: GraphQLResponse<DeleteActionTypeObjectTypeResponse> = try await Hasura.shared.sendGraphQL(
                query: graphqlQuery,
                variables: variables,
                responseType: GraphQLResponse<DeleteActionTypeObjectTypeResponse>.self
            )
        } catch {
            print("Failed to delete action type object type: \(error.localizedDescription)")
        }
    }
    
    static func fetchActionTypeObjectTypes(actionTypeId: Int) async -> [ObjectConnection] {
        let (graphqlQuery, variables) = generateQueryForActionTypeObjectTypes(actionTypeId: actionTypeId)
        
        struct ActionTypeObjectTypeData: GraphQLData {
            var v2_action_type_object_types: [ObjectConnection]
        }
        
        do {
            let responseData: GraphQLResponse<ActionTypeObjectTypeData> = try await Hasura.shared.sendGraphQL(query: graphqlQuery, variables: variables, responseType: GraphQLResponse<ActionTypeObjectTypeData>.self)
            return responseData.data.v2_action_type_object_types
        } catch {
            print("Failed to fetch action type object types: \(error.localizedDescription)")
            return []
        }
    }
    
    private static func generateQueryForActionTypeObjectTypes(actionTypeId: Int) -> (String, [String: Any]) {
        var hasuraStruct = HasuraQuery(queryFor: "v2_action_type_object_types", queryName: "ActionTypeObjectTypesQuery", queryType: .query)
        hasuraStruct.addWhereClause(name: "action_type_id", type: .int, value: actionTypeId, op: .equals)
        hasuraStruct.setSelections(selections: actionTypeObjectTypeSelections())
        return hasuraStruct.getQueryAndVariables
    }
    
    static func actionTypeObjectTypeSelections() -> String {
        return """
        action_type_id
        object_type_id
        id
        metadata
        object_type {
          \(ObjectTypeController.objectTypeSelections())
        }
        """
    }
}

