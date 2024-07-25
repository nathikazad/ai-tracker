//
//  ActionModel.swift
//  History
//
//  Created by Nathik Azad on 7/24/24.
//

import Foundation

class ActionModel {
    var id: Int
    var staticData: ActionModelStaticData
    var dynamicData: [String: Any]
    
    init(id: Int, staticData: ActionModelStaticData, dynamicData: [String : Any]) {
        self.id = id
        self.staticData = staticData
        self.dynamicData = dynamicData
    }
}

class ActionModelStaticData {
    var actionType: String
    var startTime: String?
    var endTime: String?
    var time: String?
    var parentId: Int?
    
    init(actionType: String, startTime: String? = nil, endTime: String? = nil, parentId: Int? = nil, time: String? = nil) {
        self.actionType = actionType
        self.startTime = startTime
        self.endTime = endTime
        self.parentId = parentId
        self.time = time
    }
}
