//
//  ActionTypeAggregateModel.swift
//  History
//
//  Created by Nathik Azad on 7/24/24.
//

import Foundation

class Aggregate: Codable {
    var field: String
    var window: Window
    var dataType: DataType
    var aggregatorType: AggregatorType
    var conditions: [Condition]
    var goals: [Goal]
    var description: String?
    
    enum CodingKeys: String, CodingKey {
        case field, window, dataType, aggregatorType, conditions, goals, description
    }
    
    
    init(field: String, window: Window, dataType: DataType, aggregatorType: AggregatorType, conditions: [Condition], goals: [Goal], description: String? = nil) {
        self.field = field
        self.window = window
        self.dataType = dataType
        self.aggregatorType = aggregatorType
        self.conditions = conditions
        self.goals = goals
        self.description = description
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        field = try container.decode(String.self, forKey: .field)
        window = try container.decode(Window.self, forKey: .window)
        dataType = try container.decode(DataType.self, forKey: .dataType)
        aggregatorType = try container.decode(AggregatorType.self, forKey: .aggregatorType)
        conditions = try container.decode([Condition].self, forKey: .conditions)
        goals = try container.decode([Goal].self, forKey: .goals)
        description = try container.decodeIfPresent(String.self, forKey: .description)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(field, forKey: .field)
        try container.encode(window, forKey: .window)
        try container.encode(dataType, forKey: .dataType)
        try container.encode(aggregatorType, forKey: .aggregatorType)
        try container.encode(conditions, forKey: .conditions)
        try container.encode(goals, forKey: .goals)
        try container.encodeIfPresent(description, forKey: .description)
    }
}

enum Window: String, Codable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
}

enum AggregatorType: String, Codable {
    case sum = "Sum"
    case count = "Count"
    case first = "First"
}

struct Condition: Codable {
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

struct Goal: Codable {
    var comparisonOperator: String
    var value: Any
    
    enum CodingKeys: String, CodingKey {
        case comparisonOperator, value
    }
    
    init(comparisonOperator: String, value: Any) {
        self.comparisonOperator = comparisonOperator
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        comparisonOperator = try container.decode(String.self, forKey: .comparisonOperator)
        let anyCodable = try container.decode(AnyCodable.self, forKey: .value)
        value = anyCodable.value
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(comparisonOperator, forKey: .comparisonOperator)
        try container.encode(AnyCodable(value), forKey: .value)
    }
    
}





