//
//  UserController.swift
//  History
//
//  Created by Nathik Azad on 4/10/24.
//

import Foundation
class UserController: ObservableObject {
    struct ResponseData: Decodable {
        var data: UsersWrapper
    }
    
    struct UsersWrapper: Decodable {
        var users_by_pk: UserModel
    }
    
    static func ensureUserTimezone() async {
        do {
            let user = Authentication.shared.user!
            if user.timezone !=  TimeZone.current.identifier {
                try await updateUserTimezone(timezone:  TimeZone.current.identifier)
                print("User timezone updated to \( TimeZone.current.identifier)")
            }
        } catch {
            // Rethrow any errors encountered
//            throw error
        }
    }
    
    static func fetchUser() async throws -> UserModel {
        let graphqlQuery = generateQuery(userId: Authentication.shared.userId!)
        
        do {
            let responseData: ResponseData = try await Hasura.shared.sendGraphQL(query: graphqlQuery, responseType: ResponseData.self)
            return responseData.data.users_by_pk
        } catch {
            // Log error details for debugging purposes
            print("Failed to fetch user: \(error.localizedDescription)")
            
            throw error
        }
    }
    
    
    
    static func updateUserTimezone(timezone: String) async throws{
        let mutationQuery = """
        mutation {
            update_users_by_pk(pk_columns: {id: \(Authentication.shared.userId!)}, _set: {timezone: \"\(timezone)\"}) {
                id
                timezone
            }
        }
        """
        
        struct UserMutationResponseData: Decodable {
            var data: UsersWrapper
            struct UsersWrapper: Decodable {
                var update_users_by_pk: UpdatedUser
                struct UpdatedUser: Decodable {
                    var id: Int
                    var timezone: String
                }
            }
        }
        
        
        do {
            let response: UserMutationResponseData = try await Hasura.shared.sendGraphQL(query: mutationQuery, responseType: UserMutationResponseData.self)
            
            print("User timezone updated: \(response.data.update_users_by_pk.timezone) for user ID: \(response.data.update_users_by_pk.id)")
        } catch {
            print("Error: \(error.localizedDescription)")
            throw(error)
        }
    }
    
    static func generateQuery(userId: Int, isSubscription: Bool = false) -> String {
        let operationType = isSubscription ? "subscription" : "query"
        
        return """
        \(operationType) {
            users_by_pk(id: \(userId)) {
                timezone
            }
        }
        """
    }
    
}

struct UserModel: Decodable, Equatable {
    var timezone: String?
    
    enum CodingKeys: String, CodingKey {
        case timezone
    }
}
