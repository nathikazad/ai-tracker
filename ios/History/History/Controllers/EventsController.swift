//
//  EventModel.swift
//  History
//
//  Created by Nathik Azad on 3/18/24.
//

import Foundation
class EventsController: ObservableObject {
    
    struct EventsResponseData: Decodable {
        var data: EventsWrapper
        struct EventsWrapper: Decodable {
            var events: [EventModel]
        }
    }
    
    static func fetchEvents(userId: Int, date: Date?) async -> [EventModel] {
        let (graphqlQuery, variables) = EventsController.generateEventQuery(userId: userId, gte: date)
        do {
            // Directly get the decoded ResponseData object from sendGraphQL
            let responseData: EventsResponseData = try await Hasura.shared.sendGraphQL(query: graphqlQuery, responseType: EventsResponseData.self)
            return responseData.data.events.sortEvents
        } catch {
            print("Error: \(error.localizedDescription)")
            return []
        }
    }
    
    static func fetchEvent(id: Int) async -> EventModel? {
        let (graphqlQuery, variables) = EventsController.generateEventQuery(id: id, nested: false)
        do {
            // Directly get the decoded ResponseData object from sendGraphQL
            let responseData: EventsResponseData = try await Hasura.shared.sendGraphQL(query: graphqlQuery,responseType: EventsResponseData.self)
            if(responseData.data.events.count > 0) {
                return responseData.data.events[0]
            }
        } catch {
            print("Error: \(error.localizedDescription)")
            return nil
        }
        return nil
    }
    
    static func listenToEvent(id: Int, subscriptionId:String, eventUpdateCallback: @escaping (EventModel) -> Void) {
        let (subscriptionQuery, variables) = EventsController.generateEventQuery(id: id, isSubscription: true, nested: false)
        Hasura.shared.startListening(subscriptionId: subscriptionId, subscriptionQuery: subscriptionQuery, responseType: EventsResponseData.self) {result in
            switch result {
            case .success(let responseData):
                if(responseData.data.events.count > 0) {
                    eventUpdateCallback(responseData.data.events[0])
                }
                
            case .failure(let error):
                print("Error processing message: \(error.localizedDescription)")
            }
        }
        
    }
    
    static func listenToEvents(userId: Int, subscriptionId:String, nested: Bool, date:Date?, parentId: Int? = nil, eventUpdateCallback: @escaping ([EventModel]) -> Void) {
        cancelListener(subscriptionId: subscriptionId)
        let (subscriptionQuery, variables) = EventsController.generateEventQuery(userId: userId, gte: date, isSubscription: true, parentId: parentId, nested: nested)
        Hasura.shared.startListening(subscriptionId: subscriptionId, subscriptionQuery: subscriptionQuery, responseType: EventsResponseData.self) {result in
            switch result {
            case .success(let responseData):
                eventUpdateCallback(responseData.data.events)
            case .failure(let error):
                print("Error processing message: \(error.localizedDescription)")
            }
        }
    }
    
    static func fetchEvents(nested: Bool, userId: Int? = nil, eventType: EventType? = nil, locationId: Int? = nil, order: String?, metadataFilter: [String: Any]? = nil, parentId: Int? = nil) async -> [EventModel] {
        
        let (graphqlQuery, variables) = EventsController.generateEventQuery(userId: userId, eventType: eventType, locationId: locationId, order: order, metadataFilter: metadataFilter, parentId: parentId, nested: nested)
        do {
            let responseData: EventsResponseData = try await Hasura.shared.sendGraphQL(query: graphqlQuery, variables: variables, responseType: EventsResponseData.self)
            return  responseData.data.events.sortEvents
        } catch {
            print("Error: \(error.localizedDescription)")
            return []
        }
        
    }
    
    static func editEvent(id: Int, startTime: Date? = nil, endTime:Date? = nil, parentId: Int? = nil, notes:[String:String]? = nil, onSuccess: (() -> Void)? = nil) {
        let (mutationQuery, variables) = EventsController.mutationQuery(id: id, startTime: startTime, endTime: endTime, parentId: parentId, notes: notes)
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

    static func mutationQuery(id: Int, startTime: Date? = nil, endTime: Date? = nil, parentId: Int? = nil, notes:[String:String]? = nil ) -> (String, [String: Any]) {
        var parameterClauses: [String] = []
        var setClauses: [String] = []
        var variables: [String: Any] = ["id": id]

        if let startTime = startTime {
            parameterClauses.append("$start_time: timestamp!")
            setClauses.append("start_time: $start_time")
            variables["start_time"] = startTime.toUTCString
        }
        if let endTime = endTime {
            parameterClauses.append("$end_time: timestamp!")
            setClauses.append("end_time: $end_time")
            variables["end_time"] = endTime.toUTCString
        }
        if let parentId = parentId {
            parameterClauses.append("$parent_id: Int!")
            setClauses.append("parent_id: $parent_id")
            variables["parent_id"] = parentId
        }
        if let notes = notes {
            parameterClauses.append("$metadata: jsonb!")
            setClauses.append("metadata: $metadata")
            variables["metadata"] = ["notes": notes]
        }
        let mutationQuery = """
        mutation MyMutation($id: Int!, \(parameterClauses.joined(separator: ", "))) {
          update_events_by_pk(pk_columns: {id: $id}, _set: { \(setClauses.joined(separator: ", ")) }) {
            id
          }
        }
        """
        return (mutationQuery, variables)
    }
    
    
    
    static func deleteEvent(id: Int, onSuccess: (() -> Void)? = nil) {
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
    
    
    static func cancelListener(subscriptionId: String) {
        Hasura.shared.stopListening(subscriptionId: subscriptionId)
    }
    
    static func generateEventQuery(userId: Int? = nil, id: Int? = nil, gte: Date? = nil, eventType: EventType? = nil, locationId: Int? = nil, isSubscription: Bool = false, order: String? = "asc", metadataFilter: [String: Any]? = nil, parentId: Int? = nil, nested: Bool = false) -> (String, [String: Any]) {
        var whereClauses: [String] = [] 
        var variables: [String: Any] = [:]
        var parameterClauses: [String] = []
        var includeChildren = false
        if let userId = userId {
            whereClauses.append("{user_id: {_eq: \(userId)}}")
        }
        
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
        
        if let parentId = parentId {
            whereClauses.append("{parent_id: {_eq: \(parentId)}}")
            includeChildren = true
        } else if nested {
            whereClauses.append("{parent_id: {_is_null: true }}")
            includeChildren = true
        }
        
        if let id = id {
            whereClauses.append("{id: {_eq: \(id)}}")
        }
        
        var jsonFilter = ""
        if let metadataFilter = metadataFilter {
            parameterClauses.append("$jsonfilter: jsonb")
            whereClauses.append("{metadata: {_contains: $jsonfilter}}")
            variables = ["jsonfilter": metadataFilter]
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
//        let childrenSelections = includeChildren ? "children {\(EventsController.eventSelections)}" : ""
        let childrenSelections = "children {\(EventsController.eventSelections)\n children {\(EventsController.eventSelections)}}"
        let parameterString = parameterClauses.isEmpty ? "" : "(\(parameterClauses.joined(separator: ", ")))"

        let query = """
        \(operationType) EventsQuery\(parameterString) {
            events(\(orderByClause) \(whereClause)) {
                \(EventsController.eventSelections)
                \(childrenSelections)
            }
        }
        """
        return (query, variables)
    }

    private static var eventSelections: String {
        return """
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
        """
    }
}


