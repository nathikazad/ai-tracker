//
//  ActionModel.swift
//  History
//
//  Created by Nathik Azad on 7/22/24.
//

import Foundation


class Schema {
    var name: String
    var dataType: String
    var description: String
    var array: Bool
    var enumValues: [String]
    var objectFields: [String: Schema]
    
    init( name: String, dataType: String, description: String,
          array: Bool = false,
          enumValues: [String] = [],
          objectFields: [String : Schema] = [:]) {
        self.dataType = dataType
        self.array = array
        self.description = description
        self.name = name
        self.enumValues = enumValues
        self.objectFields = objectFields
    }
}

class InternalObject: Observable {
    var name: String
    var description: String
    @Published var fields: [String: Schema]
    
    init(name: String, description: String, fields: [String : Schema]) {
        self.name = name
        self.description = description
        self.fields = fields
    }
}

struct Condition {
    var field: String
    var comparisonOperator: String
    var value: String
    
    init(field: String, comparisonOperator: String, value: String) {
        self.field = field
        self.comparisonOperator = comparisonOperator
        self.value = value
    }
}

struct Goal {
    var comparisonOperator: String
    var value: Any
    
    init(comparisonOperator: String, value: Any) {
        self.comparisonOperator = comparisonOperator
        self.value = value
    }
}

enum ComparisonOperator: String, Codable {
    case greaterThan = "gt"
    case lessThan = "lt"
    case equalTo = "eq"
    case notEqualTo = "neq"
    case greaterThanOrEqualTo = "gte"
    case lessThanOrEqualTo = "lte"
}

enum DataType: String {
    case timeDuration = "TimeDuration"
    case time = "Time"
    case date = "Date"
    case dateTime = "DateTime"
    case number = "Number"
}

enum AggregatorType: String {
    case sum = "Sum"
    case count = "Count"
    case first = "First"
}

enum Window: String {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
}

class Aggregate {
    var field: String
    var window: Window
    var dataType: DataType
    var aggregatorType: AggregatorType
    var conditions: [Condition]
    var goals: [Goal]
    var description: String?
    
    init(field: String, window: Window, dataType: DataType, aggregatorType: AggregatorType, conditions: [Condition], goals: [Goal], description: String? = nil) {
        self.field = field
        self.window = window
        self.dataType = dataType
        self.aggregatorType = aggregatorType
        self.conditions = conditions
        self.goals = goals
        self.description = description
    }
}

class ActionTypeMeta: ObservableObject {
    @Published var hasDuration: Bool
    var description: String?
    
    init(hasDuration: Bool = true, description: String? = nil) {
        self.hasDuration = hasDuration
        self.description = description
    }
}

class ActionModelTypeStaticSchema {
    var startTime: Schema?
    var endTime: Schema?
    var time: Schema?
    var parentId: Schema?
    
    init(startTime: Schema? = nil, endTime: Schema? = nil, time: Schema? = nil, parentId: Schema? = nil) {
        self.startTime = startTime
        self.endTime = endTime
        self.time = time
        self.parentId = parentId
    }
}


class ActionTypeModel: ObservableObject {
    var name: String
    @Published var meta: ActionTypeMeta
    var staticFields: ActionModelTypeStaticSchema
    @Published var dynamicFields: [String: Schema]
    @Published var internalObjects: [String: InternalObject]
    var aggregates: [String: Aggregate]
    var computed: [String: Any]
    var goals: [String: Any]
    
    var internalDataTypes: [String] {
        internalObjects.values.compactMap { $0.name }.sorted()
    }
    
    init(name: String, 
         meta: ActionTypeMeta,
         staticFields: ActionModelTypeStaticSchema,
         dynamicFields: [String: Schema] = [:],
         computed: [String: Any] = [:],
         internalObjects: [String: InternalObject] = [:],
         aggregates: [String: Aggregate] = [:], goals: [String: Any] = [:]) {
        self.name = name
        self.meta = meta
        self.staticFields = staticFields
        self.dynamicFields = dynamicFields
        self.computed = computed
        self.internalObjects = internalObjects
        self.aggregates = aggregates
        self.goals = goals
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
