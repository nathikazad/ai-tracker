//
//  ActionController.swift
//  History
//
//  Created by Nathik Azad on 7/22/24.
//

import Foundation

let externalDataTypes: [String] = ["Expense", "Organization", "Item"]
let actionsTypes: [ActionTypeModel] = [
    ActionTypeModel(name: "Sleep",
                    meta: ActionTypeMeta(
                        hasDuration: true,
                        description: "This event is when a user sleeps for a period of time"
                    ),
                    staticFields: ActionModelTypeStaticSchema(
                        startTime:
                            Schema(
                                name: "Sleep time",
                                dataType: "DateTime",
                                description: "The hour that the user woke up"
                            ),
                        endTime:
                            Schema(name: "Wake Up time",
                                   dataType: "DateTime",
                                   description: "The hour that the user went to sleep"
                                  )
                    ),
                    dynamicFields: [
                        "notes":
                            Schema(
                                name: "Notes",
                                dataType: "String",
                                description: "Additional notes if any about the sleep"
                            )
                    ],
                    computed: [
                        "duration":
                            Schema(
                                name: "Duration",
                                dataType: "TimeDuration",
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
                            Schema(
                                name: "Prayer Time",
                                dataType: "DateTime",
                                description: "The time user prayed"
                            )
                    ),
                    dynamicFields: [
                        "Prayer Name":
                            Schema(
                                name: "PrayerName",
                                dataType: "enum",
                                description: "The type of prayer",
                                enumValues: ["Fajr", "Dhuhr", "Asr", "Magrib", "Isha"]
                            )
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
                   ),
    ActionTypeModel(name: "Shopping",
                    meta: ActionTypeMeta(
                        hasDuration: true,
                        description: "This event is when a user goes shopping"
                    ),
                    staticFields: ActionModelTypeStaticSchema(
                        startTime:
                            Schema(
                                name: "Start Time",
                                dataType: "DateTime",
                                description: "The time user went shopping"
                            ),
                        endTime:
                            Schema(
                                name: "End Time",
                                dataType: "DateTime",
                                description: "The time user got back from shopping"
                            )
                    ),
                    dynamicFields: [
                        "itemList":
                            Schema(
                                name: "List of Items",
                                dataType: "ItemRow",
                                description: "List of items that was bought",
                                array: true
                            ),
                        "store":
                            Schema(
                                name: "Store",
                                dataType: "Organization",
                                description: "The store from where the items were bought"
                            ),
                        "cost":
                            Schema(
                                name: "Cost",
                                dataType: "Expense",
                                description: "The total cost of the items"
                            ),
                        "ShoppingType":
                            Schema(
                                name: "ShoppingType",
                                dataType: "enum",
                                description: "The type of shopping",
                                enumValues: ["In Person", "Online"]
                            ),
                    ],
                    internalObjects: [
                        "ItemRow": InternalObject(
                            name: "ItemRow",
                            description: "The item that was bought",
                            fields: [
                                "item":
                                    Schema(
                                        name: "Item",
                                        dataType: "Item",
                                        description: "The item that was bought"
                                    ),
                                "quantity":
                                    Schema(
                                        name: "Quantity",
                                        dataType: "number",
                                        description: "The quantity of item that was bought"
                                    ),
                                "unitOfQuantity":
                                    Schema(
                                        name: "Unit",
                                        dataType: "String",
                                        description: "The unit of quantity of item"
                                    ),
                                "cost":
                                    Schema(
                                        name: "Cost",
                                        dataType: "number",
                                        description: "The cost of the item"
                                    ),
                            ]

                        )
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
