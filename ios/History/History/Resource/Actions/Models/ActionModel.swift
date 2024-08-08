//
//  ActionModel.swift
//  History
//
//  Created by Nathik Azad on 7/24/24.
//

import Foundation

// ActionModel struct
import Foundation

extension Int {
    var fromSecondsToHHMMString: String {
        let hours = self / 3600
        let minutes = (self % 3600) / 60
        return String(format: "%02d:%02d", hours, minutes)
    }
}

class ActionModel: ObservableObject, Codable {
    @Published var id: Int?
    @Published var actionTypeId: Int
    @Published var startTime: Date
    @Published var endTime: Date?
    var parentId: Int?
    @Published var dynamicData: [String: AnyCodable]
    @Published var actionTypeModel: ActionTypeModel
    let createdAt: Date
    let updatedAt: Date
    
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
    
    var durationInSeconds: Int {
        guard let endTime = endTime else { return 0 }
        return Int(endTime.timeIntervalSince(startTime))
    }

    init(id: Int? = nil, actionTypeId: Int, startTime: Date, endTime: Date? = nil, parentId: Int? = nil, dynamicData: [String: AnyCodable] = [:], actionTypeModel: ActionTypeModel, createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.actionTypeId = actionTypeId
        self.startTime = startTime
        self.endTime = endTime
        self.parentId = parentId
        self.dynamicData = dynamicData
        self.actionTypeModel = actionTypeModel
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int.self, forKey: .id)
        actionTypeId = try container.decode(Int.self, forKey: .actionTypeId)
        let startTimeString = try container.decode(String.self, forKey: .startTime)
        startTime = startTimeString.getDate ?? Date()
        if let endTimeString = try container.decodeIfPresent(String.self, forKey: .endTime) {
            endTime = endTimeString.getDate
        } else {
            endTime = nil
        }
        parentId = try container.decodeIfPresent(Int.self, forKey: .parentId)
        dynamicData = try container.decode([String: AnyCodable].self, forKey: .dynamicData)
        let createdAtString = try container.decode(String.self, forKey: .createdAt)
        createdAt = createdAtString.getDate!
        let updatedAtString = try container.decode(String.self, forKey: .updatedAt)
        updatedAt = updatedAtString.getDate!
        actionTypeModel = try container.decode(ActionTypeModel.self, forKey: .actionType)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encode(actionTypeId, forKey: .actionTypeId)
        try container.encode(startTime.toUTCString, forKey: .startTime)
        try container.encodeIfPresent(endTime?.toUTCString, forKey: .endTime)
        try container.encodeIfPresent(parentId, forKey: .parentId)
        try container.encode(dynamicData, forKey: .dynamicData)
        try container.encode(createdAt.toUTCString, forKey: .createdAt)
        try container.encode(updatedAt.toUTCString, forKey: .updatedAt)
    }
    
    func copy(_ newModel: ActionModel) {
        self.id = newModel.id
        self.actionTypeId = newModel.actionTypeId
        self.startTime = newModel.startTime
        self.endTime = newModel.endTime
        self.parentId = newModel.parentId
        self.dynamicData = newModel.dynamicData
        self.actionTypeModel = newModel.actionTypeModel
    }
    
    var toString: String? {
        var description: String?
        if let shortDescSyntax = actionTypeModel.shortDescSyntax {
            description = self.dynamicData[shortDescSyntax]?.toString
        }
        
        if actionTypeModel.meta.hasDuration, durationInSeconds > 0 {
            if let desc = description {
                return "\(desc) (\(durationInSeconds.fromSecondsToHHMMString))"
            } else {
                return "(\(durationInSeconds.fromSecondsToHHMMString))"
            }
        } else {
            return description
        }
    }
}


