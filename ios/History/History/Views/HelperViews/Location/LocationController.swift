//
//  LocationModel.swift
//  History
//
//  Created by Nathik Azad on 3/18/24.
//

import Foundation
import CoreLocation
class LocationsController: ObservableObject {
    
    let subscriptionId: String = "locations"
    
    struct LocationsResponseData: Decodable {
        var data: LocationsWrapper
        struct LocationsWrapper: Decodable {
            var locations: [LocationModel]
        }
    }
    
    struct LocationResponseData: Decodable {
        var data: LocationWrapper
        struct LocationWrapper: Decodable {
            var locations_by_pk: LocationModel
        }
    }
    
    static func fetchLocations(userId: Int) async throws -> [LocationModel] {
        let (query, variables): (String, [String: Any]) = LocationsController.generateQueryForUserLocations(userId: userId)
        
        do {
            // Directly get the decoded ResponseData object from sendGraphQL
            let responseData: LocationsResponseData = try await Hasura.shared.sendGraphQL(query: query, variables: variables, responseType: LocationsResponseData.self)
            
                return responseData.data.locations
            
        } catch {
            print("Error: \(error.localizedDescription)")
            throw error
        }
    }

    static func fetchLocation(locationId: Int) async throws -> LocationModel {
            let (query, variables): (String, [String: Any]) = LocationsController.generateQueryForLocation(locationId: locationId)
            
            do {
                // Directly get the decoded ResponseData object from sendGraphQL
                let responseData: LocationResponseData = try await Hasura.shared.sendGraphQL(query: query, variables: variables, responseType: LocationResponseData.self)
                return responseData.data.locations_by_pk
            } catch {
                print("Error: \(error.localizedDescription)")
                throw error
            }
    }
    
    
    static private func generateQueryForUserLocations(userId: Int) -> (String, [String: Any]) {
        let query =  """
        query LocationQuery($userId: Int) {
          locations(where: {user_id: {_eq: $userId}}) {
            id
            location
            name
          }
        }
        """
        let variables: [String: Any] = ["userId": userId]
        return (query, variables)
    }
    
    
    static private func generateQueryForLocation(locationId: Int) -> (String, [String: Any]) {
        let query = """
        query LocationQuery($locationId: Int!) {
            locations_by_pk(id: $locationId) {
                id
                location
                name
                events {
                    id
                    metadata
                    start_time
                    end_time
                    id
                    event_type
                    parent_id
                    metadata
                }

            }
        }
        """
        let variables: [String: Any] = ["locationId": locationId]
        return (query, variables)
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
    
    static func createLocation(name:String, lat: Double, lon: Double) async throws -> Int {
        let body:[String:Any] =  [
            "name": name,
            "lon": lon,
            "lat": lat
        ]
        let data = try await ServerCommunicator.sendPostRequestAsync(to: createLocationEndpoint, body: body, token: Authentication.shared.hasuraJwt, stackOnUnreachable: false)
        if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []),
            let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
            let jsonString = String(data: jsonData, encoding: .utf8) {
             print("Received JSON: \(jsonString)")
             
             if let jsonObject = json as? [String: Any],
                 let id = jsonObject["id"] as? Int {
                  // Use the id value here
                  print("Received ID: \(id)")
                 return id
             } else {
                  print("Failed to extract ID from JSON data")
                  throw NSError(domain: "InvalidDataError", code: 0, userInfo: nil)
             }
        } else {
             print("Failed to decode JSON data")
            throw NSError(domain: "InvalidDataError", code: 0, userInfo: nil)
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
    var id: Int?
    var name: String?
    var location: LocationData?
    var events: [EventModel]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case location
        case events
    }
    
    var latitude: Double {
        location?.coordinates[1] ?? 0.0
    }
    
    var longitude: Double {
        location?.coordinates[0] ?? 0.0
    }
    
    var toCLLocation: CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }

    static func fromCLLocation(name: String, location: CLLocation) -> LocationModel {
        return LocationModel(id: nil, name: name, location: LocationData(type: "Point", crs: CRS(type: "name", properties: CRS.Properties(name: "EPSG:4326")), coordinates: [location.coordinate.longitude, location.coordinate.latitude]))
    }
    
    struct LocationData: Decodable {
        var type: String
        var crs: CRS?
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

