//
//  ActionTypeAggregateModel.swift
//  History
//
//  Created by Nathik Azad on 7/24/24.
//

import Foundation

class AggregateModel: Codable, ObservableObject, Identifiable {
    @Published var id: Int?
    let actionTypeId: Int
    let actionType: ActionTypeModel?
    @Published var metadata: AggregateMetaData

    enum CodingKeys: String, CodingKey {
        case id
        case actionTypeId = "action_type_id"
        case metadata
        case actionType = "action_type"
    }
    
    init(id: Int? = nil, actionTypeId: Int, metadata: AggregateMetaData = AggregateMetaData()) {
        self.id = id
        self.actionTypeId = actionTypeId
        self.metadata = metadata
        self.actionType = nil
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        actionTypeId = try container.decode(Int.self, forKey: .actionTypeId)
        metadata = try container.decode(AggregateMetaData.self, forKey: .metadata)
        actionType = try container.decodeIfPresent(ActionTypeModel.self, forKey: .actionType)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(actionTypeId, forKey: .actionTypeId)
        try container.encode(metadata, forKey: .metadata)
    }
    
    var toString: String {
        return "\(metadata.window.rawValue.capitalized) \(metadata.aggregatorType) \(metadata.field != "" ? "of \(metadata.field)" : "")"
    }
}

class AggregateMetaData: Codable, ObservableObject {
    @Published var field: String
    @Published var window: ASWindow
    @Published var dataType: DataType
    @Published var name: String
    @Published var aggregatorType: AggregatorType
    @Published var conditions: [Goal]
    @Published var goals: [Goal]
    
    enum CodingKeys: String, CodingKey {
        case field, window, dataType, aggregatorType, conditions, goals, name
    }
    
    init(field: String = "", window: ASWindow = .daily, dataType: DataType = .dateTime, aggregatorType: AggregatorType = .count, conditions: [Goal] = [], goals: [Goal] = [], name: String = "") {
        self.field = field
        self.window = window
        self.dataType = dataType
        self.aggregatorType = aggregatorType
        self.conditions = conditions
        self.goals = [Goal()]
        self.name = name
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        field = try container.decodeIfPresent(String.self, forKey: .field) ?? ""
        let windowString = try container.decodeIfPresent(String.self, forKey: .window) ?? "daily"
        window = ASWindow(rawValue: windowString) ?? .daily
        let dataTypeString = try container.decodeIfPresent(String.self, forKey: .dataType) ?? "ShortString"
        dataType = DataType(rawValue: dataTypeString) ?? .shortString
        let aggregatorTypeString = try container.decodeIfPresent(String.self, forKey: .aggregatorType) ?? "sum"
        aggregatorType = AggregatorType(rawValue: aggregatorTypeString) ?? .sum
        conditions = try container.decodeIfPresent([Goal].self, forKey: .conditions) ?? []
        goals = try container.decodeIfPresent([Goal].self, forKey: .goals) ?? []
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if aggregatorType != .count && field != "" {
            try container.encode(field, forKey: .field)
        }
        try container.encode(window, forKey: .window)
        try container.encode(name, forKey: .name)
        try container.encode(dataType, forKey: .dataType)
        try container.encode(aggregatorType, forKey: .aggregatorType)
        try container.encode(conditions, forKey: .conditions)
        try container.encode(goals, forKey: .goals)
    }
    
    var toJson: [String: Any] {
        let encoder = JSONEncoder()
        if let metadataJson = try? encoder.encode(self),
           let metadataDict = try? JSONSerialization.jsonObject(with: metadataJson, options: []) as? [String: Any] {
            return metadataDict
        } else {
            return [:]
        }
    }
}

enum ASWindow: String, Codable, CaseIterable, Hashable {
    case daily = "daily"
    case weekly = "weekly"
    case monthly = "monthly"
}

enum AggregatorType: String, Codable, CaseIterable, Hashable {
    case sum = "sum"
    case count = "count"
    case compare = "compare"
}

enum GoalPriority: String, Codable, CaseIterable, Hashable {
    case high = "high"
    case low = "low"
}

struct Goal: Codable {
    var field: String
    var comparisonOperator: ComparisonOperator
    var priority: GoalPriority
    var value: AnyCodable?
    var selectedDays: [Int]
    
    enum CodingKeys: String, CodingKey {
        case field
        case comparisonOperator
        case priority
        case value
        case selectedDays = "selected_days"
    }
    
    init(field: String = "Start Time", comparisonOperator: ComparisonOperator = .equalTo, value: AnyCodable? = nil, priority: GoalPriority = .high) {
        self.field = field
        self.comparisonOperator = comparisonOperator
        self.value = value
        self.priority = priority
        self.selectedDays = Array(0..<7)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        field = try container.decode(String.self, forKey: .field)
        let comparisonOperatorString = try container.decode(String.self, forKey: .comparisonOperator)
        comparisonOperator = ComparisonOperator(from: comparisonOperatorString)
        value = try container.decodeIfPresent(AnyCodable.self, forKey: .value)
        priority = try container.decodeIfPresent(GoalPriority.self, forKey: .priority) ?? GoalPriority.high
        self.selectedDays = try container.decodeIfPresent([Int].self, forKey: .selectedDays) ?? []
    }
}


enum ComparisonOperator: String, Codable, CaseIterable {
    case greaterThan = "Greater Than"
    case lessThan = "Less Than"
    case equalTo = "Equal To"
    case notEqualTo = "Not Equal To"
    case greaterThanOrEqualTo = "Greater or Equal To"
    case lessThanOrEqualTo = "Less or Equal To"

    init(from string: String) {
        self = ComparisonOperator(rawValue: string) ?? .equalTo
    }
}






