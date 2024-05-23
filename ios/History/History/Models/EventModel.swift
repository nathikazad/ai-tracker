//
//  EventsModel.swift
//  History
//
//  Created by Nathik Azad on 5/17/24.
//

import Foundation

enum EventType: String, Decodable {
    case reading = "reading"
    case learning = "learning"
    case shopping = "shopping"
    case sleeping = "sleeping"
    case commuting = "commute"
    case dancing = "dancing"
    case staying = "stay"
    case distracting = "distraction"
    case praying = "praying"
    case cooking = "cooking"
    case feeling = "feeling"
    case meeting = "meeting"
    case eating = "eating"
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
    
    enum CodingKeys: String, CodingKey {
        case id
        case startTime = "start_time"
        case endTime = "end_time"
        case parentId
        case eventType = "event_type"
        case metadata
        case interaction
        case locations
        case objects
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
    }
    
    fileprivate func joinWords(_ names: [String]) -> String? {
        if names.count > 1 {
            let allButLast = names.dropLast().joined(separator: ", ")
            let last = names.last!
            return "\(allButLast) and \(last)"
        } else if let first = names.first {
            return first
        } else {
            return nil
        }
    }
    
    var toString: String {
        switch eventType {
        case .reading:
            let name = metadata?.readingData?.name?.capitalized
            return name != nil ? "Read \(name!)" : "Read Something"
        case .learning:
            let skill = metadata?.learningData?.skill?.capitalized
            let interactionContent: String = interaction?.content ?? ""
            return skill != nil ? "\(interactionContent)" : "Learned Something"
        case .shopping:
            return metadata?.shoppingData?.name ?? "Shopping"
        case .praying:
            if let names = metadata?.prayerData?.name?.map({ $0.capitalized }) {
                let formattedNames: String? = joinWords(names)
                return formattedNames != nil ? "Prayed \(formattedNames!)" : "Prayed"
            } else {
                return "Prayed"
            }
        case .cooking:
            return metadata?.cookingData?.name != nil ? "Cooked \(metadata!.cookingData!.name!.capitalized)" : "Cooked Something"
        case .feeling:
            let name = metadata?.feelingData?.name?.capitalized
            return name != nil ? "Felt \(name!)" : "Felt Something"
        case .meeting:
            let people = metadata?.meetingData?.people?.map({ $0.capitalized }) ?? []
            let action = metadata?.meetingData?.meetingType == "inperson" ? "Met" : "Spoke to"
            let formattedPeople: String? = joinWords(people)
            let location = metadata?.meetingData?.location != nil ? " at \(metadata!.meetingData!.location!)" : ""
            return formattedPeople != nil ? "\(action) \(formattedPeople!)\(location)" : "\(action) Someone"
        case .sleeping:
            
            return "Slept \(timeTaken != nil ? "for \(timeTaken!)"  : "")"
        case .staying:
            let eventName = (socialEvent?.name != nil) ? " for \(socialEvent!.name)" : ""
            let locationName = location?.name ?? "Unnamed location"
            return "\(locationName)\(eventName)"// \(timeTaken)"
        case .commuting:
            let distance = metadata?.distance != nil ? "\(metadata!.distance!)km" : ""
            return "Commute"// \(timeTaken) \(distance)"
        default:
            
            return interaction?.content ?? eventType.capitalized
        }
    }
    
    
    static func == (lhs: EventModel, rhs: EventModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var book: ASObject? {
        return objects.books.first
    }
    
    var socialEvent: ASObject? {
        return objects.socialEvents.first
    }
    
    var location: LocationModel? {
        return locations.first
    }
}

extension [ASObject] {
    var books: [ASObject] {
        return self.objectIds(objectType: .book)
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

struct ASObject: Decodable {
    var id: Int
    var name: String
    var objectType: ASObjectType
    var events: [EventModel]
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case objectType = "object_type"
        case events
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        let objectTypeString = try container.decode(String.self, forKey: .objectType)
        objectType = ASObjectType(rawValue: objectTypeString) ?? .unknown
        events = try container.decodeIfPresent([EventModel].self, forKey: .events) ?? []
    }

    var dateStarted: Date? {
        return events.min(by: { $0.startTime ?? Date.distantFuture < $1.startTime ?? Date.distantFuture })?.startTime
    }

    var dateEnded: Date? {
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

struct Association: Decodable {
    var id: Int
    var table: String
    enum CodingKeys: String, CodingKey {
        case id = "ref_two_id"
        case table = "ref_two_table"
    }
}

struct Metadata: Decodable {
    var location: LocationModel?
    
    var readingData: ReadingData?
    var learningData: LearningData?
    var shoppingData: ShoppingData?
    var prayerData: PrayerData?
    var cookingData: CookingData?
    var feelingData: FeelingData?
    var meetingData: MeetingData?
    var eatingData: EatingData?
    
    var polyline: String?
    var timeTaken: String?
    var distance: String?
    enum CodingKeys: String, CodingKey {
        case location
        case polyline
        case timeTaken = "time_taken"
        case distance
        case readingData = "reading"
        case learningData = "learning"
        case cookingData = "cooking"
        case prayerData = "praying"
        case eatingData = "eating"
        case meetingData = "meeting"
        case feelingData = "feeling"
        
    }
    
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




extension [EventModel] {
    
    func filterEventsForTheLastNdays(days: Int) -> [EventModel] {
        let startDate = Calendar.currentInLocal.date(byAdding: .day, value: -Int(days), to: Date())!
        return self.filter { event in
            return (event.startTime != nil && event.startTime! >= startDate) || (event.endTime != nil && event.endTime! >= startDate)
        }.reversed()
    }

//    func datesChartData(days: Int) ->  [String] {
//        return self.filterEventsForTheLastNdays(days: Int(days)).map(\.endTime!.formattedSuperShortDate)
//    }

    func startTimes(days: Int, unique: Bool) -> [Date] {
        let events = self.filterEventsForTheLastNdays(days: days).filter { event in
            return event.startTime != nil
        }
        let startTimes = events.compactMap { $0.startTime } // Safely unwrap the start times

        if unique {
            // Group start times by day using the calendar to normalize dates to the start of each day
            let calendar = Calendar.current
            let groupedByDay = Dictionary(grouping: startTimes, by: { calendar.startOfDay(for: $0) })

            // For each group, find the minimum start time
            return groupedByDay.map { day, times in
                times.min() ?? day // Return the minimum time or the day itself if no times are available
            }
        } else {
            // If not unique, return all start times
            return startTimes
        }
    }


    func endTimes(days: Int, unique: Bool) -> [Date] {
        let events = self.filterEventsForTheLastNdays(days: days).filter { event in
            return event.endTime != nil
        }
        let endTimes = events.compactMap { $0.endTime }

        if unique {
            // Group end times by day
            let calendar = Calendar.current
            let groupedByDay = Dictionary(grouping: endTimes, by: { calendar.startOfDay(for: $0) })

            // For each group, find the maximum end time
            return groupedByDay.map { day, times in
                times.max() ?? day // Return the maximum time or the day itself if no times are available
            }
        } else {
            // If not unique, return all end times
            return endTimes
        }
    }
    
    func dailyTimes(days: Int) -> [(String, Date, Date)] {
            var dailyTimes = [(String, Date, Date)]()
            let now = Date()
            let calendar = Calendar.currentInLocal
            
            let filteredEvents = self.filter { event in
                guard let eventDate = event.startTime else { return false }
                let localEventDate = eventDate.toLocal
                return localEventDate >= calendar.date(byAdding: .day, value: -days, to: now)!
            }
            
            for event in filteredEvents {
                guard let utcStartTime = event.startTime, let utcEndTime = event.endTime else {
                    if let utcStartTime = event.startTime {
                        if(calendar.isDateInToday(utcStartTime) && event.endTime == nil){
                            dailyTimes.append((utcStartTime.formattedSuperShortDate, utcStartTime, now))
                        }
                    }
                    continue
                }
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                dateFormatter.timeZone = TimeZone.current

                let startDateString = dateFormatter.string(from: utcStartTime)
                let endDateString = dateFormatter.string(from: utcEndTime)
                
//                print("Local start date \(utcStartTime) end date \(utcEndTime)")

                // Split events spanning multiple days
                if startDateString != endDateString {
//                    print("Event spans multiple days")
                    let midnight = utcStartTime.endOfDay
//                    print("\(utcStartTime.formattedSuperShortDate) start date \(utcStartTime.toLocal) end date \(midnight.addMinute(-1).toLocal)")
//                    print("\(utcEndTime.formattedSuperShortDate) start date \(midnight.toLocal) end date \(utcEndTime.toLocal)")
                    dailyTimes.append((utcStartTime.formattedSuperShortDate, utcStartTime, midnight.addMinute(-1)))
                    dailyTimes.append((utcEndTime.formattedSuperShortDate, midnight, utcEndTime))
                } else {
//                    print("Event within the same day")
                    dailyTimes.append((utcStartTime.formattedSuperShortDate, utcStartTime, utcEndTime))
                }
            }
            
            return dailyTimes.sorted { $0.1 < $1.1 }
        }
    
    func dailyTotals(days: Int) -> [(Date, Double)] {
        let dailyTimes = self.dailyTimes(days: days)
        var dailyTotals = [Date: Double]()
        
        for (_, startTime, endTime) in dailyTimes {
            let day = Calendar.currentInLocal.startOfDay(for:startTime)
            let duration = endTime.timeIntervalSince(startTime) / 3600
            if let total = dailyTotals[day] {
                dailyTotals[day] = total + duration
            } else {
                dailyTotals[day] = duration
            }
        }
        
        
        let sortedTotals = dailyTotals.sorted { $0.key < $1.key }
        return sortedTotals.map { ($0.key, $0.value) }
    }
    
    func totalHours(days: Int) -> Int {
        let dailyTimes = self.dailyTimes(days: days)
        var total = 0.0
        for (_, startTime, endTime) in dailyTimes {
//            let day = Calendar.currentInLocal.startOfDay(for:startTime)
            let duration = endTime.timeIntervalSince(startTime) / 3600
            total = total + duration
        }
        return Int(total)
    }
    
    func totalDays(days: Int) -> Int {
        return dailyTotals(days: days).count
    }
    
    var maxDays: Double {
        guard let earliestDate = self.min(by: { $0.startTime ?? Date() < $1.startTime ?? Date() })?.startTime else {
            return 7 // or some default minimum
        }
        let daysDifference = Calendar.current.dateComponents([.day], from: earliestDate, to: Date()).day ?? 0
        return Double(daysDifference + 1)
    }
    
    var sortEvents: [EventModel] {
        return self.sorted { (event1, event2) -> Bool in
            let date1 = event1.startTime ?? event1.endTime
            let date2 = event2.startTime ?? event2.endTime
            return date1 ?? Date.distantFuture < date2 ?? Date.distantFuture
        }
    }
}





