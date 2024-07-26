//
//  ActionController.swift
//  History
//
//  Created by Nathik Azad on 7/22/24.
//

import Foundation

let externalDataTypes: [String] = ["Expense", "Organization", "Item"]

func updateActionType(actionTypeModel: ActionTypeModel) async -> Int {
//    if let index = actionsTypes.firstIndex(where: { $0.name == actionTypeModel.name }) {
//        actionsTypes[index] = actionTypeModel
//    }
    return 1
}

func actionTypeModelMutation(userId: Int, model: ActionTypeModel, actionTypeId: Int?) async -> Int? {
    var hasuraStruct:HasuraMutation = HasuraMutation(
        mutationFor: "insert_action_types_one",
        mutationName: "ActionTypeModelMutation",
        mutationType: .create)
    hasuraStruct.addParameter(name: "user_id", type: "Int", value: userId)
    hasuraStruct.addParameter(name: "name", type: "String", value: model.name)
    hasuraStruct.addParameter(name: "hasDuration", type: "Boolean", value: model.meta.hasDuration)
    hasuraStruct.addParameter(name: "description", type: "String", value: model.meta.description)
    let metadata: ActionTypeMetadataForHasura = ActionTypeMetadataForHasura(
        staticFields: model.staticFields,
        internalObjects: model.internalObjects, aggregates: model.aggregates,
        computed: model.computed)
    hasuraStruct.addParameter(name: "metadata", type: "jsonb", value: metadata.toJSONDictionary())

    let (graphqlQuery, variables) = hasuraStruct.getMutationAndVariables
    
    struct CreateActionTypeResponse: GraphQLData {
        var insert_action_types_one: CreatedObject
        struct CreatedObject: Decodable {
            var id: Int
        }
    }
    
    do {
        let responseData: GraphQLResponse<CreateActionTypeResponse> = try await Hasura.shared.sendGraphQL(query: graphqlQuery, variables: variables, responseType: GraphQLResponse<CreateActionTypeResponse>.self)
        return responseData.data.insert_action_types_one.id
    } catch {
        // Log error details for debugging purposes
        print("Failed to create object: \(error.localizedDescription)")
        return nil
    }
}



func fetchActionTypes(userId: Int, actionTypeId: Int? = nil) async -> [ActionTypeModel] {
    let (graphqlQuery, variables) = generateQueryForActionTypes(userId: userId, actionTypeId: actionTypeId)
    struct ActionTypeData: GraphQLData {
        var action_types: [ActionTypeForHasura]
    }
    do {
//        let responseData2: Any = try await Hasura.shared.sendGraphQL(query: graphqlQuery, variables: variables)
        let responseData: GraphQLResponse<ActionTypeData> = try await Hasura.shared.sendGraphQL(query: graphqlQuery, variables: variables, responseType: GraphQLResponse<ActionTypeData>.self)
        return responseData.data.action_types.map { $0.toActionTypeModel() }
    } catch {
        print(error)
        print("Failed to fetch object: \(error.localizedDescription)")
        return []
    }
}

func generateQueryForActionTypes(userId: Int, actionTypeId: Int?) -> (String, [String: Any]) {
    var hasuraStruct:HasuraQuery = HasuraQuery(queryFor: "action_types", queryName: "ActionTypesQuery", queryType: .query)
    hasuraStruct.addParameter(name: "user_id", type: "Int", value: userId, op: "_eq")
    if (actionTypeId != nil) {
        hasuraStruct.addParameter(name: "id", type: "Int", value: actionTypeId, op: "_eq")
    }
    hasuraStruct.setSelections(selections:actionTypeSelections)
    return hasuraStruct.getQueryAndVariables
}

var actionTypeSelections: String {
    return """
        id
        created_at
        description
        hasDuration
        metadata
        name
        updated_at
        user_id
    """
}

