//
//  ActionController.swift
//  History
//
//  Created by Nathik Azad on 7/22/24.
//

import Foundation

let externalDataTypes: [String] = ["Expense", "Organization", "Item"]
var actionsTypes: [ActionTypeModel] = [
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
                                dataType: "LongString",
                                description: "Additional notes if any about the sleep"
                            )
                    ],
                    computed: [
                        "duration":
                            Schema(
                                name: "Duration",
                                dataType: "Duration",
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
                                dataType: .duration,
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
                                dataType: "Enum",
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
                                dataType: "Enum",
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
                                        dataType: "Number",
                                        description: "The quantity of item that was bought"
                                    ),
                                "unitOfQuantity":
                                    Schema(
                                        name: "Unit",
                                        dataType: "Unit",
                                        description: "The unit of quantity of item"
                                    ),
                                "cost":
                                    Schema(
                                        name: "Cost",
                                        dataType: "Currency",
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

func updateActionType(actionTypeModel: ActionTypeModel) async {
    if let index = actionsTypes.firstIndex(where: { $0.name == actionTypeModel.name }) {
        actionsTypes[index] = actionTypeModel
    }
}

func updateActionType(actionTypeModel: ActionTypeModel, actionName: String? = nil) async {
    do {
        // Serialize to JSON
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601 // Use ISO8601 for date encoding
        let jsonData = try encoder.encode(actionTypeModel)
        
        // Convert JSON data to a dictionary
        guard let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
            print("Error: Cannot convert JSON data to dictionary")
            return
        }
        
        // Call dbFunction with the JSON object
        let id = await dbUpdateFunction(jsonObject: jsonObject)
        
        // You can do something with the returned id if needed
        print("Action type added with id: \(id)")
    } catch {
        print("Error serializing ActionTypeModel to JSON: \(error)")
    }
}

func fetchActionType(id: String) async throws -> ActionTypeModel {
    // Call dbFetchFunction to get JSON object
    let jsonObject = await dbFetchFunction(id: id)
    
    // Convert dictionary to JSON data
    let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
    
    // Deserialize JSON data to ActionTypeModel
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601 // Use ISO8601 for date decoding
    let model = try decoder.decode(ActionTypeModel.self, from: jsonData)
    
    return model
}

func dbFetchFunction(id: String) async -> [String: Any] {
    // This function would interact with the database
    // and return a JSON object as a dictionary
    return ["name": "Sleep", "meta": ["hasDuration": true], /* ... other fields ... */]
}

// Assume this function is already implemented
func dbUpdateFunction(jsonObject: [String: Any], actionName: String? = nil) async -> String {
    // This function would interact with the database
    // and return an id
    return "some-generated-id"
}



// finished: work on action view
// finished: work on action type view
// finished: work on action type create/edit
// working: put action type into database and then fetch it
// work on create/modify/delete action
// put action action into database and then fetch it

// RELASE
// work on object view
// work on object create/edit
// put object into database and then fetch it
// RELASE
// work on aggregates
// RELASE
// work on goals
// RELASE
// work on reminders
// RELASE
// integrate location
// RELASE
// integrate sleep
// RELASE
// integrate plaid
// RELEASE




