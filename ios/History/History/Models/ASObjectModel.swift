//
//  ASObject.swift
//  History
//
//  Created by Nathik Azad on 5/28/24.
//

import Foundation

extension EventModel {
    var book: ASObject? {
        return objects.books.first
    }
    
    var people: [ASObject] {
        return objects.people
    }
    
    var socialEvent: ASObject? {
        return objects.socialEvents.first
    }
}

extension [ASObject] {
    var books: [ASObject] {
        return self.objectIds(objectType: .book)
    }
    
    var people: [ASObject] {
        return self.objectIds(objectType: .person)
    }
    
    var socialEvents: [ASObject] {
        return self.objectIds(objectType: .socialEvent)
    }

    func objectIds(objectType: ASObjectType) -> [ASObject] {
        return self.filter { $0.objectType == objectType }
    }
}

enum ASObjectType: String, Decodable {
    case book = "Book"
    case person = "Person"
    case recipe = "Recipe"
    case store = "Store"
    case socialEvent = "SocialEvent"
    case unknown = "Unknown"
}

class ASObject: Decodable {
    var id: Int?
    var name: String
    var objectType: ASObjectType
    var events: [EventModel] = []

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case objectType = "object_type"
        case events
        case metadata
    }
    
    init(name:String, objectType: ASObjectType) {
        self.name = name
        self.objectType = objectType
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        let objectTypeString = try container.decode(String.self, forKey: .objectType)
        objectType = ASObjectType(rawValue: objectTypeString) ?? .unknown
        events = try container.decodeIfPresent([EventModel].self, forKey: .events) ?? []
    }


    var metadata:  [String: Any] {
        return [:]
    }
    
    var firstEventDate: Date? {
        return events.min(by: { $0.startTime ?? Date.distantFuture < $1.startTime ?? Date.distantFuture })?.startTime
    }

    var lastEventDate: Date? {
        return events.max(by: { $0.endTime ?? Date.distantPast < $1.endTime ?? Date.distantPast })?.endTime
    }

    var totalDurationInHours: Double {
        let totalDuration = events.reduce(0.0) { (result, event) -> Double in
            guard let startTime = event.startTime, let endTime = event.endTime else {
                return result
            }
            let duration = endTime.timeIntervalSince(startTime)
            return result + duration
        }
        return totalDuration / 3600
    }
}

class PersonData: JSONRepresentable {
    var contactMethods:[String]? = []
    var photo:String? = nil
    var description: String? = nil
    
    enum CodingKeys: String, CodingKey {
        case contactMethods
        case photo
        case description
    }
    
    func toJson() throws ->  [String: Any] {
        return try encodeToDictionary(self)
    }
}

class Person: ASObject {
    var data: PersonData? = nil
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        data = try container.decode(PersonData.self, forKey: .metadata)
        try super.init(from: decoder)
    }
    
    init(name: String, data: PersonData) {
        self.data = data
        super.init(name: name, objectType: .person)
    }
    
    
    override var metadata:  [String: Any] {
        print("to json of Person")
        do {
            return try data!.toJson()
        } catch {
            print("PersonObject: toJson: Error")
            print(error)
            return [:]
        }
    }
}
