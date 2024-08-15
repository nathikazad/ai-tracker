//
//  ActionModel.swift
//  History
//
//  Created by Nathik Azad on 7/22/24.
//

import Foundation

import SwiftUI

class ActionTypeModel: ObservableObject, Codable {
    @Published var id: Int?
    @Published var name: String
    @Published var meta: ActionTypeMeta
    @Published var staticFields: ActionModelTypeStaticSchema
    @Published var dynamicFields: [String: Schema]
    @Published var objectConnections: [String: ObjectConnection]
    @Published var aggregates: [AggregateModel]
    
    var shortDescSyntax: String?
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, name, metadata, staticFields, dynamicFields, internalObjects
        case shortDescSyntax = "short_desc_syntax"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case hasDuration = "has_duration"
        case description = "description"
        case aggregates = "aggregates"
        case objectConnections = "object_t_action_ts"
    }
    
    init(id: Int? = nil,
         name: String,
         meta: ActionTypeMeta = ActionTypeMeta(),
         staticFields: ActionModelTypeStaticSchema = ActionModelTypeStaticSchema(),
         dynamicFields: [String: Schema] = [:],
         objectConnections: [String: ObjectConnection] = [:],
         aggregates: [AggregateModel] = [],
         shortDescSyntax: String? = nil,
         createdAt: Date = Date(),
         updatedAt: Date = Date()) {
        self.id = id
        self.name = name
        self.meta = meta
        self.staticFields = staticFields
        self.dynamicFields = dynamicFields
        self.shortDescSyntax = shortDescSyntax
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.aggregates = aggregates
        self.objectConnections = objectConnections
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? "Unknown Verb"
        meta = try ActionTypeMeta(
            hasDuration: container.decode(Bool.self, forKey: .hasDuration),
            description: container.decodeIfPresent(String.self, forKey: .description)
        )
        let metadata = try container.decode(ActionTypeMetadataForHasura.self, forKey: .metadata)
        staticFields = metadata.staticFields
        dynamicFields = metadata.dynamicFields
        shortDescSyntax = try container.decodeIfPresent(String.self, forKey: .shortDescSyntax)
        let createdAtString = try container.decode(String.self, forKey: .createdAt)
        createdAt = createdAtString.getDate!
        let updatedAtString = try container.decode(String.self, forKey: .updatedAt)
        updatedAt = updatedAtString.getDate!
        self.aggregates = try container.decodeIfPresent([AggregateModel].self, forKey: .aggregates) ?? []
        let objectConnections = try container.decodeIfPresent([ObjectConnection].self, forKey: .objectConnections) ?? []
        self.objectConnections = Dictionary(uniqueKeysWithValues: objectConnections.map { (String($0.id), $0) })
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(meta.hasDuration, forKey: .hasDuration)
        try container.encode(meta.description, forKey: .description)
        let metadata = ActionTypeMetadataForHasura(
            staticFields: staticFields,
            dynamicFields: dynamicFields
        )
        try container.encode(metadata, forKey: .metadata)
        try container.encodeIfPresent(shortDescSyntax, forKey: .shortDescSyntax)
        try container.encode(createdAt.toUTCString, forKey: .createdAt)
        try container.encode(updatedAt.toUTCString, forKey: .updatedAt)
    }
    
    func copy(_ m: ActionTypeModel) {
        self.id = m.id
        self.name = m.name
        self.meta = m.meta
        self.staticFields = m.staticFields
        self.dynamicFields = m.dynamicFields
        self.shortDescSyntax = m.shortDescSyntax
        self.aggregates = m.aggregates
        self.objectConnections = m.objectConnections
    }
    
    var getMetadataJson: [String: Any] {
        let metadata: ActionTypeMetadataForHasura = ActionTypeMetadataForHasura(
            staticFields: staticFields,
            dynamicFields: dynamicFields
        )
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(metadata)
            if let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
                return dictionary
            } else {
                print("Error: Could not convert encoded data to dictionary")
                return [:]
            }
        } catch {
            print("Error encoding to JSON: \(error)")
            return [:]
        }
    }
}