struct ActionTypeForHasura: Codable {
    let id: Int
    let createdAt: Date
    let description: String
    let hasDuration: Bool
    let name: String
    let updatedAt: Date
    let userId: Int
    let metadata: ActionTypeMetadataForHasura
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case description
        case hasDuration
        case metadata
        case name
        case updatedAt = "updated_at"
        case userId = "user_id"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let createdAtString = try container.decodeIfPresent(String.self, forKey: .createdAt)
        createdAt = createdAtString!.getDate!
        id = try container.decode(Int.self, forKey: .id)
        description = try container.decode(String.self, forKey: .description)
        hasDuration = try container.decode(Bool.self, forKey: .hasDuration)
        name = try container.decode(String.self, forKey: .name)
        let updatedAtString = try container.decodeIfPresent(String.self, forKey: .updatedAt)
        updatedAt = updatedAtString!.getDate!
        userId = try container.decode(Int.self, forKey: .userId)
        metadata = try container.decodeIfPresent(ActionTypeMetadataForHasura.self, forKey: .metadata) ?? ActionTypeMetadataForHasura()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(description, forKey: .description)
        try container.encode(hasDuration, forKey: .hasDuration)
        try container.encode(name, forKey: .name)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encode(userId, forKey: .userId)
        try container.encode(metadata, forKey: .metadata)
    }
    
    func toActionTypeModel() -> ActionTypeModel {
        let meta = ActionTypeMeta(
            hasDuration: self.hasDuration, description: self.description
        )
        return ActionTypeModel(
            id: id,
            name: self.name,
            meta: meta,
            staticFields: metadata.staticFields,
            dynamicFields: metadata.dynamicFields,
            computed: [:],
            internalObjects: metadata.internalObjects,
            aggregates: metadata.aggregates
        )
    }
}

struct ActionTypeMetadataForHasura: Codable {
    var staticFields: ActionModelTypeStaticSchema
    var dynamicFields: [String: Schema]
    var internalObjects: [String: InternalObject]
    var aggregates: [String: Aggregate]
    var computed: [String: Schema]

    enum CodingKeys: String, CodingKey {
        case staticFields, dynamicFields, internalObjects, aggregates, computed
    }
    
    init(staticFields: ActionModelTypeStaticSchema = ActionModelTypeStaticSchema(),
         dynamicFields: [String : Schema] = [:],
         internalObjects: [String : InternalObject] = [:],
         aggregates: [String : Aggregate] = [:],
         computed: [String : Schema]  = [:]
    ) {
        self.staticFields = staticFields
        self.dynamicFields = dynamicFields
        self.internalObjects = internalObjects
        self.aggregates = aggregates
        self.computed = computed
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        staticFields = try container.decode(ActionModelTypeStaticSchema.self, forKey: .staticFields)
        dynamicFields = try container.decodeIfPresent([String: Schema].self, forKey: .dynamicFields) ?? [:]
        internalObjects = (try? container.decode([String: InternalObject].self, forKey: .internalObjects)) ?? [:]
        aggregates = (try? container.decode([String: Aggregate].self, forKey: .aggregates)) ?? [:]
        computed = (try? container.decode([String: Schema].self, forKey: .computed)) ?? [:]
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(staticFields, forKey: .staticFields)
        try container.encode(dynamicFields, forKey: .dynamicFields)
        try container.encode(internalObjects, forKey: .internalObjects)
        try container.encode(aggregates, forKey: .aggregates)
        try container.encode(computed, forKey: .computed)
    }
    
    func toJSONDictionary() -> [String: Any] {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(self)
            if let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
                return dictionary
            } else {
                print("Error: Could not convert encoded data to dictionary")
                return [:]
            }
        } catch {
            print("Error encoding to JSON: \(error)")
            return [:]
        }
    }
}



// finished: work on action view
// finished: work on action type view
// finished: work on action type create/edit
// working: put action type into database and then 
// finished: fetch it
// work on create/modify/delete action
// put action action into database and then fetch it

// RELASE
// work on object view
// work on object create/edit
// put object into database and then fetch it
// RELASE
// work on aggregates
// RELASE
// work on goals
// RELASE
// work on reminders
// RELASE
// integrate location
// RELASE
// integrate sleep
// RELASE
// integrate plaid
// RELEASE




