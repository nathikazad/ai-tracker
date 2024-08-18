//
//  ObjectConnectionM.swift
//  History
//
//  Created by Nathik Azad on 8/16/24.
//

import Foundation
struct ObjectAction: Codable {
    let id: Int?
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
    
    init(id: Int? = nil, objectTypeActionTypeId: Int, objectId: Int, objectName: String) {
        self.id = id
        self.objectTypeActionTypeId = objectTypeActionTypeId
        self.objectId = objectId
        self.objectName = objectName
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int.self, forKey: .id)
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


extension Dictionary where Key == Int, Value == [ObjectAction] {
    mutating func addObjectAction(_ action: ObjectAction, forId id: Int) {
        if self[id] != nil {
            // Entry exists, append the action
            self[id]?.append(action)
        } else {
            // No entry exists, create a new array with the action
            self[id] = [action]
        }
    }
    
    mutating func removeObjectAction(objectId: Int, forId id: Int) {
        print("id:\(id) objectId:\(objectId)")
        guard var actions = self[id] else {
            return
        }
        actions.removeAll { $0.objectId == objectId }
        self[id] = actions
    }
}
