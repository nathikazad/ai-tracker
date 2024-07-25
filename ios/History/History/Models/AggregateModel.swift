//
//  ActionTypeAggregateModel.swift
//  History
//
//  Created by Nathik Azad on 7/24/24.
//

import Foundation

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

enum Window: String {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
}

enum AggregatorType: String {
    case sum = "Sum"
    case count = "Count"
    case first = "First"
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

enum ComparisonOperator: String, Codable {
    case greaterThan = "gt"
    case lessThan = "lt"
    case equalTo = "eq"
    case notEqualTo = "neq"
    case greaterThanOrEqualTo = "gte"
    case lessThanOrEqualTo = "lte"
}

struct Goal {
    var comparisonOperator: String
    var value: Any
    
    init(comparisonOperator: String, value: Any) {
        self.comparisonOperator = comparisonOperator
        self.value = value
    }
}





