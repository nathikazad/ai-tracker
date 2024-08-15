//
//  SchemaM.swift
//  History
//
//  Created by Nathik Azad on 8/14/24.
//

import Foundation

extension [String: Schema] {
    var filterNumericTypes: [String: Schema] {
        return self.filter { (_, schema) in
            schema.dataType == .currency || schema.dataType == .number
        }
    }
}

class Schema: Codable {
    var name: String
    var dataType: DataType
    var description: String
    var array: Bool
    var enumValues: [String]
//    var objectFields: [String: Schema]
    var rank: Int = 0
    
    enum CodingKeys: String, CodingKey {
        case name, dataType, description, array, enumValues, rank
    }
    
    var getEnums: [String] {
        if(!enumValues.isEmpty) {
            return enumValues
        } else {
            return ["None"]
        }
    }
    
    
    init(name: String,
         dataType: DataType,
         description: String,
         array: Bool = false,
         enumValues: [String] = [],
//         objectFields: [String : Schema] = [:],
         rank: Int = 0) {
        self.name = name
        self.dataType = dataType
        self.description = description
        self.array = array
        self.enumValues = enumValues
//        self.objectFields = objectFields
        self.rank = rank
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        rank = try container.decodeIfPresent(Int.self, forKey: .rank) ?? 0
        var dataTypeAsString = try container.decodeIfPresent(String.self, forKey: .dataType) ?? "ShortString"
        dataType = getDataType(from: dataTypeAsString) ?? .shortString
        description = try container.decode(String.self, forKey: .description)
        array = try container.decodeIfPresent(Bool.self, forKey: .array) ?? false
        enumValues = try container.decodeIfPresent([String].self, forKey: .enumValues) ?? []
//        objectFields = try container.decodeIfPresent([String: Schema].self, forKey: .objectFields) ?? [:]
    }
}
