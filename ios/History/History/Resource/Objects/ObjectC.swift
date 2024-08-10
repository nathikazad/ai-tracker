//
//  ObjectController.swift
//  History
//
//  Created by Nathik Azad on 7/25/24.
//

import Foundation

class ObjectV2Controller {
    static func createObjectModel(model: ObjectModel) async -> Int? {
        var hasuraStruct: HasuraMutation = HasuraMutation(
            mutationFor: "insert_objects_one",
            mutationName: "ObjectModelMutation",
            mutationType: .create)
        hasuraStruct.addParameter(name: "user_id", type: .int, value: Authentication.shared.userId!)
        hasuraStruct.addParameter(name: "object_type_id", type: .int, value: model.objectTypeId)

        hasuraStruct.addParameter(name: "name", type: .string, value: model.name)
        hasuraStruct.addParameter(name: "fields", type: .jsonb, value: model.fields.toJson)
        
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
            print(error)
            print("Failed to create Object: \(error.localizedDescription)")
            return nil
        }
    }
    
    static func updateObjectModel(model: ObjectModel) async {
        guard let id = model.id else {
            print("Cannot update Object without an id")
            return
        }
        
        var hasuraMutation: HasuraMutation = HasuraMutation(
            mutationFor: "update_objects_by_pk",
            mutationName: "UpdateObjectModelMutation",
            mutationType: .update,
            id: id
        )
        
        hasuraMutation.addParameter(name: "object_type_id", type: .int, value: model.objectTypeId)
        hasuraMutation.addParameter(name: "name", type: .string, value: model.name)
        hasuraMutation.addParameter(name: "fields", type: .jsonb, value: model.fields.toJson)
        
        let (graphqlQuery, variables) = hasuraMutation.getMutationAndVariables
        struct UpdateObjectResponse: GraphQLData {
            var update_objects_by_pk: UpdatedObject
            struct UpdatedObject: Decodable {
                var id: Int
            }
        }
        
        do {
            let _: GraphQLResponse<UpdateObjectResponse> = try await Hasura.shared.sendGraphQL(
                query: graphqlQuery,
                variables: variables,
                responseType: GraphQLResponse<UpdateObjectResponse>.self
            )
        } catch {
            print(error)
            print("Failed to update Object: \(error.localizedDescription)")
        }
    }
    
    static func deleteObjectModel(id: Int) async {
        let hasuraMutation: HasuraMutation = HasuraMutation(
            mutationFor: "delete_objects_by_pk",
            mutationName: "DeleteObjectModelMutation",
            mutationType: .delete,
            id: id
        )
        
        let (graphqlQuery, variables) = hasuraMutation.getMutationAndVariables
        
        struct DeleteObjectResponse: GraphQLData {
            var delete_objects_by_pk: DeletedObject
            struct DeletedObject: Decodable {
                var id: Int
            }
        }
        
        do {
            let _: GraphQLResponse<DeleteObjectResponse> = try await Hasura.shared.sendGraphQL(
                query: graphqlQuery,
                variables: variables,
                responseType: GraphQLResponse<DeleteObjectResponse>.self
            )
        } catch {
            print("Failed to delete Object: \(error.localizedDescription)")
        }
    }
    
    static func fetchObjects(userId: Int, objectId: Int? = nil, objectTypeId: Int? = nil) async -> [ObjectModel] {
        let (graphqlQuery, variables) = generateQueryForObjects(userId: userId, objectId: objectId, objectTypeId: objectTypeId)
        struct ObjectData: GraphQLData {
            var objects: [ObjectModel]
        }
        do {
            let responseData: GraphQLResponse<ObjectData> = try await Hasura.shared.sendGraphQL(query: graphqlQuery, variables: variables, responseType: GraphQLResponse<ObjectData>.self)
            return responseData.data.objects
        } catch {
            print(graphqlQuery, variables)
            print(error)
            print("Failed to fetch Objects: \(error.localizedDescription)")
            return []
        }
    }
    
    static func listenToObjects(userId: Int, subscriptionId: String, objectId: Int? = nil, objectTypeId: Int? = nil, forDate: Date? = nil, objectUpdateCallback: @escaping ([ObjectModel]) -> Void) {
        Hasura.shared.stopListening(subscriptionId: subscriptionId)
        let (subscriptionQuery, variables) = generateQueryForObjects(userId: userId, objectId: objectId, objectTypeId: objectTypeId, isSubscription: true)
        struct ObjectData: GraphQLData {
            var objects: [ObjectModel]
        }
        
        Hasura.shared.startListening(subscriptionId: subscriptionId, subscriptionQuery: subscriptionQuery, responseType: GraphQLResponse<ObjectData>.self, variables: variables) { result in
            switch result {
            case .success(let responseData):
                let Objects = responseData.data.objects
                objectUpdateCallback(Objects)
            case .failure(let error):
                print("Error processing Object update: \(error.localizedDescription)")
            }
        }
    }
    
    static private func generateQueryForObjects(userId: Int, objectId: Int?, objectTypeId: Int? = nil, isSubscription:Bool = false) -> (String, [String: Any]) {
        var hasuraStruct: HasuraQuery = HasuraQuery(queryFor: "objects", queryName: "ObjectsQuery", queryType: isSubscription ? .subscription : .query)
        hasuraStruct.addWhereClause(name: "user_id", type: .int, value: userId, op: .equals)
        
        if let objectId = objectId {
            hasuraStruct.addWhereClause(name: "id", type: .int, value: objectId, op: .equals)
        }
        if let objectTypeId = objectTypeId {
            hasuraStruct.addWhereClause(name: "object_type_id", type: .int, value: objectTypeId, op: .equals)
        }
        hasuraStruct.setSelections(selections: ObjectSelections)
        return hasuraStruct.getQueryAndVariables
    }
    
    static var ObjectSelections: String {
        return """
            id
            name
            fields
            object_type_id
            object_type {
                \(ObjectTypeController.objectTypeSelections())
            }
        """
    }
}
