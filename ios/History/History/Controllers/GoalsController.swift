//
//  GoalModel.swift
//  History
//
//  Created by Nathik Azad on 3/18/24.
//

import Foundation
class GoalsController: ObservableObject {
    
    @Published var goals: [GoalModel] = []
    var subscriptionId: String?
    
    struct GoalsResponseData: Decodable {
        var data: GoalsWrapper
        struct GoalsWrapper: Decodable {
            var goals: [GoalModel]
        }
    }
    
    
    func fetchGoals(userId: Int) async {
        let startOfToday = Calendar.current.startOfDay(for: Date())
        let graphqlQuery = GoalsController.generateQuery(userId: userId)
        
        do {
            // Directly get the decoded ResponseData object from sendGraphQL
            let responseData: GoalsResponseData = try await Hasura.shared.sendGraphQL(query: graphqlQuery, responseType: GoalsResponseData.self)
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
    
    
    
    func listenToGoals(userId: Int) {
        let startOfToday = Calendar.current.startOfDay(for: Date())
        let subscriptionQuery = GoalsController.generateQuery(userId: userId, isSubscription: true)
        
        subscriptionId = Hasura.shared.startListening(subscriptionQuery: subscriptionQuery, responseType: GoalsResponseData.self) {result in
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
    
    static private func generateQuery(userId: Int, limit: Int? = 20, isSubscription: Bool = false) -> String {
        let limitClause = limit.map { ", limit: \($0)" } ?? ""
        let operationType = isSubscription ? "subscription" : "query"
        
        return """
        \(operationType) {
            goals(where: {user_id: {_eq: \(userId)}}\(limitClause)) {
                id
                name
                status
                frequency
                nl_description
            }
        }
        """
    }
    
}

struct Frequency: Codable, Equatable {
    var type: String // "weekly" or "periodic"
    var daysOfWeek: [String]? // Optional: ["monday", "tuesday", ..., "weekends"]
    var timesPerDay: Int
    var preferredHours: [String]? // Optional
    var duration: String? // Optional
    var period: Int? // Optional
}

// Updated GoalModel struct in Swift
struct GoalModel: Codable, Equatable {
    var id: Int
    var name: String
    var frequency: Frequency
    var nlDescription: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case frequency
        case nlDescription = "nl_description"
    }
}
