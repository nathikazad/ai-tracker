//
//  ObjectConnectionM.swift
//  History
//
//  Created by Nathik Azad on 8/16/24.
//

import Foundation
struct ObjectAction: Codable {
    let id: Int
    let objectTypeActionTypeId: Int
    let objectId: Int
    let objectName: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case objectTypeActionTypeId = "object_t_action_t_id"
        case object
    }
    
    enum ObjectKeys: String, CodingKey {
        case id
        case name
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        objectTypeActionTypeId = try container.decode(Int.self, forKey: .objectTypeActionTypeId)
        let objectContainer = try container.nestedContainer(keyedBy: ObjectKeys.self, forKey: .object)
        objectId = try objectContainer.decode(Int.self, forKey: .id)
        objectName = try objectContainer.decode(String.self, forKey: .name)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(objectTypeActionTypeId, forKey: .objectTypeActionTypeId)
        var objectContainer = container.nestedContainer(keyedBy: ObjectKeys.self, forKey: .object)
        try objectContainer.encode(objectId, forKey: .id)
        try objectContainer.encode(objectName, forKey: .name)
    }
}
