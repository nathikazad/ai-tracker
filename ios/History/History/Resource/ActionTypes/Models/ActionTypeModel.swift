//
//  ActionModel.swift
//  History
//
//  Created by Nathik Azad on 7/22/24.
//

import Foundation

import Foundation

class ActionTypeModel: ObservableObject, Codable {
    @Published var id: Int?
    @Published var name: String
    @Published var meta: ActionTypeMeta
    var staticFields: ActionModelTypeStaticSchema
    @Published var dynamicFields: [String: Schema]
    @Published var internalObjects: [String: InternalObject]
    @Published var aggregates: [AggregateModel]
    var computed: [String: Schema]
    var shortDescSyntax: String?
    let createdAt: Date
    let updatedAt: Date
    
    var internalDataTypes: [String] {
        internalObjects.values.compactMap { $0.name }.sorted()
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, metadata, staticFields, dynamicFields, internalObjects, computed, shortDescSyntax
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case hasDuration = "has_duration"
        case description = "description"
        case aggregates = "aggregates"
    }
    
    init(id: Int? = nil,
         name: String,
         meta: ActionTypeMeta = ActionTypeMeta(),
         staticFields: ActionModelTypeStaticSchema = ActionModelTypeStaticSchema(),
         dynamicFields: [String: Schema] = [:],
         computed: [String: Schema] = [:],
         internalObjects: [String: InternalObject] = [:],
         aggregates: [AggregateModel] = [],
         shortDescSyntax: String? = nil,
         createdAt: Date = Date(),
         updatedAt: Date = Date()) {
        self.id = id
        self.name = name
        self.meta = meta
        self.staticFields = staticFields
        self.dynamicFields = dynamicFields
        self.computed = computed
        self.internalObjects = internalObjects
        self.shortDescSyntax = shortDescSyntax
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.aggregates = aggregates
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        meta = try ActionTypeMeta(
            hasDuration: container.decode(Bool.self, forKey: .hasDuration),
            description: container.decode(String.self, forKey: .description)
        )
        let metadata = try container.decode(ActionTypeMetadataForHasura.self, forKey: .metadata)
        staticFields = metadata.staticFields
        dynamicFields = metadata.dynamicFields
        internalObjects = metadata.internalObjects
        computed = metadata.computed
        shortDescSyntax = try container.decodeIfPresent(String.self, forKey: .shortDescSyntax)
        let createdAtString = try container.decode(String.self, forKey: .createdAt)
        createdAt = createdAtString.getDate!
        let updatedAtString = try container.decode(String.self, forKey: .updatedAt)
        updatedAt = updatedAtString.getDate!
        self.aggregates = try container.decodeIfPresent([AggregateModel].self, forKey: .aggregates) ?? []
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(meta.hasDuration, forKey: .hasDuration)
        try container.encode(meta.description, forKey: .description)
        let metadata = ActionTypeMetadataForHasura(
            staticFields: staticFields,
            dynamicFields: dynamicFields,
            internalObjects: internalObjects,
            computed: computed
        )
        try container.encode(metadata, forKey: .metadata)
        try container.encodeIfPresent(shortDescSyntax, forKey: .shortDescSyntax)
        try container.encode(createdAt.toUTCString, forKey: .createdAt)
        try container.encode(updatedAt.toUTCString, forKey: .updatedAt)
    }
    
    func copy(_ m: ActionTypeModel) {
        self.id = m.id
        self.name = m.name
        self.meta = m.meta
        self.staticFields = m.staticFields
        self.dynamicFields = m.dynamicFields
        self.internalObjects = m.internalObjects
        self.computed = m.computed
        self.shortDescSyntax = m.shortDescSyntax
        self.aggregates = m.aggregates
    }
    
