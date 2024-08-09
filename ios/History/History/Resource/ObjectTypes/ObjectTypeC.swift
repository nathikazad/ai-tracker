//
//  ObjectTypeC.swift
//  History
//
//  Created by Nathik Azad on 8/9/24.
//

import Foundation

class ObjectTypeController {
    static func createObjectType(objectType: ObjectType) async -> Int? {
        var hasuraStruct = HasuraMutation(
            mutationFor: "insert_object_types_one",
            mutationName: "CreateObjectTypeMutation",
            mutationType: .create
        )
        
        hasuraStruct.addParameter(name: "user_id", type: .int, value: Authentication.shared.userId!)
        hasuraStruct.addParameter(name: "name", type: .string, value: objectType.name)
        hasuraStruct.addParameter(name: "metadata", type: .jsonb, value: objectType.getMetadataJson)
        
        let (graphqlQuery, variables) = hasuraStruct.getMutationAndVariables
        struct CreateObjectTypeResponse: GraphQLData {
            var insert_object_types_one: CreatedObject
            struct CreatedObject: Decodable {
                var id: Int
            }
        }
        
        do {
            let responseData: GraphQLResponse<CreateObjectTypeResponse> = try await Hasura.shared.sendGraphQL(
                query: graphqlQuery,
                variables: variables,
                responseType: GraphQLResponse<CreateObjectTypeResponse>.self
            )
            return responseData.data.insert_object_types_one.id
        } catch {
            print("Failed to create object type: \(error.localizedDescription)")
            return nil
        }
    }
    
    static func updateObjectType(objectType: ObjectType) async {
        guard let id = objectType.id else {
            print("Cannot update object type without an ID")
            return
        }
        
        var hasuraMutation = HasuraMutation(
            mutationFor: "update_object_types_by_pk",
            mutationName: "UpdateObjectTypeMutation",
            mutationType: .update,
            id: id
        )
        
        hasuraMutation.addParameter(name: "name", type: .string, value: objectType.name)
        hasuraMutation.addParameter(name: "metadata", type: .jsonb, value: objectType.getMetadataJson)
    
        
        let (graphqlQuery, variables) = hasuraMutation.getMutationAndVariables
        
        struct UpdateObjectTypeResponse: GraphQLData {
            var update_object_types_by_pk: UpdatedObject
            struct UpdatedObject: Decodable {
                var id: Int
            }
        }
        
        do {
            let _: GraphQLResponse<UpdateObjectTypeResponse> = try await Hasura.shared.sendGraphQL(
                query: graphqlQuery,
                variables: variables,
                responseType: GraphQLResponse<UpdateObjectTypeResponse>.self
            )
        } catch {
            print("Failed to update object type: \(error.localizedDescription)")
        }
    }
    
    static func deleteObjectType(id: Int) async {
        let hasuraMutation = HasuraMutation(
            mutationFor: "delete_object_types_by_pk",
            mutationName: "DeleteObjectTypeMutation",
            mutationType: .delete,
            id: id
        )
        
        let (graphqlQuery, variables) = hasuraMutation.getMutationAndVariables
        struct DeleteObjectTypeResponse: GraphQLData {
            var delete_object_types_by_pk: DeletedObject
            struct DeletedObject: Decodable {
                var id: Int
            }
        }
        
        do {
            let _: GraphQLResponse<DeleteObjectTypeResponse> = try await Hasura.shared.sendGraphQL(
                query: graphqlQuery,
                variables: variables,
                responseType: GraphQLResponse<DeleteObjectTypeResponse>.self
            )
        } catch {
            print("Failed to delete object type: \(error.localizedDescription)")
        }
    }
    
    static func fetchObjectTypes(userId: Int, objectTypeId: Int? = nil) async -> [ObjectType] {
        let (graphqlQuery, variables) = generateQueryForObjectTypes(userId: userId, objectTypeId: objectTypeId)
        
        struct ObjectTypeData: GraphQLData {
            var object_types: [ObjectType]
        }
        
        do {
            let responseData: GraphQLResponse<ObjectTypeData> = try await Hasura.shared.sendGraphQL(
                query: graphqlQuery,
                variables: variables,
                responseType: GraphQLResponse<ObjectTypeData>.self
            )
            return responseData.data.object_types
        } catch {
            print("Failed to fetch object types: \(error.localizedDescription)")
            return []
        }
    }
    
    static func fetchObjectType(userId: Int, objectTypeId: Int) async -> ObjectType? {
        let (graphqlQuery, variables) = generateQueryForObjectTypes(userId: userId, objectTypeId: objectTypeId)
        
        struct ObjectTypeData: GraphQLData {
            var object_types: [ObjectType]
        }
        
        do {
            let responseData: GraphQLResponse<ObjectTypeData> = try await Hasura.shared.sendGraphQL(
                query: graphqlQuery,
                variables: variables,
                responseType: GraphQLResponse<ObjectTypeData>.self
            )
            return responseData.data.object_types.first
        } catch {
            print("Failed to fetch object type: \(error.localizedDescription)")
            return nil
        }
    }
    
    private static func generateQueryForObjectTypes(userId: Int, objectTypeId: Int? = nil) -> (String, [String: Any]) {
        var hasuraStruct = HasuraQuery(queryFor: "object_types", queryName: "ObjectTypesQuery", queryType: .query)
        hasuraStruct.addWhereClause(name: "user_id", type: .int, value: userId, op: .equals)
        if let objectTypeId = objectTypeId {
            hasuraStruct.addWhereClause(name: "id", type: .int, value: objectTypeId, op: .equals)
        }
        hasuraStruct.setSelections(selections: objectTypeSelections())
        return hasuraStruct.getQueryAndVariables
    }
    
    private static func objectTypeSelections() -> String {
        return """
            id
            created_at
            user_id
            name
            metadata
        """
    }
}
