//
//  SquadM.swift
//  History
//
//  Created by Nathik Azad on 8/19/24.
//

import Foundation
class SquadModel: Codable, Identifiable, ObservableObject {
    @Published var id: Int
    @Published var name: String
    var ownerId: Int
    @Published var members: [Int: GroupMemberModel]
    @Published var messages: [Int: MessageModel]
    
    func copy(_ from: SquadModel) {
        self.id = from.id
        self.ownerId = from.ownerId
        self.name = from.name
        self.members = from.members
        self.messages = from.messages
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case ownerId = "owner_id"
        case members
        case messages
    }
    
    func userOfMessage(_ messageId: Int) -> SquadUserModel? {
        if let memberId = messages[messageId]?.memberId {
            return members[memberId]?.user
        }
        return nil
    }
    
    func memberIdOfUser(_ userId: Int) -> Int? {
        return members.filter { (key, value) in
            return value.user.id == userId
        }.first?.key
    }
    
    func ingestNewMessages(newMessages: [MessageModel]) {
        for message in newMessages {
            if messages[message.id] == nil {
                messages[message.id] = message
            }
        }
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        ownerId = try container.decode(Int.self, forKey: .ownerId)
        
        let memberArray = try container.decode([GroupMemberModel].self, forKey: .members)
        members = Dictionary(uniqueKeysWithValues: memberArray.map { ($0.id, $0) })
        
        if let messageArray = try container.decodeIfPresent([MessageModel].self, forKey: .messages) {
            messages = Dictionary(uniqueKeysWithValues: messageArray.map { ($0.id, $0) })
        } else {
            messages = [:]
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(ownerId, forKey: .ownerId)
        try container.encode(Array(members.values), forKey: .members)
        try container.encode(Array(messages.values), forKey: .messages)
    }
}

class GroupMemberModel: Observable, Codable, ObservableObject, Identifiable {
    @Published var id: Int
    @Published var user: SquadUserModel
    @Published var metadata: [String: AnyCodable]?
    
    enum CodingKeys: String, CodingKey {
        case id, user, metadata
    }
    
    init(id: Int, user: SquadUserModel, metadata: [String: AnyCodable]? = nil) {
        self.id = id
        self.user = user
        self.metadata = metadata
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        user = try container.decode(SquadUserModel.self, forKey: .user)
        metadata = try container.decodeIfPresent([String: AnyCodable].self, forKey: .metadata)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(user, forKey: .user)
        try container.encodeIfPresent(metadata, forKey: .metadata)
    }
    
    func copy(_ newModel: GroupMemberModel) {
        self.id = newModel.id
        self.user = newModel.user
        self.metadata = newModel.metadata
    }
    
    var aggregates: [Int] {
        get {
            return metadata?["aggregates"]?.value as? [Int] ?? []
        }
        set {
            if metadata == nil {
                metadata = [:]
            }
            metadata?["aggregates"] = AnyCodable(newValue)
        }
    }
    
    func addToAggregates(_ aggregateId: Int) {
            var currentAggregates = self.aggregates
            if !currentAggregates.contains(aggregateId) {
                currentAggregates.append(aggregateId)
                self.aggregates = currentAggregates
            }
        }
        
    func removeFromAggregates(_ aggregateId: Int) {
        var currentAggregates = self.aggregates
        if let index = currentAggregates.firstIndex(of: aggregateId) {
            currentAggregates.remove(at: index)
            self.aggregates = currentAggregates
        }
    }
}

struct SquadUserModel: Codable, Identifiable {
    let id: Int
    var name: String
}

struct MessageModel: Codable, Identifiable {
    let id: Int
    let memberId: Int
    let time: String
    let payload: MessagePayload
    
    enum CodingKeys: String, CodingKey {
        case id
        case memberId = "member_id"
        case time
        case payload
    }
}

struct MessagePayload: Codable {
    let message: String
}
