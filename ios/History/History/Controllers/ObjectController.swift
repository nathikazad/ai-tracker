//
//  ObjectController.swift
//  History
//
//  Created by Nathik Azad on 5/17/24.
//

import Foundation
class ObjectController {
    
    struct ObjectResponseData<T: Decodable>: Decodable {
        struct ObjectWrapper: Decodable {
            var objects_by_pk: T
        }
        var data: ObjectWrapper
    }
    
    struct ObjectsResponseData: Decodable {
        struct ObjectsWrapper: Decodable {
            var objects: [ASObject]
        }
        var data: ObjectsWrapper
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
        if let objectType = objectType {
            hasuraStruct.addParameter(name: "object_type", type: "String", value: objectType.rawValue, op: "_eq")
        }
        
        hasuraStruct.setSelections(selections:objectSelections)
        return hasuraStruct.getQueryAndVariables
    }
    

    static var objectSelections: String {
        return """
            id
            user_id
            name
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
            }
          }
        """
    }

    static func fetchObject<T: ASObject>(type: T.Type, objectId: Int) async -> T? {
        let graphqlQuery = generateQueryForObject(objectId: objectId)
        
        do {
            let responseData: ObjectResponseData<T> = try await Hasura.shared.sendGraphQL(query: graphqlQuery, responseType: ObjectResponseData<T>.self)
            return responseData.data.objects_by_pk
        } catch {
            // Log error details for debugging purposes
            print("Failed to fetch object: \(error.localizedDescription)")
            return nil
        }
    }
    
    static func fetchObjects(userId: Int, objectType: ASObjectType?) async -> [ASObject] {
        let (graphqlQuery, variables) = generateQueryForObjects(userId: userId, objectType: objectType)
        
        do {
            let responseData: ObjectsResponseData = try await Hasura.shared.sendGraphQL(query: graphqlQuery, variables: variables, responseType: ObjectsResponseData.self)
            return responseData.data.objects
        } catch {
            // Log error details for debugging purposes
            print("Failed to fetch object: \(error.localizedDescription)")
            return []
        }
    }
    
    
}
