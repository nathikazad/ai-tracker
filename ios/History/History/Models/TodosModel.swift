//
//  TodoModel.swift
//  History
//
//  Created by Nathik Azad on 3/18/24.
//

import Foundation
class TodosModel: ObservableObject {
    
    @Published var todos: [Todo] = []
    var subscriptionId: String?
    
    struct ResponseData: Decodable {
        var data: TodosWrapper
    }
    
    struct TodosWrapper: Decodable {
        var todos: [Todo]
    }
    
    
    func fetchTodos() async {
        let startOfToday = Calendar.current.startOfDay(for: Date())
        let graphqlQuery = Todo.generateQuery()
        
        do {
            // Directly get the decoded ResponseData object from sendGraphQL
            let responseData: ResponseData = try await Hasura.shared.sendGraphQL(query: graphqlQuery, responseType: ResponseData.self)
            DispatchQueue.main.async {
                self.todos = responseData.data.todos
            }
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    
    
    func deleteTodo(id: Int, onSuccess: (() -> Void)? = nil) {
        let mutationQuery = """
        mutation {
            delete_todos_by_pk(id: \(id)) {
              id
            }
        }
        """
        
        struct DeleteTodoResponse: Decodable {
            var delete_todos_by_pk: DeletedTodo
            struct DeletedTodo: Decodable {
                var id: Int
            }
        }
        Task {
            do {
                let response: DeleteTodoResponse = try await Hasura.shared.sendGraphQL(query: mutationQuery, responseType: DeleteTodoResponse.self)
                DispatchQueue.main.async {
                    print("Todo deleted: \(response.delete_todos_by_pk.id)")
                    onSuccess?()
                }
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    
    
    func listenToTodos() {
        let startOfToday = Calendar.current.startOfDay(for: Date())
        let subscriptionQuery = Todo.generateQuery(isSubscription: true)
        
        subscriptionId = Hasura.shared.startListening(subscriptionQuery: subscriptionQuery, responseType: ResponseData.self) {result in
            switch result {
            case .success(let responseData):
                DispatchQueue.main.async {
                    self.todos = responseData.data.todos
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
    
//    var todosGroupedByDate: [(date: String, todos: [Todo])] {
//        // Group todos by justDate
//        let groups = Dictionary(grouping: todos) { $0.justDate }
//        
//        // Convert Dictionary to sorted array of tuples
//        let sortedGroups = groups.sorted { $0.key < $1.key }.map { (date: $0.key, todos: $0.value) }
//        return sortedGroups
//    }
    
    
}

struct Todo: Decodable, Equatable {
    var id: Int
    var name: String
    var status: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case status
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
            todos(\(limitClause)\(gteClause)) {
                id
                name
                status
            }
        }
        """
    }
    
    var isDone: Bool {
        return status == "done"
    }
    
//    var justDate: String {
//        return HasuraUtil.justDate(timestamp: timestamp)
//    }
//    
//    var formattedTime: String {
//        return HasuraUtil.formattedTime(timestamp: timestamp)
//    }
}
