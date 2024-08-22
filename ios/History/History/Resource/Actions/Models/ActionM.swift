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
extension Date {
    func convertUTCToLocalPreservingTime(originalTimeZone: TimeZone) -> Date {
        let localTimeZone = TimeZone.current
        let offsetSeconds = localTimeZone.secondsFromGMT() - originalTimeZone.secondsFromGMT()
        let adjustedDate = self.addingTimeInterval(TimeInterval(-offsetSeconds))
        return adjustedDate
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
    @Published var objectConnections: [Int:[ObjectAction]] = [:] //Int is the actionTypeObjectTypeId
    @Published var children: [Int:[ActionModel]] = [:]
    @Published var parent: ActionModel? = nil
    var timezone: TimeZone
    
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
        case objectActions = "object_actions"
        case children = "children"
        case parent = "parent"
        case timezone
    }
    
    var durationInSeconds: Int {
        guard let endTime = endTime else { return 0 }
        return Int(endTime.timeIntervalSince(startTime))
    }

    init(id: Int? = nil, actionTypeId: Int, startTime: Date = Date(), endTime: Date? = nil, parentId: Int? = nil, dynamicData: [String: AnyCodable] = [:], actionTypeModel: ActionTypeModel = ActionTypeModel(name: "Unknown"), createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.actionTypeId = actionTypeId
        self.startTime = startTime
        self.endTime = endTime
        self.parentId = parentId
        self.dynamicData = dynamicData
        self.actionTypeModel = actionTypeModel
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.timezone = TimeZone.current
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int.self, forKey: .id)
        actionTypeId = try container.decode(Int.self, forKey: .actionTypeId)
        let timezoneIdentifier = try container.decode(String.self, forKey: .timezone)
        timezone = TimeZone(identifier: timezoneIdentifier)!
        let startTimeString = try container.decode(String.self, forKey: .startTime)
        
        startTime = startTimeString.getDate?.convertUTCToLocalPreservingTime(originalTimeZone: timezone) ?? Date()
        if let endTimeString = try container.decodeIfPresent(String.self, forKey: .endTime) {
            endTime = endTimeString.getDate?.convertUTCToLocalPreservingTime(originalTimeZone: timezone)
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
        let connections = try container.decodeIfPresent([ObjectAction].self, forKey: .objectActions) ?? []
        objectConnections = Dictionary(grouping: connections, by: { $0.objectTypeActionTypeId })
        
        let childrenNode = try container.decodeIfPresent([ActionModel].self, forKey: .children) ?? []
        children = Dictionary(grouping: childrenNode, by: { $0.actionTypeId })
        parent = try container.decodeIfPresent(ActionModel.self, forKey: .parent)
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
        self.objectConnections = newModel.objectConnections
        self.children = newModel.children
        self.parent = newModel.parent
    }
    
    var duplicate: ActionModel {
        let actionTypeModel = ActionModel(actionTypeId: self.actionTypeId, startTime: self.startTime, actionTypeModel: self.actionTypeModel)
        actionTypeModel.copy(self)
        return actionTypeModel
    }
    
    var toString: String {
        var description: String = ""
        if let name = objectConnections.first?.value.first?.objectName {
            description = name
        } else if let shortDescSyntax = actionTypeModel.shortDescSyntax {
            description = self.dynamicData[shortDescSyntax]?.toString ?? ""
        }
        
        
        
        return description
    }
}


extension Dictionary where Key == Int, Value == [ActionModel] {
    mutating func addChild(_ child: ActionModel, forId id: Int) {
        if self[id] != nil {
            // Entry exists, append the action
            self[id]?.append(child)
        } else {
            // No entry exists, create a new array with the action
            self[id] = [child]
        }
    }
    
    mutating func removeChild(childId: Int, forId id: Int) {
        guard var actions = self[id] else {
            return
        }
        actions.removeAll { $0.id == childId }
        self[id] = actions
    }
}

extension ActionModel {
    
    var formattedTime: String {
        if let endTime = endTime  {
            return "\(startTime.formattedTime) - \(endTime.formattedTime)"
        } else {
            return  "\(startTime.formattedTime)"
        }
    }

    func formattedTimeWithReferenceDate(_ referenceDate: Date) -> String {
        let formattedStartTime = startTime.formattedTimeWithReferenceDate(referenceDate)
        if (endTime != nil) {
            let formattedEndTime = endTime!.formattedTimeWithReferenceDate(referenceDate)
            return "\(formattedStartTime) - \(formattedEndTime)"
        } else {
            return "\(formattedStartTime)"
        }
    }
    
    var formattedDate: String {
        return "\(startTime.formattedDate)"
    }
    
    var date: Date {
        return startTime
    }
    
    var formattedTimeWithDate: String {
        return "\(formattedDate): \(formattedTime)"
    }
    
    var totalHoursPerDay: TimeInterval? {
        if(endTime == nil){
            return nil
        }
        return endTime!.timeIntervalSince(startTime)
    }
    
    var timeTaken: String? {
        if endTime != nil {
            return startTime.durationInHHMM(to: endTime!)
        } else {
            return nil
        }
    }
}
