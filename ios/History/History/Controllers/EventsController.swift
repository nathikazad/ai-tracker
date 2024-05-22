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
                }
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func listenToEvents(userId: Int) {
        cancelListener()
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
    
    static func fetchEvents(userId: Int, eventType: EventType, locationId: Int? = nil, order: String?, metadataFilter: [String: Any]? = nil) async -> [EventModel] {
        
        let graphqlQuery = EventsController.generateEventQuery(userId: userId, eventType: eventType, locationId: locationId, order: order, metadataFilter: metadataFilter)
        var variables: [String: Any]? = nil
        if let metadataFilter = metadataFilter {
            variables = ["jsonfilter": metadataFilter]
        }
        do {
            let responseData: EventsResponseData = try await Hasura.shared.sendGraphQL(query: graphqlQuery, variables: variables, responseType: EventsResponseData.self)
            return  responseData.data.events.sortEvents
        } catch {
            print("Error: \(error.localizedDescription)")
            return []
        }
        
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
    
    static func generateEventQuery(userId: Int, gte: Date? = nil, eventType: EventType? = nil, locationId: Int? = nil, isSubscription: Bool = false, order: String? = "asc", metadataFilter: [String: Any]? = nil) -> String {
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
            whereClauses.append("{event_type: {_eq: \"\(eventType.toString)\"}}")
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
                locations {
                  id
                  name
                  location
                }
                objects {
                    object_type
                    name
                    id
                }
            }
        }
        """
    }
}


