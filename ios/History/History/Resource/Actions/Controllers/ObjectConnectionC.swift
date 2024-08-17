//
//  ObjectConnectionC.swift
//  History
//
//  Created by Nathik Azad on 8/16/24.
//

import Foundation

class ObjectActionController {
    
    static func createObjectAction(objectTypeActionTypeId: Int, objectId: Int, actionId: Int) async -> Int? {
        var hasuraStruct = HasuraMutation(
            mutationFor: "insert_v2_object_action_one",
            mutationName: "CreateObjectActionMutation",
            mutationType: .create
        )
        
        hasuraStruct.addParameter(name: "object_t_action_t_id", type: .int, value: objectTypeActionTypeId)
        hasuraStruct.addParameter(name: "object_id", type: .int, value: objectId)
        hasuraStruct.addParameter(name: "action_id", type: .int, value: actionId)
        
        let (graphqlQuery, variables) = hasuraStruct.getMutationAndVariables
        
        struct CreateObjectActionResponse: GraphQLData {
            var insert_v2_object_action_one: CreatedObject
            struct CreatedObject: Decodable {
                var id: Int
            }
        }
        
        do {
            let responseData: GraphQLResponse<CreateObjectActionResponse> = try await Hasura.shared.sendGraphQL(query: graphqlQuery, variables: variables, responseType: GraphQLResponse<CreateObjectActionResponse>.self)
            return responseData.data.insert_v2_object_action_one.id
        } catch {
            print("Failed to create object action: \(error.localizedDescription)")
            return nil
        }
    }
    
    static func updateObjectAction(id: Int, actionId: Int? = nil, objectId: Int? = nil) async {
        var hasuraMutation = HasuraMutation(
            mutationFor: "update_v2_object_action_by_pk",
            mutationName: "UpdateObjectActionMutation",
            mutationType: .update,
            id: id
        )
        
        if let actionId = actionId {
            hasuraMutation.addParameter(name: "action_id", type: .int, value: actionId)
        }
        
        if let objectId = objectId {
            hasuraMutation.addParameter(name: "object_id", type: .int, value: objectId)
        }
        
        let (graphqlQuery, variables) = hasuraMutation.getMutationAndVariables
        
        struct UpdateObjectActionResponse: GraphQLData {
            var update_v2_object_action_by_pk: UpdatedObject
            struct UpdatedObject: Decodable {
                var id: Int
            }
        }
        
        do {
            let _: GraphQLResponse<UpdateObjectActionResponse> = try await Hasura.shared.sendGraphQL(
                query: graphqlQuery,
                variables: variables,
                responseType: GraphQLResponse<UpdateObjectActionResponse>.self
            )
        } catch {
            print("Failed to update object action: \(error.localizedDescription)")
        }
    }
    
    static func deleteObjectAction(id: Int) async {
        let hasuraMutation = HasuraMutation(
            mutationFor: "delete_v2_object_action_by_pk",
            mutationName: "DeleteObjectActionMutation",
            mutationType: .delete,
            id: id
        )
        
        let (graphqlQuery, variables) = hasuraMutation.getMutationAndVariables
        
        struct DeleteObjectActionResponse: GraphQLData {
            var delete_v2_object_action_by_pk: DeletedObject
            struct DeletedObject: Decodable {
                var id: Int
            }
        }
        
        do {
            let _: GraphQLResponse<DeleteObjectActionResponse> = try await Hasura.shared.sendGraphQL(
                query: graphqlQuery,
                variables: variables,
                responseType: GraphQLResponse<DeleteObjectActionResponse>.self
            )
        } catch {
            print("Failed to delete object action: \(error.localizedDescription)")
        }
    }
    
    static func fetchObjectActions(actionId: Int) async -> [ObjectAction] {
        let (graphqlQuery, variables) = generateQueryForObjectActions(actionId: actionId)
        
        struct ObjectActionsData: GraphQLData {
            var v2_actions_by_pk: ActionData
            
            struct ActionData: Decodable {
                var object_actions: [ObjectAction]
            }
        }
        
        do {
            let responseData: GraphQLResponse<ObjectActionsData> = try await Hasura.shared.sendGraphQL(query: graphqlQuery, variables: variables, responseType: GraphQLResponse<ObjectActionsData>.self)
            return responseData.data.v2_actions_by_pk.object_actions
        } catch {
            print("Failed to fetch object actions: \(error.localizedDescription)")
            return []
        }
    }
    
    private static func generateQueryForObjectActions(actionId: Int) -> (String, [String: Any]) {
        var hasuraStruct = HasuraQuery(queryFor: "v2_object_action_by_pk", queryName: "ObjectActionsQuery", queryType: .query)
        hasuraStruct.addParameter(name: "action_id", type: .int, value: actionId)
        hasuraStruct.setSelections(selections: objectActionSelections())
        return hasuraStruct.getQueryAndVariables
    }
    
    static func objectActionSelections() -> String {
        return """
          id
          object_t_action_t_id
          object {
            id
            name
          }
          action_id
        """
    }
}
