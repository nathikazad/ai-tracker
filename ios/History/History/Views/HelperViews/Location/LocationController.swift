//
//  LocationModel.swift
//  History
//
//  Created by Nathik Azad on 3/18/24.
//

import Foundation
class LocationsController: ObservableObject {
    
    @Published var locations: [LocationModel] = []
    let subscriptionId: String = "locations"
    
    struct LocationsResponseData: Decodable {
        var data: LocationsWrapper
        struct LocationsWrapper: Decodable {
            var locations: [LocationModel]
        }
    }
    
    func fetchLocations(userId: Int) {
        Task {
            let graphqlQuery = LocationsController.generateQuery(userId: userId)
            let variables: [String: Any] = ["userId": userId]
            do {
                // Directly get the decoded ResponseData object from sendGraphQL
                print(graphqlQuery)
                let responseData: LocationsResponseData = try await Hasura.shared.sendGraphQL(query: graphqlQuery, variables: variables, responseType: LocationsResponseData.self)
                DispatchQueue.main.async {
                    self.locations = responseData.data.locations
                }
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    
    static private func generateQuery(userId: Int, isSubscription: Bool = false) -> String {
        let operationType =  "query"
        
        return """
        query LocationQuery($userId: Int) {
          locations(where: {user_id: {_eq: $userId}}) {
            id
            location
            name
          }
        }
        """
    }
    
    static func editLocationName(id: Int, name: String) {
        let mutationQuery = """
        mutation MyMutation($id: Int!, $name: String) {
          update_locations_by_pk(pk_columns: {id: $id}, _set: {name: $name}) {
            id
          }
        }
        """
        let variables: [String: Any] = ["id": id, "name": name]

        struct EditLocationResponse: Decodable {
            var data: EditLocationWrapper
            struct EditLocationWrapper: Decodable {
                var update_locations_by_pk: EditedLocation
                struct EditedLocation: Decodable {
                    var id: Int
                }
            }
        }
        Task {
            do {
                let response: EditLocationResponse = try await Hasura.shared.sendGraphQL(query: mutationQuery, variables: variables, responseType: EditLocationResponse.self)
            } catch {
                print("Error editing location name: \(error)")
            }
        }
    }
    
    
    static func deleteLocation(id: Int, onSuccess: (() -> Void)? = nil) {
        let mutationQuery = """
        mutation MyMutation($id: Int!) {
          delete_locations_by_pk(id: $id) {
            id
          }
        }
        """
        let variables: [String: Any] = ["id": id]

        struct DeleteLocationResponse: Decodable {
            var data: DeleteLocationWrapper
            struct DeleteLocationWrapper: Decodable {
                var delete_locations_by_pk: DeletedLocation
                struct DeletedLocation: Decodable {
                    var id: Int
                }
            }
        }
        Task {
            do {
                let response: DeleteLocationResponse = try await Hasura.shared.sendGraphQL(query: mutationQuery, variables: variables, responseType: DeleteLocationResponse.self)
                DispatchQueue.main.async {
                    print("Location deleted: \(response.data.delete_locations_by_pk.id)")
                    onSuccess?()
                }
            } catch {
                print("Error deleting location: \(error)")
            }
        }
    }
}

struct LocationModel: Decodable, Identifiable {
    var id: Int
    var name: String?
    var location: LocationData
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case location
    }
    
    var latitude: Double {
        location.coordinates[1]
    }
    
    var longitude: Double {
        location.coordinates[0]
    }
    
    struct LocationData: Decodable {
        var type: String
        var crs: CRS
        var coordinates: [Double]
    }
    
    struct CRS: Decodable {
        var type: String
        var properties: Properties
        
        struct Properties: Decodable {
            var name: String
        }
    }
}