    var getMetadataJson: [String: Any] {
        let metadata: ActionTypeMetadataForHasura = ActionTypeMetadataForHasura(
            staticFields: staticFields,
            dynamicFields: dynamicFields,
            internalObjects: internalObjects,
            computed: computed
        )
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(metadata)
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

struct ActionTypeMetadataForHasura: Codable {
    var staticFields: ActionModelTypeStaticSchema
    var dynamicFields: [String: Schema]
    var internalObjects: [String: InternalObject]
    var computed: [String: Schema]
    
    enum CodingKeys: String, CodingKey {
        case staticFields, dynamicFields, internalObjects, aggregates, computed
    }
    
    init(staticFields: ActionModelTypeStaticSchema = ActionModelTypeStaticSchema(),
         dynamicFields: [String : Schema] = [:],
         internalObjects: [String : InternalObject] = [:],
         computed: [String : Schema]  = [:]
    ) {
        self.staticFields = staticFields
        self.dynamicFields = dynamicFields
        self.internalObjects = internalObjects
        self.computed = computed
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        staticFields = try container.decode(ActionModelTypeStaticSchema.self, forKey: .staticFields)
        dynamicFields = try container.decodeIfPresent([String: Schema].self, forKey: .dynamicFields) ?? [:]
        internalObjects = (try? container.decode([String: InternalObject].self, forKey: .internalObjects)) ?? [:]
        computed = (try? container.decode([String: Schema].self, forKey: .computed)) ?? [:]
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(staticFields, forKey: .staticFields)
        try container.encode(dynamicFields, forKey: .dynamicFields)
        try container.encode(internalObjects, forKey: .internalObjects)
        try container.encode(computed, forKey: .computed)
    }
}

class ActionTypeMeta: ObservableObject, Codable {
    @Published var hasDuration: Bool
    var description: String?
    
    enum CodingKeys: String, CodingKey {
        case hasDuration, description
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

class ActionModelTypeStaticSchema: Codable {
    var startTime: Schema?
    var endTime: Schema?
    var time: Schema?
    var parentId: Schema?
    
    enum CodingKeys: String, CodingKey {
        case startTime, endTime, time, parentId
    }
    
    init(startTime: Schema? = nil, endTime: Schema? = nil, time: Schema? = nil, parentId: Schema? = nil) {
        self.startTime = startTime
        self.endTime = endTime
        self.time = time
        self.parentId = parentId
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        startTime = try container.decodeIfPresent(Schema.self, forKey: .startTime)
        endTime = try container.decodeIfPresent(Schema.self, forKey: .endTime)
        time = try container.decodeIfPresent(Schema.self, forKey: .time)
        parentId = try container.decodeIfPresent(Schema.self, forKey: .parentId)
    }
}

class Schema: Codable {
    var name: String
    var dataType: String
    var description: String
    var array: Bool
    var enumValues: [String]
    var objectFields: [String: Schema]
    var rank: Int = 0
    
    enum CodingKeys: String, CodingKey {
        case name, dataType, description, array, enumValues, objectFields, rank
    }
    
    var getEnums: [String] {
        if(!enumValues.isEmpty) {
            return enumValues
        } else {
            return ["None"]
        }
    }
    
    
    init(name: String, dataType: String, description: String,
         array: Bool = false,
         enumValues: [String] = [],
         objectFields: [String : Schema] = [:],
         rank: Int = 0) {
        self.name = name
        self.dataType = dataType
        self.description = description
        self.array = array
        self.enumValues = enumValues
        self.objectFields = objectFields
        self.rank = rank
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        rank = try container.decodeIfPresent(Int.self, forKey: .rank) ?? 0
        dataType = try container.decode(String.self, forKey: .dataType)
        description = try container.decode(String.self, forKey: .description)
        array = try container.decodeIfPresent(Bool.self, forKey: .array) ?? false
        enumValues = try container.decodeIfPresent([String].self, forKey: .enumValues) ?? []
        objectFields = try container.decodeIfPresent([String: Schema].self, forKey: .objectFields) ?? [:]
    }
}

class InternalObject: Observable, Codable {
    var name: String
    var description: String
    @Published var fields: [String: Schema]
    
    enum CodingKeys: String, CodingKey {
        case name, description, fields
    }
    
    init(name: String, description: String, fields: [String : Schema]) {
        self.name = name
        self.description = description
        self.fields = fields
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        fields = try container.decode([String: Schema].self, forKey: .fields)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(fields, forKey: .fields)
    }
}




