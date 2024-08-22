//
//  AdminUsersC.swift
//  History
//
//  Created by Nathik Azad on 8/21/24.
//

import Foundation
class AdminUserController {
    static func fetchUsers() async -> [UserModel] {
        let (graphqlQuery, variables) = generateQueryForUsers()
        
        struct UserData: GraphQLData {
            var users: [UserModel]
        }
        
        do {
            let responseData: GraphQLResponse<UserData> = try await Hasura.shared.sendGraphQL(
                query: graphqlQuery,
                variables: variables,
                responseType: GraphQLResponse<UserData>.self
            )
            return responseData.data.users
        } catch {
            print(graphqlQuery, variables)
            print(error)
            print("Failed to fetch Users: \(error.localizedDescription)")
            return []
        }
    }
    
    static func deleteUser(id: Int) async -> Bool {
        let hasuraMutation: HasuraMutation = HasuraMutation(
            mutationFor: "delete_users_by_pk",
            mutationName: "DeleteUserMutation",
            mutationType: .delete,
            id: id
        )
        
        let (graphqlQuery, variables) = hasuraMutation.getMutationAndVariables
        
        struct DeleteUserResponse: GraphQLData {
            var delete_users_by_pk: DeletedUser?
            
            struct DeletedUser: Decodable {
                var id: Int
            }
        }
        
        do {
            let responseData: GraphQLResponse<DeleteUserResponse> = try await Hasura.shared.sendGraphQL(
                query: graphqlQuery,
                variables: variables,
                responseType: GraphQLResponse<DeleteUserResponse>.self
            )
            return responseData.data.delete_users_by_pk != nil
        } catch {
            print(graphqlQuery, variables)
            print(error)
            print("Failed to delete User: \(error.localizedDescription)")
            return false
        }
    }
    
    
    
    static private func generateQueryForUsers() -> (String, [String: Any]) {
        var hasuraStruct: HasuraQuery = HasuraQuery(
            queryFor: "users",
            queryName: "UsersQuery",
            queryType: .query
        )
        
        hasuraStruct.setSelections(selections: UserSelections)
        return hasuraStruct.getQueryAndVariables
    }
    
    static var UserSelections: String {
        return """
            id
            name
            timezone
        """
    }
    
    struct UserModel: Codable, Identifiable {
        let id: Int
        let name: String
        let timezone: String
    }
}


