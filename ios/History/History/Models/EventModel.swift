//
//  EventsModel.swift
//  History
//
//  Created by Nathik Azad on 5/17/24.
//

import Foundation


struct Association: Decodable {
    enum AssociationType: String, Decodable {
        case object = "objects"
        case location = "locations"
    }
    var id: Int
    var associtaionId: Int
    var associationType: AssociationType
    enum CodingKeys: String, CodingKey {
        case id
        case associtaionId = "ref_two_id"
        case associationType = "ref_two_table"
    }
}

struct EventModel: Decodable, Identifiable, Hashable, Equatable {
    var id: Int
    var parentId: Int?
    var eventType: EventType
    var startTime: Date?
    var endTime: Date?
    var metadata: Metadata?
    var interaction: InteractionModel?
    var locations: [LocationModel] = []
    var objects: [ASObject] = []
    var children: [EventModel] = []
    var associations: [Association] = []
    
    enum CodingKeys: String, CodingKey {
        case id
        case startTime = "start_time"
        case endTime = "end_time"
        case parentId = "parent_id"
        case eventType = "event_type"
        case metadata
        case interaction
        case locations
        case objects
        case children
        case associations
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        parentId = try container.decodeIfPresent(Int.self, forKey: .parentId)
        let eventTypeString = try container.decode(String.self, forKey: .eventType)
        eventType = eventTypeString.eventType
        metadata = try container.decodeIfPresent(Metadata.self, forKey: .metadata)
        interaction = try container.decodeIfPresent(InteractionModel.self, forKey: .interaction)
        
        // Decode the dates as Strings, then convert to Dates using getTime
        let startTimeString = try container.decodeIfPresent(String.self, forKey: .startTime)
        startTime = startTimeString?.getDate
        
        let endTimeString = try container.decodeIfPresent(String.self, forKey: .endTime)
        endTime = endTimeString?.getDate
        locations = try container.decodeIfPresent([LocationModel].self, forKey: .locations) ?? []
        objects = try container.decodeIfPresent([ASObject].self, forKey: .objects) ?? []
        children = try container.decodeIfPresent([EventModel].self, forKey: .children) ?? []
        associations = try container.decodeIfPresent([Association].self, forKey: .associations) ?? []
    }
    
    
    static func == (lhs: EventModel, rhs: EventModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var location: LocationModel? {
        return locations.first
    }
    
    var hasNotes: Bool {
        let count = metadata?.notes.count ?? 0
        return count > 0
    }
    
    var hasChildren: Bool {
        return children.count > 0
    }
    
    var hasChildrenOrNotes: Bool {
        return hasChildren || hasNotes
    }
    
    var depth: Int {
        return children.isEmpty ? 0 : 1 + children.map(\.depth).max()!
    }
    
    func getAssociation(associationType: Association.AssociationType, associationId: Int) -> Association? {
        return associations.filter({ $0.associtaionId == associationId}).first
    }
}

struct Metadata: Decodable {
    //    var location: LocationModel?
    
    var readingData: ReadingData?
    var learningData: LearningData?
    var shoppingData: ShoppingData?
    var prayerData: PrayerData?
    var cookingData: CookingData?
    var feelingData: FeelingData?
    var meetingData: MeetingData?
    var distractionData: DistractionData?
    var eatingData: [EatingData] = []
    var notes: [Date: String] = [:]
    
    
    enum CodingKeys: String, CodingKey {
        case readingData = "reading"
        case learningData = "learning"
        case cookingData = "cooking"
        case prayerData = "praying"
        case eatingData = "eating"
        case meetingData = "meeting"
        case feelingData = "feeling"
        case distractionData = "distraction"
        case notes
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        readingData = try container.decodeIfPresent(ReadingData.self, forKey: .readingData)
        learningData = try container.decodeIfPresent(LearningData.self, forKey: .learningData)
        prayerData = try container.decodeIfPresent(PrayerData.self, forKey: .prayerData)
        cookingData = try container.decodeIfPresent(CookingData.self, forKey: .cookingData)
        feelingData = try container.decodeIfPresent(FeelingData.self, forKey: .feelingData)
        meetingData = try container.decodeIfPresent(MeetingData.self, forKey: .meetingData)
        eatingData = try container.decodeIfPresent([EatingData].self, forKey: .eatingData) ?? []
        distractionData = try container.decodeIfPresent(DistractionData.self, forKey: .distractionData)
        let notes = try container.decodeIfPresent([String: String].self, forKey: .notes) ?? [:]
        for (dateString, note) in notes {
            if let date = dateString.getDate {
                self.notes[date] = note
            }
        }
    }
    
    var notesToJson: [String: String] {
        if !notes.isEmpty {
            var notes: [String: String] = [:]
            for (date, note) in self.notes {
                notes[date.toUTCString] = note
            }
            return notes
        }
        return [:]
    }
}


