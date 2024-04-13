//
//  TodosView.swift
//  History
//
//  Created by Nathik Azad on 4/8/24.
//

import SwiftUI

struct TodosView: View {
    @StateObject var todoController = TodosController()
    
    init() {
        
    }
    var body: some View {
        Group {
            if todoController.todos.isEmpty {
                // Fullscreen message for no todos
                VStack {
                    Spacer()
                    Text("No Todos Yet")
                        .foregroundColor(.black)
                        .font(.title2)
                    Text("Create a todo by defining a goal or a task by clicking the microphone below")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center) // This will center-align the text horizontally
                        .padding(.horizontal, 20)
                    Spacer()
                }
            } else {
                List {
                    ForEach(todoController.todos, id: \.id) { todo in
                        Button(action: {
                            // Example toggle action
                        }) {
                            HStack {
                                Image(systemName: todo.isDone ? "checkmark.square.fill" : "square")
                                    .foregroundColor(todo.isDone ? .blue : .gray)
                                Text(todo.name)
                                if let timesPerDay = todo.goal?.frequency.timesPerDay {
                                    if(timesPerDay > 1) {
                                        Text("\(todo.currentCount ?? 0)/\(timesPerDay)")
                                    }
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.all, 0)
            }
        }
        .padding(.all, 0)
        .onAppear {
            print("TodosView has appeared")
            if(Authentication.shared.areJwtSet) {
                Task {
                    await todoController.fetchTodos(userId: Authentication.shared.userId!)
                    todoController.listenToTodos(userId: Authentication.shared.userId!)
                }
            }
        }
        .onDisappear {
            todoController.cancelListener()
            print("TodosView has disappeared")
        }
    }
}


#Preview {
    TodosView()
}
