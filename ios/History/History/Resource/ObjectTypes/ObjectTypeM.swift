//
//  ModelObjec.swift
//  History
//
//  Created by Nathik Azad on 8/8/24.
//

import Foundation

class ObjectType: Observable, Codable {
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
