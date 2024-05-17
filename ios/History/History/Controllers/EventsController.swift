//
//  EventModel.swift
//  History
//
//  Created by Nathik Azad on 3/18/24.
//

import Foundation
class EventsController: ObservableObject {
    
    @Published var events: [EventModel] = []
    @Published var currentDate = Calendar.current.startOfDay(for: Date())
    let subscriptionId: String = "events"
    
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE MMMM dd" // Custom format for day, month, and date
        return formatter.string(from: currentDate)
    }
    
    func goToNextDay() {
        print("next day")
        currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
        fetchEvents(userId: Authentication.shared.userId!)
        listenToEvents(userId: Authentication.shared.userId!)
    }
    
    func goToPreviousDay() {
        print("previous day")
        currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate)!
        fetchEvents(userId: Authentication.shared.userId!)
        listenToEvents(userId: Authentication.shared.userId!)
    }
    
    struct EventsResponseData: Decodable {
        var data: EventsWrapper
        struct EventsWrapper: Decodable {
            var events: [EventModel]
        }
    }
    
    func fetchEvents(userId: Int) {
        Task {
            let graphqlQuery = EventsController.generateEventQuery(userId: userId, gte: currentDate)
            do {
                // Directly get the decoded ResponseData object from sendGraphQL
                let responseData: EventsResponseData = try await Hasura.shared.sendGraphQL(query: graphqlQuery, responseType: EventsResponseData.self)
                DispatchQueue.main.async {
                    self.events = responseData.data.events.sortEvents
//                    for event in self.events {
//                        print("Event: \(event.id) \(event.eventType) \(event.startTime?.formattedSuperShortDate ?? "") - \(event.endTime?.formattedSuperShortDate ?? "")")
//                        print(event.metadata?.meetingData)
//                    }
                }
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func listenToEvents(userId: Int) {
        cancelListener()
        // print("listening for events")
        let subscriptionQuery = EventsController.generateEventQuery(userId: userId, gte: currentDate)
        Hasura.shared.startListening(subscriptionId: subscriptionId, subscriptionQuery: subscriptionQuery, responseType: EventsResponseData.self) {result in
            switch result {
            case .success(let responseData):
                DispatchQueue.main.async {
                    self.events = responseData.data.events
                }
            case .failure(let error):
                print("Error processing message: \(error.localizedDescription)")
            }
        }
    }
    
    static func fetchEvents(userId: Int, eventType: String, locationId: Int? = nil, order: String?, metadataFilter: [String: Any]? = nil) async -> [EventModel] {
        
        let graphqlQuery = EventsController.generateEventQuery(userId: userId, eventType: eventType, locationId: locationId, order: order, metadataFilter: metadataFilter)
        var variables: [String: Any]? = nil
        if let metadataFilter = metadataFilter {
            variables = ["jsonfilter": metadataFilter]
        }
        do {
            // Directly get the decoded ResponseData object from sendGraphQL
            let responseData: EventsResponseData = try await Hasura.shared.sendGraphQL(query: graphqlQuery, variables: variables, responseType: EventsResponseData.self)
            return  responseData.data.events.sortEvents
        } catch {
            print("Error: \(error.localizedDescription)")
            return []
        }
        //        }
        
    }
    
    static func editEvent(id: Int, startTime: Date?, endTime:Date?, onSuccess: (() -> Void)? = nil) {
        print("editing event")
        let mutationQuery = """
        mutation MyMutation($id: Int!, $start_time: timestamp, $end_time: timestamp) {
          update_events_by_pk(pk_columns: {id: $id}, _set: {start_time: $start_time, end_time: $end_time}) {
            id
          }
        }
        """
        let variables: [String: Any] = ["id": id, "start_time": startTime?.toUTCString ?? nil, "end_time": endTime?.toUTCString ?? nil]
        struct EditEventResponse: Decodable {
            var data: EditEventWrapper
            struct EditEventWrapper: Decodable {
                var update_events_by_pk: EditedEvent
                struct EditedEvent: Decodable {
                    var id: Int
                }
            }
        }
        Task {
            let response: EditEventResponse = try await Hasura.shared.sendGraphQL(query: mutationQuery, variables: variables, responseType: EditEventResponse.self)
            DispatchQueue.main.async {
                print("Event edited: \(response.data.update_events_by_pk.id)")
                onSuccess?()
            }
        }
    }
    
    func deleteEvent(id: Int, onSuccess: (() -> Void)? = nil) {
        print("deleting event")
        let mutationQuery = """
        mutation {
            delete_events_by_pk(id: \(id)) {
              id
            }
        }
        """
        
        struct DeleteEventResponse: Decodable {
            var data: DeletedEventWrapper
            struct DeletedEventWrapper: Decodable {
                var delete_events_by_pk: DeletedEvent
                struct DeletedEvent: Decodable {
                    var id: Int
                }
            }
            
            
        }
        Task {
            let response: DeleteEventResponse = try await Hasura.shared.sendGraphQL(query: mutationQuery, responseType: DeleteEventResponse.self)
            DispatchQueue.main.async {
                print("Event deleted: \(response.data.delete_events_by_pk.id)")
                onSuccess?()
            }
            
        }
    }
    
    
    func cancelListener() {
        Hasura.shared.stopListening(subscriptionId: subscriptionId)
    }
    
    static func generateEventQuery(userId: Int, gte: Date? = nil, eventType: String? = nil, locationId: Int? = nil, isSubscription: Bool = false, order: String? = "asc", metadataFilter: [String: Any]? = nil) -> String {
        var whereClauses: [String] = ["{user_id: {_eq: \(userId)}}"] // Fix syntax for where clause
        
        if let gteDate = gte {
            let startOfTodayUTCString = gteDate.toUTCString
            let calendar = Calendar.current
            let dayAfterGteDate = calendar.date(byAdding: .day, value: +1, to: gteDate)!
            let dayAfterUTCString = dayAfterGteDate.toUTCString
            
            // Combining timestamp conditions using _and
            // Modify the timestampConditions to use the provided condition
            let timestampConditions = "{_or: [{_and: [{start_time: {_gt: \"\(startOfTodayUTCString)\"}}, {start_time: {_lt: \"\(dayAfterUTCString)\"}}]}, {_and: [{end_time: {_gt: \"\(startOfTodayUTCString)\"}}, {end_time: {_lt: \"\(dayAfterUTCString)\"}}]}]}"
            
            whereClauses.append(timestampConditions)
        }
        
        if let eventType = eventType {
            whereClauses.append("{event_type: {_eq: \"\(eventType)\"}}")
        }
        
        if let locationId = locationId {
            whereClauses.append("{metadata: {_contains: {location: {id: \(locationId)}}}}")
        }
        var jsonFilter = ""
        if let metadataFilter = metadataFilter {
            jsonFilter = "($jsonfilter: jsonb)"
            whereClauses.append("{metadata: {_contains: $jsonfilter}}")
        }
        
        var orderByClause: String
        if order == "asc" {
            orderByClause = "order_by: {"
            if whereClauses.contains("{start_time:") {
                orderByClause += "start_time: asc}"
            } else if whereClauses.contains("{end_time:") {
                orderByClause += "end_time: asc}"
            } else {
                orderByClause += "start_time: asc}"
            }
        } else {
            orderByClause = "order_by: {"
            if whereClauses.contains("{start_time:") {
                orderByClause += "start_time: desc}"
            } else if whereClauses.contains("{end_time:") {
                orderByClause += "end_time: desc}"
            } else {
                orderByClause += "start_time: desc}" // Default to start_time if neither is specified
            }
        }
        

        
        let whereClause = whereClauses.isEmpty ? "" : "where: {_and: [\(whereClauses.joined(separator: ", "))]}"
        let operationType = isSubscription ? "subscription" : "query"
        
        return """
        \(operationType) EventsQuery\(jsonFilter) {
            events(\(orderByClause) \(whereClause)) {
                start_time
                end_time
                id
                event_type
                parent_id
                metadata
                interaction {
                  timestamp
                  id
                  content
                }
            }
        }
        """
    }
}

struct EventModel: Decodable, Identifiable, Hashable, Equatable {
    var id: Int
    var parentId: Int?
    var eventType: String
    var startTime: Date?
    var endTime: Date?
    var metadata: Metadata?
    var interaction: InteractionModel?
    
    enum CodingKeys: String, CodingKey {
        case id
        case startTime = "start_time"
        case endTime = "end_time"
        case parentId
        case eventType = "event_type"
        case metadata
        case interaction
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        parentId = try container.decodeIfPresent(Int.self, forKey: .parentId)
        eventType = try container.decode(String.self, forKey: .eventType)
        metadata = try container.decodeIfPresent(Metadata.self, forKey: .metadata)
        interaction = try container.decodeIfPresent(InteractionModel.self, forKey: .interaction)
        
        // Decode the dates as Strings, then convert to Dates using getTime
        let startTimeString = try container.decodeIfPresent(String.self, forKey: .startTime)
        startTime = startTimeString?.getDate
        
        let endTimeString = try container.decodeIfPresent(String.self, forKey: .endTime)
        endTime = endTimeString?.getDate
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
        case "reading":
            let name = metadata?.readingData?.name?.capitalized
            return name != nil ? "Read \(name!)" : "Read Something"
        case "learning":
            let skill = metadata?.learningData?.skill?.capitalized
            let interactionContent: String = interaction?.content ?? ""
            return skill != nil ? "\(interactionContent)" : "Learned Something"
        case "shopping":
            return metadata?.shoppingData?.name ?? "Shopping"
        case "praying":
            if let names = metadata?.prayerData?.name?.map({ $0.capitalized }) {
                let formattedNames: String? = joinWords(names)
                return formattedNames != nil ? "Prayed \(formattedNames!)" : "Prayed"
            } else {
                return "Prayed"
            }
        case "cooking":
            return metadata?.cookingData?.name != nil ? "Cooked \(metadata!.cookingData!.name!.capitalized)" : "Cooked Something"
        case "feeling":
            let name = metadata?.feelingData?.name?.capitalized
            return name != nil ? "Felt \(name!)" : "Felt Something"
        case "meeting":
            let people = metadata?.meetingData?.people?.map({ $0.capitalized }) ?? []
            let action = metadata?.meetingData?.meetingType == "inperson" ? "Met" : "Spoke to"
            let formattedPeople: String? = joinWords(people)
            let location = metadata?.meetingData?.location != nil ? " at \(metadata!.meetingData!.location!)" : ""
            return formattedPeople != nil ? "\(action) \(formattedPeople!)\(location)" : "\(action) Someone"
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
    
    private func _formattedTime(fillWithX: Bool = false) -> String {
        let filler = fillWithX ? "XX:XX" : ""
        let formattedStartTime = startTime?.formattedTime ?? filler
        let formattedEndTime = endTime?.formattedTime ?? filler
        if (startTime != nil && endTime != nil) {
            return "\(formattedStartTime) - \(formattedEndTime)"
        } else if (startTime != nil) {
            return "\(formattedStartTime)"
        } else if (endTime != nil) {
            return  "\(formattedEndTime)"
        }
        return ""
    }
    
    var formattedTime: String {
        return _formattedTime(fillWithX: false)
    }
    
    var formattedTimeWithX: String {
        return _formattedTime(fillWithX: true)
    }
    
    var formattedDate: String {
        return "\(startTime?.formattedDate ?? endTime?.formattedDate ?? "")"
    }
    
    var date: Date {
        return startTime?.startOfDay ?? endTime!.startOfDay
    }
    
    var formattedTimeWithDate: String {
        return "\(formattedDate): \(formattedTime)"
    }
    
    var formattedTimeWithDateAndX: String {
        return "\(formattedDate): \(formattedTimeWithX)"
    }
    
    var totalHoursPerDay: TimeInterval? {
        if(startTime == nil || endTime == nil){
            return nil
        }
        return endTime!.timeIntervalSince(startTime!)
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







