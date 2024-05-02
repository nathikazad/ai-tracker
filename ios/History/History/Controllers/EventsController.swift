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
                    self.events = responseData.data.events
                }
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    static func fetchEvents(userId: Int, eventType: String, locationId: Int? = nil, order: String?) async -> [EventModel] {
        
        let graphqlQuery = EventsController.generateEventQuery(userId: userId, eventType: eventType, locationId: locationId, order: order)
        do {
            // Directly get the decoded ResponseData object from sendGraphQL
            let responseData: EventsResponseData = try await Hasura.shared.sendGraphQL(query: graphqlQuery, responseType: EventsResponseData.self)
            return  responseData.data.events.sortEvents
        } catch {
            print("Error: \(error.localizedDescription)")
            return []
        }
        //        }
        
    }
    
    static func editEvent(id: Int, startTime: Date, endTime:Date, onSuccess: (() -> Void)? = nil) {
        print("editing event")
        let mutationQuery = """
        mutation MyMutation($id: Int!, $start_time: timestamp!, $end_time: timestamp!) {
          update_events_by_pk(pk_columns: {id: $id}, _set: {start_time: $start_time, end_time: $end_time}) {
            id
          }
        }
        """
        let variables: [String: Any] = ["id": id, "start_time": startTime.toUTCString, "end_time": endTime.toUTCString]
        
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
    
    
    
    func listenToEvents(userId: Int) {
        cancelListener()
        // print("listening for events")
        let subscriptionQuery = EventsController.generateEventQuery(userId: userId, gte: currentDate, isSubscription: true)
        
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
    
    
    func cancelListener() {
        Hasura.shared.stopListening(uniqueID: subscriptionId)
    }
    
    static func generateEventQuery(userId: Int, gte: Date? = nil, eventType: String? = nil, locationId: Int? = nil, isSubscription: Bool = false, order: String? = "asc") -> String {
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
        \(operationType) {
            events(\(orderByClause) \(whereClause)) {
                start_time
                end_time
                id
                event_type
                parent_id
                metadata
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
    
    enum CodingKeys: String, CodingKey {
        case id
        case startTime = "start_time"
        case endTime = "end_time"
        case parentId
        case eventType = "event_type"
        case metadata
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        parentId = try container.decodeIfPresent(Int.self, forKey: .parentId)
        eventType = try container.decode(String.self, forKey: .eventType)
        metadata = try container.decodeIfPresent(Metadata.self, forKey: .metadata)
        
        // Decode the dates as Strings, then convert to Dates using getTime
        let startTimeString = try container.decodeIfPresent(String.self, forKey: .startTime)
        startTime = HasuraUtil.getTime(timestamp: startTimeString)
        
        let endTimeString = try container.decodeIfPresent(String.self, forKey: .endTime)
        endTime = HasuraUtil.getTime(timestamp: endTimeString)
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
        return "\(formattedStartTime) - \(formattedEndTime)"
    }
    
    var formattedTime: String {
        return _formattedTime(fillWithX: false)
    }
    
    var formattedTimeWithX: String {
        return _formattedTime(fillWithX: true)
    }
    
    
    var formattedTimeWithDate: String {
        return "\(startTime?.formattedDate ?? endTime?.formattedDate ?? ""): \(formattedTime)"
    }
    
    var formattedTimeWithDateAndX: String {
        return "\(startTime?.formattedDate ?? endTime?.formattedDate ?? ""): \(formattedTimeWithX)"
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
    var polyline: String?
    var timeTaken: String?
    var distance: String?
    enum CodingKeys: String, CodingKey {
        case location
        case polyline
        case timeTaken = "time_taken"
        case distance
    }
}


extension Array where Element == EventModel {
    
    func filteredEvents(days: Int) -> [EventModel] {
        let startDate = Calendar.current.date(byAdding: .day, value: -Int(days), to: Date())!
        return self.filter { event in
            event.startTime != nil && event.endTime != nil &&
            event.startTime! >= startDate // Filter to include only events from the last 'selectedDays' days
        }.reversed()
    }

    func datesChartData(days: Int) ->  [String] {
        return self.filteredEvents(days: Int(days)).map(\.endTime!.formattedSuperShortDate)
    }

    func startTimes(days: Int, unique: Bool) -> [Date] {
        let events = self.filteredEvents(days: days)
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
        let events = self.filteredEvents(days: days)
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
            var calendar = Calendar.current
            var localTimeZone: TimeZone = TimeZone.current
            calendar.timeZone = localTimeZone
            
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
                dateFormatter.timeZone = localTimeZone

                let startDateString = dateFormatter.string(from: utcStartTime)
                let endDateString = dateFormatter.string(from: utcEndTime)
                
                print("Local start date \(utcStartTime) end date \(utcEndTime)")

                // Split events spanning multiple days
                if startDateString != endDateString {
                    print("Event spans multiple days")
                    let midnight = utcStartTime.endOfDay
                    print("\(utcStartTime.formattedSuperShortDate) start date \(utcStartTime.toLocal) end date \(midnight.addMinute(-1).toLocal)")
                    print("\(utcEndTime.formattedSuperShortDate) start date \(midnight.toLocal) end date \(utcEndTime.toLocal)")
                    dailyTimes.append((utcStartTime.formattedSuperShortDate, utcStartTime, midnight.addMinute(-1)))
                    dailyTimes.append((utcEndTime.formattedSuperShortDate, midnight, utcEndTime))
                } else {
                    print("Event within the same day")
                    dailyTimes.append((utcStartTime.formattedSuperShortDate, utcStartTime, utcEndTime))
                }
            }
            
            return dailyTimes.sorted { $0.1 < $1.1 }
        }
    
    func dailyTotals(days: Int) -> [(Date, Double)] {
        let dailyTimes = self.dailyTimes(days: days)
        var dailyTotals = [Date: Double]()
        
        for (sday, startTime, endTime) in dailyTimes {
            let day = Calendar.current.startOfDay(for:startTime)
            let duration = endTime.timeIntervalSince(startTime) / 3600
            if var total = dailyTotals[day] {
                dailyTotals[day] = total + duration
            } else {
                dailyTotals[day] = duration
            }
        }
        
        
        let sortedTotals = dailyTotals.sorted { $0.key < $1.key }
        return sortedTotals.map { ($0.key, $0.value) }
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
            return date1 ?? Date.distantFuture > date2 ?? Date.distantFuture
        }
    }
}







