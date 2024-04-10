//
//  TodosView.swift
//  History
//
//  Created by Nathik Azad on 4/8/24.
//

import SwiftUI

struct TodosView: View {
    @StateObject var todoModel = TodosModel()

    var body: some View {
        List {
            ForEach(todoModel.todos, id: \.id) { todo in
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
                await todoModel.fetchTodos()
                todoModel.listenToTodos()
            }
        }
        .onDisappear {
            todoModel.cancelListener()
            print("TodosView has disappeared")
        }
    }
}


#Preview {
    TodosView()
}
