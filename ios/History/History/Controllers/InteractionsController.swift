//
//  InteractionModel.swift
//  History
//
//  Created by Nathik Azad on 3/18/24.
//

import Foundation
class InteractionsController: ObservableObject {
    
    @Published var interactions: [InteractionModel] = []
    @Published var currentDate = Calendar.current.startOfDay(for: Date())
    let subscriptionId: String = "interactions"
    

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE MMMM dd" // Custom format for day, month, and date
        return formatter.string(from: currentDate)
    }

    func goToNextDay() {
        print("next day")
        currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
        fetchInteractions(userId: Authentication.shared.userId!)
        listenToInteractions(userId: Authentication.shared.userId!)
    }

    func goToPreviousDay() {
        print("previous day")
        currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate)!
        fetchInteractions(userId: Authentication.shared.userId!)
        listenToInteractions(userId: Authentication.shared.userId!)
    }
    
    struct InteractionsResponseData: Decodable {
        var data: InteractionsWrapper
        struct InteractionsWrapper: Decodable {
            var interactions: [InteractionModel]
        }
    }
    
    func fetchInteractions(userId: Int) {
        Task {
            let graphqlQuery = InteractionsController.generateQuery(userId: userId, gte: currentDate)
            do {
                // Directly get the decoded ResponseData object from sendGraphQL
                let responseData: InteractionsResponseData = try await Hasura.shared.sendGraphQL(query: graphqlQuery, responseType: InteractionsResponseData.self)
                DispatchQueue.main.async {
                    self.interactions = responseData.data.interactions
                }
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func editInteraction(id: Int, content: String, onSuccess: (() -> Void)? = nil) {
        print("editing interaction")
        let mutationQuery = """
        mutation MyMutation($id: Int!, $content: String!) {
          update_interactions_by_pk(pk_columns: {id: $id}, _set: {content: $content}) {
            id
          }
        }
        """
        let variables: [String: Any] = ["id": id, "content": content]

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
            let response: EditInteractionResponse = try await Hasura.shared.sendGraphQL(query: mutationQuery, variables: variables, responseType: EditInteractionResponse.self)
            DispatchQueue.main.async {
                print("Interaction edited: \(response.data.update_interactions_by_pk.id)")
                onSuccess?()
            }
        }
    }
    
    func deleteInteraction(id: Int, onSuccess: (() -> Void)? = nil) {
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
    
    
    
    func listenToInteractions(userId: Int) {
        cancelListener()
        // print("listening for interactions")
        let subscriptionQuery = InteractionsController.generateQuery(userId: userId, gte: currentDate, isSubscription: true)
        
        Hasura.shared.startListening(subscriptionId: subscriptionId, subscriptionQuery: subscriptionQuery, responseType: InteractionsResponseData.self) {result in
            switch result {
            case .success(let responseData):
                DispatchQueue.main.async {
                    self.interactions = responseData.data.interactions
                }
            case .failure(let error):
                print("Error processing message: \(error.localizedDescription)")
            }
        }
    }
    
    
    func cancelListener() {
        Hasura.shared.stopListening(uniqueID: subscriptionId)
    }
    
    static private func generateQuery(userId: Int,gte: Date? = nil, isSubscription: Bool = false) -> String {
        let limitClause = ""
        var whereClauses: [String] = ["{user_id: {_eq: \(userId)}", "content_type: {_eq: \"event\"}}"]

        if let gteDate = gte {
            let startOfTodayUTCString = HasuraUtil.dateToUTCString(date: gteDate)
            let calendar = Calendar.current
            let dayAfterGteDate = calendar.date(byAdding: .day, value: +1, to: gteDate)!
            let dayAfterUTCString = HasuraUtil.dateToUTCString(date: dayAfterGteDate)

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
            }
        }
        """
    }
}

struct InteractionModel: Decodable, Equatable, Identifiable {
    var id: Int
    var content: String
    var timestamp: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case content
        case timestamp // if the key in your JSON is "timestamp" instead of "time"
    }
    
    var justDate: String {
        return HasuraUtil.justDate(timestamp: timestamp)
    }
    
    var formattedTime: String {
        return HasuraUtil.formattedTime(timestamp: timestamp)
    }
}
