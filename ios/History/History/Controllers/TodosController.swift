//
//  TodoModel.swift
//  History
//
//  Created by Nathik Azad on 3/18/24.
//

import Foundation
class TodosController: ObservableObject {
    
    @Published var todos: [Todo] = []
    var subscriptionId: String?
    
    struct TodosResponseData: Decodable {
        var data: TodosWrapper
        struct TodosWrapper: Decodable {
            var todos: [Todo]
        }
    }
    
    
    
    
    func fetchTodos(userId: Int) async {
        let startOfToday = Calendar.current.startOfDay(for: Date())
        let graphqlQuery = TodosController.generateQuery(userId: userId)
        
        do {
            // Directly get the decoded ResponseData object from sendGraphQL
            let responseData: TodosResponseData = try await Hasura.shared.sendGraphQL(query: graphqlQuery, responseType: TodosResponseData.self)
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
    
    
    
    func listenToTodos(userId: Int) {
        print("lsitening for todos")
        let startOfToday = Calendar.current.startOfDay(for: Date())
        let subscriptionQuery = TodosController.generateQuery(userId: userId, isSubscription: true)
        
        subscriptionId = Hasura.shared.startListening(subscriptionQuery: subscriptionQuery, responseType: TodosResponseData.self) {result in
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
    
    static private func generateQuery(userId: Int, limit: Int? = 20, isSubscription: Bool = false) -> String {
        let limitClause = limit.map { ", limit: \($0)" } ?? ""
        let operationType = isSubscription ? "subscription" : "query"
        return """
        \(operationType) {
            todos(where: {user_id: {_eq: \(userId)}}\(limitClause)) {
                id
                name
                status
            }
        }
        """
    }
    
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
    
    var isDone: Bool {
        return status == "done"
    }
}
