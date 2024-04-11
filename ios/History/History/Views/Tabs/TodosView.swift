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
        .onAppear {
            Task {
                await todoController.fetchTodos()
                todoController.listenToTodos()
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
