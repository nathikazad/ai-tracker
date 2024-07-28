//
//  ActionTypeHasura.swift
//  History
//
//  Created by Nathik Azad on 7/26/24.
//

import Foundation

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
            computed: metadata.computed,
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

