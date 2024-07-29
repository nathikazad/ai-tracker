//
//  AssociationController.swift
//  History
//
//  Created by Nathik Azad on 5/17/24.
//

import Foundation
class AssociationController {

    static func createEventObjectAssociation(userId: Int, eventId: Int, objectId: Int) async -> Int? {
        var hasuraStruct:HasuraMutation = HasuraMutation(mutationFor: "insert_associations_one", mutationName: "CreateAssociationMutation", mutationType: .create)
        hasuraStruct.addParameter(name: "user_id", type: .int, value: userId)
        hasuraStruct.addParameter(name: "ref_one_table", type: .string, value: "events")
        hasuraStruct.addParameter(name: "ref_one_id", type: .int, value: eventId)
        hasuraStruct.addParameter(name: "ref_two_table", type: .string, value: "objects")
        hasuraStruct.addParameter(name: "ref_two_id", type: .int, value: objectId)
        

        let (graphqlQuery, variables) = hasuraStruct.getMutationAndVariables
        struct CreateAssociationResponse: Decodable {
            var data: CreateAssociationWrapper
            struct CreateAssociationWrapper: Decodable {
                var insert_associations_one: CreatedAssociation
                struct CreatedAssociation: Decodable {
                    var id: Int
                }
            }
        }
        
        
        do {
            let responseData: CreateAssociationResponse = try await Hasura.shared.sendGraphQL(query: graphqlQuery, variables: variables, responseType: CreateAssociationResponse.self)
            return responseData.data.insert_associations_one.id
        } catch {
            // Log error details for debugging purposes
            print("Failed to create object: \(error.localizedDescription)")
            return nil
        }
    }
    
    
    static func deleteObjectAssociations(objectId: Int) async {
    }
    
    
    static func deleteAssociation(id: Int) async {
        let hasuraMutation: HasuraMutation = HasuraMutation(mutationFor: "delete_associations_by_pk", mutationName: "AssociationDeletion", mutationType: .delete, id: id)
        let (graphqlQuery, variables) = hasuraMutation.getMutationAndVariables
        struct DeleteMutationResult: GraphQLData {
            var delete_associations_by_pk: DeletedAssociation
            struct DeletedAssociation: Decodable {
                var id: Int
            }
        }
        
        do {
            let _: GraphQLResponse<DeleteMutationResult> = try await Hasura.shared.sendGraphQL(query: graphqlQuery, variables: variables, responseType: GraphQLResponse<DeleteMutationResult>.self)
        } catch {
            // Log error details for debugging purposes
            print("Failed to mutate object: \(error.localizedDescription)")
        }
    }
}


