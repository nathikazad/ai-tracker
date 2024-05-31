//
//  EventModel.swift
//  History
//
//  Created by Nathik Azad on 3/18/24.
//

import Foundation
class EventsController: ObservableObject {
        
    struct EventsResponseData: GraphQLData {
        var events: [EventModel]
    }
    
    static func fetchEvents(userId: Int, date: Date?) async -> [EventModel] {
        let (graphqlQuery, _) = EventsController.generateEventQuery(userId: userId, gte: date)
        do {
            // Directly get the decoded ResponseData object from sendGraphQL
            let responseData: GraphQLResponse<EventsResponseData> = try await Hasura.shared.sendGraphQL(query: graphqlQuery, responseType: GraphQLResponse<EventsResponseData>.self)
            return responseData.data.events.sortEvents
        } catch {
            print("Error: \(error.localizedDescription)")
            return []
        }
    }
    
    static func fetchEvent(id: Int) async -> EventModel? {
        let (graphqlQuery, _) = EventsController.generateEventQuery(id: id, onlyRootNodes: false)
        do {
            // Directly get the decoded ResponseData object from sendGraphQL
            let responseData: GraphQLResponse<EventsResponseData> = try await Hasura.shared.sendGraphQL(query: graphqlQuery,responseType: GraphQLResponse<EventsResponseData>.self)
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
        let (subscriptionQuery, _) = EventsController.generateEventQuery(id: id, isSubscription: true, onlyRootNodes: false)
        Hasura.shared.startListening(subscriptionId: subscriptionId, subscriptionQuery: subscriptionQuery, responseType: GraphQLResponse<EventsResponseData>.self) {result in
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
    
    static func listenToEvents(userId: Int, subscriptionId:String, onlyRootNodes: Bool, date:Date?, parentId: Int? = nil, eventUpdateCallback: @escaping ([EventModel]) -> Void) {
        cancelListener(subscriptionId: subscriptionId)
        let (subscriptionQuery, _) = EventsController.generateEventQuery(userId: userId, gte: date, isSubscription: true, parentId: parentId, onlyRootNodes: onlyRootNodes)
        Hasura.shared.startListening(subscriptionId: subscriptionId, subscriptionQuery: subscriptionQuery, responseType: GraphQLResponse<EventsResponseData>.self) {result in
            switch result {
            case .success(let responseData):
                eventUpdateCallback(responseData.data.events)
            case .failure(let error):
                print("Error processing message: \(error.localizedDescription)")
            }
        }
    }
    
    static func fetchEvents(userId: Int? = nil, onlyRootNodes: Bool = false, eventType: EventType? = nil, locationId: Int? = nil, order: String?, metadataFilter: [String: Any]? = nil, parentId: Int? = nil) async -> [EventModel] {
        
        let (graphqlQuery, variables) = EventsController.generateEventQuery(userId: userId, eventType: eventType, locationId: locationId, order: order, metadataFilter: metadataFilter, parentId: parentId, onlyRootNodes: onlyRootNodes)
        print(graphqlQuery)
        print(variables)
        do {
            let responseData: GraphQLResponse<EventsResponseData> = try await Hasura.shared.sendGraphQL(query: graphqlQuery, variables: variables, responseType: GraphQLResponse<EventsResponseData>.self)
            return  responseData.data.events.sortEvents
        } catch {
            print("Error: \(error.localizedDescription)")
            return []
        }
        
    }
    
    static func editEvent(id: Int, startTime: Date? = nil, endTime:Date? = nil, parentId: Int? = nil, notes:[String:String]? = nil, metadata:[String:Any]? = nil, images:[String]? = nil, passNullTimeValues: Bool = false, onSuccess: (() -> Void)? = nil) {
        let (mutationQuery, variables) = EventsController.mutationQuery(id: id, startTime: startTime, endTime: endTime, parentId: parentId, notes: notes, metadata: metadata, images:images, passNullTimeValues: passNullTimeValues)

        struct EditEventResponse: GraphQLData {
            var update_events_by_pk: EditedEvent
            struct EditedEvent: Decodable {
                var id: Int
            }
        }

        Task {
            let response: GraphQLResponse<EditEventResponse> = try await Hasura.shared.sendGraphQL(query: mutationQuery, variables: variables, responseType: GraphQLResponse<EditEventResponse>.self)
            DispatchQueue.main.async {
                print("Event edited: \(response.data.update_events_by_pk.id)")
                onSuccess?()
            }
        }
    }

    static func mutationQuery(id: Int, startTime: Date? = nil, endTime: Date? = nil, parentId: Int? = nil, notes:[String:String]? = nil, metadata:[String:Any]? = nil, images:[String]? = nil, passNullTimeValues: Bool = false) -> (String, [String: Any]) {
        var hasuraMutation: HasuraMutation = HasuraMutation(mutationFor: "update_events_by_pk", mutationName: "EventMutation", mutationType: .update, id: id)
        hasuraMutation.addParameter(name: "start_time", type: "timestamp", value: startTime?.toUTCString, passNullValue: passNullTimeValues)
        hasuraMutation.addParameter(name: "end_time", type: "timestamp", value: endTime?.toUTCString, passNullValue: passNullTimeValues)
        hasuraMutation.addParameter(name: "parent_id", type: "Int", value: parentId)
        if let notes = notes {
            hasuraMutation.addParameter(name: "metadata", type: "jsonb", value: ["notes": notes])
        }
        if let images = images {
            hasuraMutation.addParameter(name: "metadata", type: "jsonb", value: ["images": images])
        }
        if let metadata = metadata {
            hasuraMutation.addParameter(name: "metadata", type: "jsonb", value: metadata)
        }
        return hasuraMutation.getMutationAndVariables
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
        
        
        
        struct DeleteEventResponse: GraphQLData {
            var delete_events_by_pk: DeletedEvent
            struct DeletedEvent: Decodable {
                var id: Int
            }
        }
        
        Task {
            let response: GraphQLResponse<DeleteEventResponse> = try await Hasura.shared.sendGraphQL(query: mutationQuery, responseType: GraphQLResponse<DeleteEventResponse>.self)
            DispatchQueue.main.async {
                print("Event deleted: \(response.data.delete_events_by_pk.id)")
                onSuccess?()
            }
            
        }
    }
    
    
    static func cancelListener(subscriptionId: String) {
        Hasura.shared.stopListening(subscriptionId: subscriptionId)
    }
    
    static func generateEventQuery(userId: Int? = nil, id: Int? = nil, gte: Date? = nil, eventType: EventType? = nil, locationId: Int? = nil, isSubscription: Bool = false, order: String? = "asc", metadataFilter: [String: Any]? = nil, parentId: Int? = nil, onlyRootNodes: Bool = false) -> (String, [String: Any]) {
        var whereClauses: [String] = []
        var variables: [String: Any] = [:]
        var parameterClauses: [String] = []
//        var includeChildren = false
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
//            includeChildren = true
        } else if onlyRootNodes {
            whereClauses.append("{parent_id: {_is_null: true }}")
//            includeChildren = true
        }
        
        if let id = id {
            whereClauses.append("{id: {_eq: \(id)}}")
        }
        
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

    static var eventSelections: String {
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
            associations {
              id
              ref_two_id
              ref_two_table
            }
        """
    }
}


