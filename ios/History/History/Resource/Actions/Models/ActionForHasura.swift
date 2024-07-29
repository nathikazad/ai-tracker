//
//  ActionHasura.swift
//  History
//
//  Created by Nathik Azad on 7/27/24.
//

import Foundation
struct ActionForHasura: Codable {
    let id: Int
    let actionTypeId: Int
    let startTime: String
    let endTime: String?
    let parentId: Int?
    let dynamicData: [String: AnyCodable]
    let createdAt: Date
    let updatedAt: Date
    let userId: Int
    let actionType: ActionTypeForHasura

    enum CodingKeys: String, CodingKey {
        case id
        case actionTypeId = "action_type_id"
        case startTime = "start_time"
        case endTime = "end_time"
        case parentId = "parent_id"
        case dynamicData = "dynamic_data"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case userId = "user_id"
        case actionType = "action_type"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        actionTypeId = try container.decode(Int.self, forKey: .actionTypeId)
        startTime = try container.decode(String.self, forKey: .startTime)
        endTime = try container.decodeIfPresent(String.self, forKey: .endTime)
        parentId = try container.decodeIfPresent(Int.self, forKey: .parentId)
        dynamicData = try container.decode([String: AnyCodable].self, forKey: .dynamicData)
        let createdAtString = try container.decode(String.self, forKey: .createdAt)
        createdAt = createdAtString.getDate!
        let updatedAtString = try container.decode(String.self, forKey: .updatedAt)
        updatedAt = updatedAtString.getDate!
        userId = try container.decode(Int.self, forKey: .userId)
        actionType = try container.decode(ActionTypeForHasura.self, forKey: .actionType)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(actionTypeId, forKey: .actionTypeId)
        try container.encodeIfPresent(startTime, forKey: .startTime)
        try container.encodeIfPresent(endTime, forKey: .endTime)
        try container.encodeIfPresent(parentId, forKey: .parentId)
        try container.encode(dynamicData, forKey: .dynamicData)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encode(userId, forKey: .userId)
    }

    func toActionModel() -> ActionModel {
        return ActionModel(
            id: id,
            actionTypeId: actionTypeId,
            startTime: startTime,
            endTime: endTime,
            parentId: parentId,
            dynamicData: dynamicData,
            actionTypeModel: actionType.toActionTypeModel()
        )
    }
}
