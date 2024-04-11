//
//  TodosView.swift
//  History
//
//  Created by Nathik Azad on 4/8/24.
//

import SwiftUI

struct TodosView: View {
    @StateObject var todoController = TodosController()
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
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
        .onAppear {
            Task {
                if(Authentication.shared.areJwtSet) {
                    await todoController.fetchTodos()
                    todoController.listenToTodos()
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
