//
//  ObjectController.swift
//  History
//
//  Created by Nathik Azad on 5/17/24.
//

import Foundation
class ObjectController {
    
    
    struct ObjectResponseData<T: Decodable>: GraphQLData {
        var objects_by_pk: T
    }
    
    struct ObjectsResponseData<T: Decodable>: GraphQLData {
        var objects: [T]
    }

    // Generate the GraphQL query string
    static func generateQueryForObject(objectId: Int) -> String {
        return """
        query ObjectQuery {
          objects_by_pk(id: \(objectId)) {
            \(objectSelections)
        }
        """
    }
    
    static func generateQueryForObjects(userId: Int, objectType: ASObjectType?) -> (String, [String: Any]) {
        var hasuraStruct:HasuraQuery = HasuraQuery(queryFor: "objects", queryName: "ObjectsQuery", queryType: .query)
        hasuraStruct.addParameter(name: "user_id", type: "Int", value: userId, op: "_eq")
        hasuraStruct.addParameter(name: "object_type", type: "String", value: objectType?.rawValue, op: "_eq")
        hasuraStruct.setSelections(selections:objectSelections)
        return hasuraStruct.getQueryAndVariables
    }
    

    static var objectSelections: String {
        return """
            id
            user_id
            name
            metadata
            object_type
            events(order_by: {id: desc}) {
              start_time
              end_time
              id
              event_type
              parent_id
              metadata
              interaction {
                  timestamp
                  id
                  content
              }
              objects {
                  object_type
                  name
                  id
              }
            }
          }
        """
    }

    static func fetchObject<T: ASObject>(type: T.Type, objectId: Int) async -> T? {
        let graphqlQuery = generateQueryForObject(objectId: objectId)
        
        do {
            let responseData: GraphQLResponse<ObjectResponseData<T>> = try await Hasura.shared.sendGraphQL(query: graphqlQuery, responseType: GraphQLResponse<ObjectResponseData<T>>.self)
            return responseData.data.objects_by_pk
        } catch {
            // Log error details for debugging purposes
            print("Failed to fetch object: \(error.localizedDescription)")
            return nil
        }
    }
    
    static func fetchObjects<T: ASObject>(type: T.Type, userId: Int, objectType: ASObjectType?) async -> [T] {
        let (graphqlQuery, variables) = generateQueryForObjects(userId: userId, objectType: objectType)
    
        do {
            let responseData: GraphQLResponse<ObjectsResponseData<T>> = try await Hasura.shared.sendGraphQL(query: graphqlQuery, variables: variables, responseType: GraphQLResponse<ObjectsResponseData<T>>.self)
            return responseData.data.objects
        } catch {
            // Log error details for debugging purposes
            print("Failed to fetch object: \(error.localizedDescription)")
            return []
        }
    }

    static func createObject(userId: Int, object: ASObject) async -> Int? {
        var hasuraStruct:HasuraMutation = HasuraMutation(mutationFor: "insert_objects_one", mutationName: "CreateObjectMutation", mutationType: .create)
        hasuraStruct.addParameter(name: "user_id", type: "Int", value: userId)
        hasuraStruct.addParameter(name: "name", type: "String", value: object.name)
        hasuraStruct.addParameter(name: "object_type", type: "String", value: object.objectType.rawValue)
        hasuraStruct.addParameter(name: "metadata", type: "jsonb", value: object.metadata)

        let (graphqlQuery, variables) = hasuraStruct.getMutationAndVariables
        
        struct CreateObjectResponse: GraphQLData {
            var insert_objects_one: CreatedObject
            struct CreatedObject: Decodable {
                var id: Int
            }
        }
        
        do {
            let responseData: GraphQLResponse<CreateObjectResponse> = try await Hasura.shared.sendGraphQL(query: graphqlQuery, variables: variables, responseType: GraphQLResponse<CreateObjectResponse>.self)
            return responseData.data.insert_objects_one.id
        } catch {
            // Log error details for debugging purposes
            print("Failed to create object: \(error.localizedDescription)")
            return nil
        }
    }
    
    static func mutateObject(object: ASObject) async {
        var hasuraMutation: HasuraMutation = HasuraMutation(mutationFor: "update_objects_by_pk", mutationName: "ObjectMutation", mutationType: .update, id: object.id)
        hasuraMutation.addParameter(name: "name", type: "String", value: object.name)
        hasuraMutation.addParameter(name: "metadata", type: "jsonb", value: object.metadata)

        let (graphqlQuery, variables) = hasuraMutation.getMutationAndVariables
        
        struct CreateObjectResponse: GraphQLData {
            var update_objects_by_pk: CreatedObject
            struct CreatedObject: Decodable {
                var id: Int
            }
        }
        
        do {
            let _: GraphQLResponse<CreateObjectResponse> = try await Hasura.shared.sendGraphQL(query: graphqlQuery, variables: variables, responseType: GraphQLResponse<CreateObjectResponse>.self)
        } catch {
            // Log error details for debugging purposes
            print("Failed to mutate object: \(error.localizedDescription)")
        }
    }
    
    
    // TODO: remove all associations
    static func deleteObject(id: Int) async {
        let hasuraMutation: HasuraMutation = HasuraMutation(mutationFor: "delete_objects_by_pk", mutationName: "ObjectDeletion", mutationType: .delete, id: id)


        let (graphqlQuery, variables) = hasuraMutation.getMutationAndVariables
        
        struct DeleteObjectResponse: GraphQLData {
            var update_objects_by_pk: CreatedObject
            struct CreatedObject: Decodable {
                var id: Int
            }
        }
        
        do {
            let _: GraphQLResponse<DeleteObjectResponse> = try await Hasura.shared.sendGraphQL(query: graphqlQuery, variables: variables, responseType: GraphQLResponse<DeleteObjectResponse>.self)
        } catch {
            // Log error details for debugging purposes
            print("Failed to mutate object: \(error.localizedDescription)")
        }
    }
    
}
