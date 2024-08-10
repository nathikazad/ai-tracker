//
//  ModelObjec.swift
//  History
//
//  Created by Nathik Azad on 8/8/24.
//

import Foundation

class ObjectTypeModel: Observable, Codable, ObservableObject {
    @Published var id: Int?
    @Published var name: String
    @Published var description: String
    @Published var fields: [String: Schema]
    
    enum CodingKeys: String, CodingKey {
        case name, description, fields, id, metadata
    }
    
    init(name: String, description: String, fields: [String : Schema]) {
        self.name = name
        self.description = description
        self.fields = fields
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        let metadata = try container.decode(ObjectTypeMetadataForHasura.self, forKey: .metadata)
        fields = metadata.dynamicFields
        description = metadata.description
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(fields, forKey: .fields)
    }
    
    var getMetadataJson: [String: Any] {
        let metadata: ObjectTypeMetadataForHasura = ObjectTypeMetadataForHasura(
            dynamicFields: fields, description: description
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

struct ObjectTypeMetadataForHasura: Codable {
    var dynamicFields: [String: Schema]
    var description: String
    enum CodingKeys: String, CodingKey {
        case dynamicFields
        case description
    }
    
    init(dynamicFields: [String : Schema] = [:], description: String = "") {
        self.dynamicFields = dynamicFields
        self.description = description
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        dynamicFields = try container.decodeIfPresent([String: Schema].self, forKey: .dynamicFields) ?? [:]
        description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(dynamicFields, forKey: .dynamicFields)
        try container.encode(description, forKey: .description)
    }
}
