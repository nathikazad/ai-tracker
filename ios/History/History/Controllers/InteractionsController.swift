//
//  InteractionModel.swift
//  History
//
//  Created by Nathik Azad on 3/18/24.
//

import Foundation
class InteractionsController: ObservableObject {
    
    @Published var interactions: [InteractionModel] = []
    var subscriptionId: String?
    
    struct InteractionsResponseData: Decodable {
        var data: InteractionsWrapper
        struct InteractionsWrapper: Decodable {
            var interactions: [InteractionModel]
        }
    }
    
    
    
    
    func fetchInteractions(userId: Int) async {
        let startOfToday = Calendar.current.startOfDay(for: Date())
        let graphqlQuery = InteractionsController.generateQuery(userId: userId, gte: startOfToday)
        
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
    
    
    
    func deleteInteraction(id: Int, onSuccess: (() -> Void)? = nil) {
        let mutationQuery = """
        mutation {
            delete_interactions_by_pk(id: \(id)) {
              id
            }
        }
        """
        
        struct DeleteInteractionResponse: Decodable {
            var delete_interactions_by_pk: DeletedInteraction
            struct DeletedInteraction: Decodable {
                var id: Int
            }
        }
        Task {
            
            let response: DeleteInteractionResponse = try await Hasura.shared.sendGraphQL(query: mutationQuery, responseType: DeleteInteractionResponse.self)
            DispatchQueue.main.async {
                print("Interaction deleted: \(response.delete_interactions_by_pk.id)")
                onSuccess?()
            }
            
        }
    }
    
    
    
    func listenToInteractions(userId: Int) {
        print("lsitening for interactions")
        let startOfToday = Calendar.current.startOfDay(for: Date())
        let subscriptionQuery = InteractionsController.generateQuery(userId: userId, gte: startOfToday, isSubscription: true)
        
        subscriptionId = Hasura.shared.startListening(subscriptionQuery: subscriptionQuery, responseType: InteractionsResponseData.self) {result in
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
        if(subscriptionId != nil) {
            Hasura.shared.stopListening(uniqueID: subscriptionId!)
            subscriptionId = nil
        }
    }
    
    static private func generateQuery(userId: Int, limit: Int? = 20, gte: Date? = nil, isSubscription: Bool = false) -> String {
        let limitClause = limit.map { ", limit: \($0)" } ?? ""
        var whereClauses: [String] = ["user_id: {_eq: \(userId)}", "content_type: {_eq: \"event\"}"]
        
        if let gteDate = gte {
            let startOfTodayUTCString = HasuraUtil.dateToUTCString(date: gteDate)
            whereClauses.append("timestamp: {_gte: \"\(startOfTodayUTCString)\"}")
        }
        
        let whereClause = whereClauses.isEmpty ? "" : "where: {\(whereClauses.joined(separator: ", "))}"
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

struct InteractionModel: Decodable, Equatable {
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
