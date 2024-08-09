//
//  InteractionModel.swift
//  History
//
//  Created by Nathik Azad on 3/18/24.
//

import Foundation
import SwiftUI
class InteractionsController: ObservableObject {
    static let subscriptionId: String = "interactions"
    

    
    struct InteractionsResponseData: Decodable {
        var data: InteractionsWrapper
        struct InteractionsWrapper: Decodable {
            var interactions: [InteractionModel]
        }
    }
    
    static func fetchInteractions(userId: Int) async -> [InteractionModel] {
        
        let graphqlQuery = InteractionsController.generateQuery(userId: userId, gte: state.currentDate)
        do {
            let responseData: InteractionsResponseData = try await Hasura.shared.sendGraphQL(query: graphqlQuery, responseType: InteractionsResponseData.self)
            
            return responseData.data.interactions
        } catch {
            print("Error: \(error.localizedDescription)")
        }
        return []
    }
    
    static func editInteraction(
        id: Int,
        fieldName: String,
        fieldValue: String,
        onSuccess: (() -> Void)? = nil
    ) {
        print("Editing interaction")
        
        // Build the mutation query using the field name
        let mutationQuery = """
                mutation MyMutation($id: Int!) {
                  update_interactions_by_pk(pk_columns: {id: $id}, _set: {\(fieldName): "\(fieldValue)"}) {
                    id
                  }
                }
        """
        // Use a dictionary to dynamically build the variables
        let variables: [String: Any] = ["id": id]
        struct EditInteractionResponse: Decodable {
            var data: EditInteractionWrapper
            struct EditInteractionWrapper: Decodable {
                var update_interactions_by_pk: EditedInteraction
                struct EditedInteraction: Decodable {
                    var id: Int
                }
            }
        }
        
        Task {
            do {
                let response: EditInteractionResponse = try await Hasura.shared.sendGraphQL(
                    query: mutationQuery,
                    variables: variables,
                    responseType: EditInteractionResponse.self
                )
                DispatchQueue.main.async {
                    print("Interaction edited: \(response.data.update_interactions_by_pk.id)")
                    onSuccess?()
                }
            } catch {
                print("Failed to edit interaction: \(error)")
            }
        }
    }
    
    static func deleteInteraction(id: Int, onSuccess: (() -> Void)? = nil) {
        print("deleting interaction")
        let mutationQuery = """
        mutation {
            delete_interactions_by_pk(id: \(id)) {
              id
            }
        }
        """
        
        struct DeleteInteractionResponse: Decodable {
            var data: DeletedInteractionWrapper
            struct DeletedInteractionWrapper: Decodable {
                var delete_interactions_by_pk: DeletedInteraction
                struct DeletedInteraction: Decodable {
                    var id: Int
                }
            }
            
            
        }
        Task {
            let response: DeleteInteractionResponse = try await Hasura.shared.sendGraphQL(query: mutationQuery, responseType: DeleteInteractionResponse.self)
            DispatchQueue.main.async {
                print("Interaction deleted: \(response.data.delete_interactions_by_pk.id)")
                onSuccess?()
            }
            
        }
    }
    
    
    
    static func listenToInteractions(userId: Int, eventUpdateCallback: @escaping ([InteractionModel]) -> Void) {
        cancelListener()
        // print("listening for interactions")
        let subscriptionQuery = InteractionsController.generateQuery(userId: userId, gte: state.currentDate, isSubscription: true)
        
        Hasura.shared.startListening(subscriptionId: subscriptionId, subscriptionQuery: subscriptionQuery, responseType: InteractionsResponseData.self) {result in
            switch result {
            case .success(let responseData):
                eventUpdateCallback(responseData.data.interactions)
            case .failure(let error):
                print("Error processing message: \(error.localizedDescription)")
            }
        }
    }
    
    
    static func cancelListener() {
        Hasura.shared.stopListening(subscriptionId: subscriptionId)
    }
    
    static private func generateQuery(userId: Int,gte: Date? = nil, isSubscription: Bool = false) -> String {
        let limitClause = ""
        var whereClauses: [String] = ["{user_id: {_eq: \(userId)}", "content_type: {_eq: \"event\"}}"]
        
        if let gteDate = gte {
            let startOfTodayUTCString = gteDate.toUTCString
            let calendar = Calendar.current
            let dayAfterGteDate = calendar.date(byAdding: .day, value: +1, to: gteDate)!
            let dayAfterUTCString = dayAfterGteDate.toUTCString
            
            // Combining timestamp conditions using _and
            let timestampConditions = "{_and: [{timestamp: {_gte: \"\(startOfTodayUTCString)\"}}, {timestamp: {_lte: \"\(dayAfterUTCString)\"}}]}"
            whereClauses.append(timestampConditions)
        }
        
        let whereClause = whereClauses.isEmpty ? "" : "where: {_and: [\(whereClauses.joined(separator: ", "))]}"
        let operationType = isSubscription ? "subscription" : "query"
        
        return """
        \(operationType) {
            interactions(order_by: {timestamp: asc}\(limitClause.isEmpty ? "" : limitClause) \(whereClause)) {
                timestamp
                id
                content
                events {
                    id
                    event_type
                    metadata
                }
            }
        }
        """
    }
}

struct InteractionModel: Decodable, Identifiable, Hashable, Equatable {
    var id: Int
    var content: String
    var timestamp: Date
    var events: [EventModel]
    
    enum CodingKeys: String, CodingKey {
        case id
        case content
        case timestamp
        case events
    }
    
    static func == (lhs: InteractionModel, rhs: InteractionModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        content = try container.decode(String.self, forKey: .content)
        
        // Decode the timestamp as a Date
        let timestampString = try container.decode(String.self, forKey: .timestamp)
        guard let timestampDate = timestampString.getDate else {
            throw DecodingError.dataCorruptedError(forKey: .timestamp,
                                                   in: container,
                                                   debugDescription: "Date string does not conform to expected format.")
        }
        timestamp = timestampDate
        
        // Decode the array of EventModel objects
        events = try container.decodeIfPresent([EventModel].self, forKey: .events) ?? []
    }
    
    var event : EventModel? {
        return (!events.isEmpty) ? events[0] : nil
    }
    
    var location : LocationModel? {
        return event?.location
    }
    
    var eventTypes: [EventType] {
        Array(Set(events)).compactMap { $0.eventType } // or $0.name, depending on the property name
    }
}

