//
//  ActionModel.swift
//  History
//
//  Created by Nathik Azad on 7/22/24.
//

import Foundation

class ActionTypeModel: ObservableObject {
    var id: Int?
    @Published var name: String
    @Published var meta: ActionTypeMeta
    var staticFields: ActionModelTypeStaticSchema
    @Published var dynamicFields: [String: Schema]
    @Published var internalObjects: [String: InternalObject]
    var aggregates: [String: Aggregate]
    var computed: [String: Schema]
    
    var internalDataTypes: [String] {
        internalObjects.values.compactMap { $0.name }.sorted()
    }
    
    func copy(_ m: ActionTypeModel) {
        self.id = m.id
        self.name = m.name
        self.meta = m.meta
        self.staticFields = m.staticFields
        self.dynamicFields = m.dynamicFields
        self.aggregates = m.aggregates
    }
    
    init(
        id: Int? = nil,
        name: String,
        meta: ActionTypeMeta,
        staticFields: ActionModelTypeStaticSchema,
        dynamicFields: [String: Schema] = [:],
        computed: [String: Schema] = [:],
        internalObjects: [String: InternalObject] = [:],
        aggregates: [String: Aggregate] = [:],
        goals: [String: Any] = [:]) {
            self.id = id
            self.name = name
            self.meta = meta
            self.staticFields = staticFields
            self.dynamicFields = dynamicFields
            self.computed = computed
            self.internalObjects = internalObjects
            self.aggregates = aggregates
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
    
    enum CodingKeys: String, CodingKey {
        case name, dataType, description, array, enumValues, objectFields
    }
    
    init(name: String, dataType: String, description: String,
         array: Bool = false,
         enumValues: [String] = [],
         objectFields: [String : Schema] = [:]) {
        self.name = name
        self.dataType = dataType
        self.description = description
        self.array = array
        self.enumValues = enumValues
        self.objectFields = objectFields
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
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




