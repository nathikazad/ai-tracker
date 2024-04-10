//
//  GoalModel.swift
//  History
//
//  Created by Nathik Azad on 3/18/24.
//

import Foundation
class GoalsModel: ObservableObject {
    
    @Published var goals: [Goal] = []
    var subscriptionId: String?
    
    struct ResponseData: Decodable {
        var data: GoalsWrapper
    }
    
    struct GoalsWrapper: Decodable {
        var goals: [Goal]
    }
    
    
    func fetchGoals() async {
        let startOfToday = Calendar.current.startOfDay(for: Date())
        let graphqlQuery = Goal.generateQuery()
        
        do {
            // Directly get the decoded ResponseData object from sendGraphQL
            let responseData: ResponseData = try await Hasura.shared.sendGraphQL(query: graphqlQuery, responseType: ResponseData.self)
            DispatchQueue.main.async {
                self.goals = responseData.data.goals
            }
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    
    
    func deleteGoal(id: Int, onSuccess: (() -> Void)? = nil) {
        let mutationQuery = """
        mutation {
            delete_goals_by_pk(id: \(id)) {
              id
            }
        }
        """
        
        struct DeleteGoalResponse: Decodable {
            var delete_goals_by_pk: DeletedGoal
            struct DeletedGoal: Decodable {
                var id: Int
            }
        }
        Task {
            do {
                let response: DeleteGoalResponse = try await Hasura.shared.sendGraphQL(query: mutationQuery, responseType: DeleteGoalResponse.self)
                DispatchQueue.main.async {
                    print("Goal deleted: \(response.delete_goals_by_pk.id)")
                    onSuccess?()
                }
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    
    
    func listenToGoals() {
        let startOfToday = Calendar.current.startOfDay(for: Date())
        let subscriptionQuery = Goal.generateQuery(isSubscription: true)
        
        subscriptionId = Hasura.shared.startListening(subscriptionQuery: subscriptionQuery, responseType: ResponseData.self) {result in
            switch result {
            case .success(let responseData):
                DispatchQueue.main.async {
                    self.goals = responseData.data.goals
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
    
//    var goalsGroupedByDate: [(date: String, goals: [Goal])] {
//        // Group goals by justDate
//        let groups = Dictionary(grouping: goals) { $0.justDate }
//
//        // Convert Dictionary to sorted array of tuples
//        let sortedGroups = groups.sorted { $0.key < $1.key }.map { (date: $0.key, goals: $0.value) }
//        return sortedGroups
//    }
    
    
}

struct Goal: Decodable, Equatable {
    var id: Int
    var name: String
    var status: String
    var period: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case status
        case period
    }
    
    static func generateQuery(limit: Int? = 20, isSubscription: Bool = false) -> String {
        let limitClause = limit.map { " limit: \($0)" } ?? ""
        let gteClause: String
//        if let gteDate = gte {
//            let startOfTodayUTCString = HasuraUtil.dateToUTCString(date: gteDate)
//            gteClause = ", where: {timestamp: {_gte: \"\(startOfTodayUTCString)\"}}"
//        } else {
            gteClause = ""
//        }
        
        let operationType = isSubscription ? "subscription" : "query"
        
        return """
        \(operationType) {
            goals(\(limitClause)\(gteClause)) {
                id
                name
                status
                period
            }
        }
        """
    }
    
}
