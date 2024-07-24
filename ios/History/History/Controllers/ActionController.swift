//
//  ActionController.swift
//  History
//
//  Created by Nathik Azad on 7/22/24.
//

import Foundation

let actionsTypes: [ActionTypeModel] = [
    ActionTypeModel(name: "Sleep",
                    meta: ActionTypeMeta(
                        hasDuration: true,
                        description: "This event is when a user sleeps for a period of time"
                    ),
                    staticFields: ActionModelTypeStaticSchema(
                        startTime:
                            Schema(type: "DateTime",
                                   description: "The hour that the user woke up",
                                   name: "Sleep time"
                                  ),
                        endTime:
                            Schema(type: "DateTime",
                                   description: "The hour that the user went to sleep",
                                   name: "Wake Up time"
                                  )
                    ),
                    dynamicFields: [
                        "notes":
                            Schema(type: "String",
                                   description: "Additional notes if any about the sleep"
                                  )
                    ],
                    computed: [
                        "duration":
                            Schema(type: "TimeDuration",
                                   description: "Hours person slept"
                                  )
                    ],
                    aggregates: [
                        "Wake up time":
                            Aggregate(
                                field: "startTime",
                                window: .daily,
                                dataType: .time,
                                aggregatorType: .first,
                                conditions: [
                                    Condition(
                                        field: "endTime",
                                        comparisonOperator: "gt",
                                        value: "18:00:00"),
                                    Condition(
                                        field: "startTime",
                                        comparisonOperator: "lt",
                                        value: "15:00:00"
                                    ),
                                ],
                                goals: [
                                    Goal(
                                        comparisonOperator: "lt",
                                        value: "06:30:00")
                                ]
                            ),
                        "Sleep time":
                            Aggregate(
                                field: "endTime",
                                window: .daily,
                                dataType: .time,
                                aggregatorType: .first,
                                conditions: [
                                    Condition(
                                        field: "endTime",
                                        comparisonOperator: "gt",
                                        value: "18:00:00"),
                                    Condition(
                                        field: "startTime",
                                        comparisonOperator: "lt",
                                        value: "15:00:00"
                                    ),
                                ],
                                goals: [
                                    Goal(
                                        comparisonOperator: "lt",
                                        value:  "23:00:00")
                                ]
                            ),
                        "Duration":
                            Aggregate(
                                field: "duration",
                                window: .daily,
                                dataType: .timeDuration,
                                aggregatorType: .sum,
                                conditions: [
                                    Condition(
                                        field: "endTime",
                                        comparisonOperator: "gt",
                                        value: "18:00:00"),
                                    Condition(
                                        field: "startTime",
                                        comparisonOperator: "lt",
                                        value: "15:00:00"
                                    ),
                                ],
                                goals: [
                                    Goal(
                                        comparisonOperator: "gt",
                                        value: "07:00:00")
                                ]
                            ),
                    ]
                   ),
    ActionTypeModel(name: "Pray",
                    meta: ActionTypeMeta(
                        hasDuration: false,
                        description: "This event is when a user prays"
                    ),
                    staticFields: ActionModelTypeStaticSchema(
                        time:
                            Schema(type: "DateTime",
                                   description: "The time user prayed"
                                  )
                    ),
                    dynamicFields: [
                        "Prayer Name":
                            Schema(type: "PrayerName",
                                   description: "Additional notes if any about the sleep"
                                  )
                    ],
                    internalTypes: [
                        "PrayerName": [
                            "description": "Name of the prayer",
                            "type": "enum",
                            "values": ["Fajr", "Dhuhr", "Asr", "Magrib", "Isha"]
                        ]
                    ],
                    aggregates:
                        ["Prayers prayed per day":
                            Aggregate(
                                field: "*",
                                window: .daily,
                                dataType: .number,
                                aggregatorType: .count,
                                conditions:[
                                    Condition(
                                        field: "prayerName",
                                        comparisonOperator: "eq",
                                        value: "Fajr"
                                    )
                                ],
                                goals: [
                                    Goal(
                                        comparisonOperator: "eq",
                                        value: 5)
                                ]
                            )
                        ]
                   )
]

func fetchActionTypes() async -> [ActionTypeModel] {
    return actionsTypes
}

func fetchActionType(type: String) async -> ActionTypeModel? {
    return actionsTypes.filter { $0.name == type }.first
}

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


// finished:  work on action view
// work on action type view
// work on action type edit
// work on action edit
// put action type and action into database and then fetch it
// then work on create action type
// then work on create action
// then work on edit action type
// then work on edit action
