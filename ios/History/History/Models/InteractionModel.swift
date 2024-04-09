//
//  InteractionModel.swift
//  History
//
//  Created by Nathik Azad on 3/18/24.
//

import Foundation
class InteractionModel: ObservableObject {
    
    @Published var interactions: [Interaction] = []
    var subscriptionId: String?
    
    struct ResponseData: Decodable {
        var data: InteractionsWrapper
    }
    
    struct InteractionsWrapper: Decodable {
        var interactions: [Interaction]
    }
    
    
    func fetchInteractions() async {
        let startOfToday = Calendar.current.startOfDay(for: Date())
        let graphqlQuery = Interaction.generateQuery(gte: startOfToday)
        
        do {
            // Directly get the decoded ResponseData object from sendGraphQL
            let responseData: ResponseData = try await Hasura.shared.sendGraphQL(query: graphqlQuery, responseType: ResponseData.self)
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
    
    
    
    func listenToInteractions() {
        let startOfToday = Calendar.current.startOfDay(for: Date())
        let subscriptionQuery = Interaction.generateQuery(gte: startOfToday, isSubscription: true)
        
        subscriptionId = Hasura.shared.startListening(subscriptionQuery: subscriptionQuery, responseType: ResponseData.self) {result in
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
    
    var interactionsGroupedByDate: [(date: String, interactions: [Interaction])] {
        // Group interactions by justDate
        let groups = Dictionary(grouping: interactions) { $0.justDate }
        
        // Convert Dictionary to sorted array of tuples
        let sortedGroups = groups.sorted { $0.key < $1.key }.map { (date: $0.key, interactions: $0.value) }
        return sortedGroups
    }
    
    
}

struct Interaction: Decodable, Equatable {
    var id: Int
    var content: String
    var timestamp: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case content
        case timestamp // if the key in your JSON is "timestamp" instead of "time"
    }
    
    static func generateQuery(limit: Int? = 20, gte: Date? = nil, isSubscription: Bool = false) -> String {
        let limitClause = limit.map { ", limit: \($0)" } ?? ""
        let gteClause: String
        if let gteDate = gte {
            let startOfTodayUTCString = HasuraUtil.dateToUTCString(date: gteDate)
            gteClause = ", where: {timestamp: {_gte: \"\(startOfTodayUTCString)\"}}"
        } else {
            gteClause = ""
        }
        
        let operationType = isSubscription ? "subscription" : "query"
        
        return """
        \(operationType) {
            interactions(order_by: {timestamp: asc}\(limitClause)\(gteClause)) {
                timestamp
                id
                content
            }
        }
        """
    }
    
    var justDate: String {
        return HasuraUtil.justDate(timestamp: timestamp)
    }
    
    var formattedTime: String {
        return HasuraUtil.formattedTime(timestamp: timestamp)
    }
}
