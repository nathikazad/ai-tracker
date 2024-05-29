//
//  EventTypeModel.swift
//  History
//
//  Created by Nathik Azad on 5/28/24.
//

import Foundation

enum EventType: String, Decodable {
    case reading = "reading"
    case learning = "learning"
    case shopping = "shopping"
    case sleeping = "sleeping"
    case exercising = "exercising"
    case commuting = "commute"
    case dancing = "dancing"
    case staying = "stay"
    case distracting = "distraction"
    case praying = "praying"
    case cooking = "cooking"
    case feeling = "feeling"
    case meeting = "meeting"
    case eating = "eating"
    case working = "working"
    case unknown = "unknown"

    var capitalized: String {
        return self.rawValue.capitalized
    }
    
    var toString: String {
        return self.rawValue
    }
}

extension String {
    var eventType: EventType {
        return EventType(rawValue: self) ?? .unknown
    }
}

extension Metadata {
    struct FeelingData: Decodable {
        var name: String?
        var score: Int? = 0
        enum CodingKeys: String, CodingKey {
            case name
            case score
        }
    }

    struct MeetingData: Decodable {
        var people: [String]?
        var meetingType: String?
        var location: String?
        enum CodingKeys: String, CodingKey {
            case people
            case meetingType
            case location
        }
    }


    struct EatingData: Decodable {
        var name: String?
        var score: Int? = 0
        enum CodingKeys: String, CodingKey {
            case name
            case score
        }
    }

    struct CookingData: Decodable {
        var name: String?
        enum CodingKeys: String, CodingKey {
            case name
        }
    }

    struct LearningData: Decodable {
        var skill: String?
        enum CodingKeys: String, CodingKey {
            case skill
        }
    }

    struct ShoppingData: Decodable {
        var name: String?
        var amount: Int?
        enum CodingKeys: String, CodingKey {
            case name
            case amount
        }
    }

    struct PrayerData: Decodable {
        var name: [String]?
        var count: Int?
        enum CodingKeys: String, CodingKey {
            case name
            case count
        }
    }


    struct ReadingData: Decodable {
        var name: String?
        var pagesCount: Int?
        var currentPage: Int?
        var currentChapter: String?
        
        
        enum CodingKeys: String, CodingKey {
            case name
            case pagesCount = "pagescount"
            case currentPage = "currentpage"
            case currentChapter = "currentchapter"
        }
        
    }
}


extension EventModel {
    var toString: String {
        switch eventType {
        case .reading:
            let name = book?.name
            return name != nil ? "Read \(name!)" : "Read Something"
        case .learning:
            let skill = metadata?.learningData?.skill?.capitalized
            let interactionContent: String = interaction?.content ?? ""
            return skill != nil ? "\(interactionContent)" : "Learned Something"
        case .shopping:
            return metadata?.shoppingData?.name ?? "Shopping"
        case .praying:
            if let names = metadata?.prayerData?.name?.map({ $0.capitalized }) {
                let formattedNames: String? = names.joinWithAndAtEnd
                return formattedNames != nil ? "Prayed \(formattedNames!)" : "Prayed"
            } else {
                return "Prayed"
            }
        case .working:
            return "Working"
        case .exercising:
            return "Exercising"
        case .cooking:
            return metadata?.cookingData?.name != nil ? "Cooked \(metadata!.cookingData!.name!.capitalized)" : "Cooked Something"
        case .feeling:
            let name = metadata?.feelingData?.name?.capitalized
            return name != nil ? "Felt \(name!)" : "Felt Something"
        case .meeting:
            let people = metadata?.meetingData?.people?.map({ $0.capitalized }) ?? []
            let action = metadata?.meetingData?.meetingType == "inperson" ? "Met" : "Spoke to"
            let formattedPeople: String? = people.joinWithAndAtEnd
            let location = metadata?.meetingData?.location != nil ? " at \(metadata!.meetingData!.location!)" : ""
            return formattedPeople != nil ? "\(action) \(formattedPeople!)\(location)" : "\(action) Someone"
        case .sleeping:
            
            return "Slept \(timeTaken != nil ? "for \(timeTaken!)"  : "")"
        case .staying:
            let eventName = (socialEvent?.name != nil) ? " for \(socialEvent!.name)" : ""
            let locationName = location?.name ?? "Unnamed location"
            return "\(locationName)\(eventName)"// \(timeTaken)"
        case .commuting:
//            let distance = metadata?.distance != nil ? "\(metadata!.distance!)km" : ""
            return "Commute"// \(timeTaken) \(distance)"
        default:
            
            return interaction?.content ?? eventType.capitalized
        }
    }
}
