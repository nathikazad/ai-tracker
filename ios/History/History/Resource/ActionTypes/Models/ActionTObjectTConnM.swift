//
//  ActionTObjectTConn.swift
//  History
//
//  Created by Nathik Azad on 8/14/24.
//

import Foundation
class ObjectConnection: Codable, ObservableObject {
    var id: Int
    @Published var name: String
    var actionTypeId: Int
    var objectTypeId: Int
    var objectType: ObjectTypeModel?
    
    enum CodingKeys: String, CodingKey {
        case id
        case metadata
        case objectTypeId = "object_type_id"
        case actionTypeId = "action_type_id"
        case objectType = "object_type"
    }
    
    init(
        id: Int,
        name: String,
        objectTypeId: Int,
        actionTypeId: Int
    ) {
            self.name = name
            self.objectTypeId = objectTypeId
            self.id = id
            self.actionTypeId = actionTypeId
        }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        let metadata = try container.decode(ActionTypeConnectionMetadataForHasura.self, forKey: .metadata)
        name = metadata.name
        objectTypeId = try container.decode(Int.self, forKey: .objectTypeId)
        actionTypeId = try container.decode(Int.self, forKey: .actionTypeId)
        objectType = try container.decodeIfPresent(ObjectTypeModel.self, forKey: .objectType)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        let metadata = ActionTypeConnectionMetadataForHasura(
            name: name
        )
        try container.encode(metadata, forKey: .metadata)
    }
    
    var metadataToHasura: ActionTypeConnectionMetadataForHasura {
        let metadata = ActionTypeConnectionMetadataForHasura(
            name: name
        )
        return metadata
    }
}


struct ActionTypeConnectionMetadataForHasura: Codable {
    var name: String
    
    enum CodingKeys: String, CodingKey {
        case name
    }
    
    init(name: String) {
        self.name = name
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
    }
    
    var toJson: [String: Any] {
        let encoder = JSONEncoder()
        if let metadataJson = try? encoder.encode(self),
           let metadataDict = try? JSONSerialization.jsonObject(with: metadataJson, options: []) as? [String: Any] {
            return metadataDict
        } else {
            return [:]
        }
    }
}
