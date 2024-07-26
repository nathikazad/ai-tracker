//
//  ActionController.swift
//  History
//
//  Created by Nathik Azad on 7/25/24.
//

import Foundation


func fetchActions(type: String) -> [ActionModel] {
    return [ActionModel(id: 1,
                        staticData:
                            ActionModelStaticData(
                                actionType: "Sleep",
                                startTime: "2024-07-22T22:30:00+08:00",
                                endTime: "2024-07-23T06:30:00+08:00",
                                parentId: 5
                            ),
                        dynamicData:
                            [
                                "notes": "Had a good night's sleep"
                            ]
                       ),
            ActionModel(id: 2,
                        staticData:
                            ActionModelStaticData(
                                actionType: "Sleep",
                                startTime: "2024-07-23T22:30:00+08:00",
                                endTime: "2024-07-24T06:30:00+08:00",
                                parentId: 7
                            ),
                        dynamicData:
                            [
                                "notes": "Lot of bad dreams"
                            ]
                       ),
            ActionModel(id: 2,
                        staticData:
                            ActionModelStaticData(
                                actionType: "Pray",
                                parentId: 5, time: "2024-07-23T06:30:00+08:00"
                            ),
                        dynamicData:
                            [
                                "Prayer Name": "Fajr"
                            ]
                       ),
    ].filter { $0.staticData.actionType == type }
}
