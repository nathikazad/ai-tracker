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
    @Published var startTime: String
    @Published var endTime: String?
    var parentId: Int?
    @Published var dynamicData: [String: Any]
    var actionTypeModel: ActionTypeModel

    init(id: Int? = nil, actionTypeId: Int, startTime: String, endTime: String? = nil, parentId: Int? = nil, dynamicData: [String: Any] = [:], actionTypeModel: ActionTypeModel) {
        self.id = id
        self.actionTypeId = actionTypeId
        self.startTime = startTime
        self.endTime = endTime
        self.parentId = parentId
        self.dynamicData = dynamicData
        self.actionTypeModel = actionTypeModel
        print(dynamicData)
    }
}


