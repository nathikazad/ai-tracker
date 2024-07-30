//
//  ActionModel.swift
//  History
//
//  Created by Nathik Azad on 7/24/24.
//

import Foundation

// ActionModel struct
class ActionModel: ObservableObject {
    var id: Int?
    @Published var actionTypeId: Int
    @Published var startTime: Date
    @Published var endTime: Date?
    var parentId: Int?
    @Published var dynamicData: [String: AnyCodable]
    @Published var actionTypeModel: ActionTypeModel
    
    var duration: String {
        guard let endTime = endTime else { return "00:00" }
        
        let durationInSeconds = Int(endTime.timeIntervalSince(startTime))
        let hours = durationInSeconds / 3600
        let minutes = (durationInSeconds % 3600) / 60
        
        return String(format: "%02d:%02d", hours, minutes)
    }


    init(id: Int? = nil, actionTypeId: Int, startTime: String, endTime: String? = nil, parentId: Int? = nil, dynamicData: [String: AnyCodable] = [:], actionTypeModel: ActionTypeModel) {
        self.id = id
        self.actionTypeId = actionTypeId
        self.startTime = startTime.getDate ?? Date()
        self.endTime = endTime?.getDate
        self.parentId = parentId
        self.dynamicData = dynamicData
        self.actionTypeModel = actionTypeModel
    }
    
    func copy(_ newModel:ActionModel) {
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
        
        if actionTypeModel.meta.hasDuration, duration != "00:00" {
            if let desc = description {
                return "\(desc) (\(duration))"
            } else {
                return "(\(duration))"
            }
        } else {
            return description
        }
    }
}


