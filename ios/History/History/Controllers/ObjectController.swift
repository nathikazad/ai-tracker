//
//  ObjectController.swift
//  History
//
//  Created by Nathik Azad on 5/17/24.
//

import Foundation
class ObjectController {
    
    struct ObjectResponseData: Decodable {
        var data: ObjectWrapper
    }

    struct ObjectWrapper: Decodable {
        var objects_by_pk: ASObject
    }

    // Generate the GraphQL query string
    static func generateQuery(objectId: Int) -> String {
        return """
        query ObjectQuery {
          objects_by_pk(id: \(objectId)) {
            id
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
        }
        """
    }

    // Fetch the object data
    static func fetchObject(objectId: Int) async -> ASObject? {
        let graphqlQuery = generateQuery(objectId: objectId)
        
        do {
            let responseData: ObjectResponseData = try await Hasura.shared.sendGraphQL(query: graphqlQuery, responseType: ObjectResponseData.self)
            return responseData.data.objects_by_pk
        } catch {
            // Log error details for debugging purposes
            print("Failed to fetch object: \(error.localizedDescription)")
            return nil
        }
    }
}
