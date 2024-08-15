//
//  ActionTypeHasuraM.swift
//  History
//
//  Created by Nathik Azad on 8/14/24.
//

import Foundation
struct ActionTypeMetadataForHasura: Codable {
    var staticFields: ActionModelTypeStaticSchema
    var dynamicFields: [String: Schema]
    var internalObjects: [String: ObjectTypeModel]
    
    enum CodingKeys: String, CodingKey {
        case staticFields, dynamicFields, internalObjects, aggregates
    }
    
    init(staticFields: ActionModelTypeStaticSchema = ActionModelTypeStaticSchema(),
         dynamicFields: [String : Schema] = [:],
         internalObjects: [String : ObjectTypeModel] = [:]
    ) {
        self.staticFields = staticFields
        self.dynamicFields = dynamicFields
        self.internalObjects = internalObjects
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        staticFields = try container.decode(ActionModelTypeStaticSchema.self, forKey: .staticFields)
        dynamicFields = try container.decodeIfPresent([String: Schema].self, forKey: .dynamicFields) ?? [:]
        internalObjects = (try? container.decode([String: ObjectTypeModel].self, forKey: .internalObjects)) ?? [:]
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(staticFields, forKey: .staticFields)
        try container.encode(dynamicFields, forKey: .dynamicFields)
        try container.encode(internalObjects, forKey: .internalObjects)
    }
}

class ActionTypeMeta: ObservableObject, Codable {
    @Published var hasDuration: Bool
    var description: String?
    
    enum CodingKeys: String, CodingKey {
        case hasDuration, description, color
    }
    
    init(hasDuration: Bool = true, description: String? = nil) {
        self.hasDuration = hasDuration
        self.description = description
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        hasDuration = try container.decode(Bool.self, forKey: .hasDuration)
        description = try container.decodeIfPresent(String.self, forKey: .description)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(hasDuration, forKey: .hasDuration)
        try container.encodeIfPresent(description, forKey: .description)
    }
}
