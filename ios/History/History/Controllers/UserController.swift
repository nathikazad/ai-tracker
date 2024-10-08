//
//  UserController.swift
//  History
//
//  Created by Nathik Azad on 4/10/24.
//

import Foundation
class UserController: ObservableObject {
    static var user:UserModel?
    struct ResponseData: Decodable {
        var data: UsersWrapper
    }
    
    struct UsersWrapper: Decodable {
        var users_by_pk: UserModel
    }
    
    static func ensureUserTimezone() async {
        do {
            let user = auth.user!
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
        let graphqlQuery = generateQuery(userId: auth.userId!)
        
        do {
            let responseData: ResponseData = try await Hasura.shared.sendGraphQL(query: graphqlQuery, responseType: ResponseData.self)
            user = responseData.data.users_by_pk
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
            update_users_by_pk(pk_columns: {id: \(auth.userId!)}, _set: {timezone: \"\(timezone)\"}) {
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
    
    static func updateUserAPNSToken(token: String?) async {
        let tokenValue = token != nil ? "\"\(token!)\"" : "null"
        
        let mutationQuery = """
        mutation {
            update_users_by_pk(pk_columns: {id: \(auth.userId!)}, _set: {apns_token: \(tokenValue)}) {
                id
                apns_token
            }
        }
        """
        
        struct UserMutationResponseData: Decodable {
            var data: UsersWrapper
            struct UsersWrapper: Decodable {
                var update_users_by_pk: UpdatedUser
                struct UpdatedUser: Decodable {
                    var id: Int
                    var apns_token: String?
                }
            }
        }
        
        do {
            let response: UserMutationResponseData = try await Hasura.shared.sendGraphQL(query: mutationQuery, responseType: UserMutationResponseData.self)
            
            if let token = response.data.update_users_by_pk.apns_token {
                print("User APNS token updated: \(token) for user ID: \(response.data.update_users_by_pk.id)")
            } else {
                print("User APNS token unset for user ID: \(response.data.update_users_by_pk.id)")
            }
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    static func generateQuery(userId: Int, isSubscription: Bool = false) -> String {
        let operationType = isSubscription ? "subscription" : "query"
        return """
        \(operationType) {
            users_by_pk(id: \(userId)) {
                timezone
                apns_token
            }
        }
        """
    }
    
}

struct UserModel: Decodable {
    var timezone: String?
    var deviceToken: String?
    
    enum CodingKeys: String, CodingKey {
        case timezone
        case deviceToken = "apns_token"
    }
}

//struct UserConfig: Decodable {
//    var healthKit: HealthKitConfig?
//    enum CodingKeys: String, CodingKey {
//        case healthKit
//    }
//}
//
//struct HealthKitConfig: Decodable {
//    var trackSleep: Bool?
//    var lastSleepEventStartTime: Date?
//    enum CodingKeys: String, CodingKey {
//        case trackSleep
//        case lastSleepEventStartTime = "last_sleep_event_start_time"
//    }
//    
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        trackSleep = try container.decode(Bool.self, forKey: .trackSleep)
//        let timeString = try container.decodeIfPresent(String.self, forKey: .lastSleepEventStartTime)
//        lastSleepEventStartTime = HasuraUtil.getTime(timestamp: timeString)
//    }
//}
