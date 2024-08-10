//
//  ModelObjec.swift
//  History
//
//  Created by Nathik Azad on 8/8/24.
//

import Foundation

class ObjectModel: Observable, Codable, ObservableObject {
    @Published var id: Int?
    @Published var name: String
    @Published var fields: [String: AnyCodable]
    @Published var objectTypeId: Int
    @Published var objectTypeModel: ObjectTypeModel
    
    enum CodingKeys: String, CodingKey {
        case id, name, fields
        case objectTypeId = "object_type_id"
        case objectType = "object_type"
    }
    
    init(objectTypeId: Int, objectType: ObjectTypeModel, name: String = "", fields: [String : AnyCodable] = [:]) {
        self.name = name
        self.fields = fields
        self.objectTypeId = objectTypeId
        self.objectTypeModel = objectType
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        objectTypeId = try container.decode(Int.self, forKey: .objectTypeId)
        objectTypeModel = try container.decode(ObjectTypeModel.self, forKey: .objectType)
        fields = try container.decode([String : AnyCodable].self, forKey: .fields)
        for field in objectTypeModel.fields {
            if fields[field.key] == nil {
                fields[field.key] = field.value.dataType.getInitAnyCodable()
            }
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(fields, forKey: .fields)
    }
    
    func copy(_ newModel: ObjectModel) {
        self.id = newModel.id
        self.objectTypeId = newModel.objectTypeId
        self.fields = newModel.fields
        self.objectTypeModel = newModel.objectTypeModel
        self.name = newModel.name
    }
}

