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
    
    static func fetchEvents(userId: Int, eventType: String, locationId: Int, order: String?) async -> [EventModel] {
        
        let graphqlQuery = EventsController.generateEventQuery(userId: userId, eventType: eventType, locationId: locationId, order: order)
            do {
                // Directly get the decoded ResponseData object from sendGraphQL
                let responseData: EventsResponseData = try await Hasura.shared.sendGraphQL(query: graphqlQuery, responseType: EventsResponseData.self)
                return responseData.data.events
            } catch {
                print("Error: \(error.localizedDescription)")
                return []
            }
//        }
        
    }
    
    func editEvent(id: Int, content: String, onSuccess: (() -> Void)? = nil) {
        print("editing event")
        let mutationQuery = """
        mutation MyMutation($id: Int!, $content: String!) {
          update_events_by_pk(pk_columns: {id: $id}, _set: {content: $content}) {
            id
          }
        }
        """
        let variables: [String: Any] = ["id": id, "content": content]
        
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
            let startOfTodayUTCString = HasuraUtil.dateToUTCString(date: gteDate)
            let calendar = Calendar.current
            let dayAfterGteDate = calendar.date(byAdding: .day, value: +1, to: gteDate)!
            let dayAfterUTCString = HasuraUtil.dateToUTCString(date: dayAfterGteDate)
            
            // Combining timestamp conditions using _and
            let timestampConditions = "{start_time: {_gte: \"\(startOfTodayUTCString)\", _lte: \"\(dayAfterUTCString)\"}}"
            whereClauses.append(timestampConditions)
        }
        
        if let eventType = eventType {
            whereClauses.append("{event_type: {_eq: \"\(eventType)\"}}")
        }
        
        if let locationId = locationId {
            whereClauses.append("{metadata: {_contains: {location: {id: \(locationId)}}}}")
        }
        
        var orderByClause = "order_by: {start_time: \(order!)}"
        
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



struct EventModel: Decodable, Identifiable {
    var id: Int
    var parentId: Int?
    var eventType: String
    var startTime: String?
    var endTime: String?
    var metadata: Metadata?
    
    enum CodingKeys: String, CodingKey {
        case id
        case startTime = "start_time"
        case endTime = "end_time"
        case parentId
        case eventType = "event_type"
        case metadata
    }
    
    var formattedTime: String {
        let formattedStartTime = HasuraUtil.formattedTimeWithoutTimeZone(timestamp: startTime) ?? ""
        let formattedEndTime = HasuraUtil.formattedTimeWithoutTimeZone(timestamp: endTime)
        if let endTime = formattedEndTime {
            return "\(formattedStartTime) - \(endTime)"
        } else {
            return "\(formattedStartTime)"
        }
    }
    
    var formattedTimeWithDate: String {
        return "\(HasuraUtil.formattedDateWithoutTimeZone(timestamp: startTime) ?? ""): \(formattedTime)"
    }

}

struct Metadata: Decodable {
    var location: LocationModel?
    var polyline: String?
    enum CodingKeys: String, CodingKey {
        case location
        case polyline
    }
}






