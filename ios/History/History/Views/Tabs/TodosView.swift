//
//  TodosView.swift
//  History
//
//  Created by Nathik Azad on 4/8/24.
//

import SwiftUI

struct TodosView: View {
        @State private var tasks = [
            ("Morning meeting", false),
            ("Check emails", false),
            ("Go running", false),
            ("Discuss marketing", false)
        ]
        
        var body: some View {
            NavigationView {
                List {
                    ForEach($tasks, id: \.0) { $task in
                        HStack {
                            Button(action: {
                                task.1.toggle()
                            }) {
                                HStack {
                                    Image(systemName: task.1 ? "checkmark.square.fill" : "square")
                                        .foregroundColor(task.1 ? .blue : .gray)
                                    Text(task.0)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .navigationTitle("Todos")
            }
            
        }
    }

#Preview {
    TodosView()
}
