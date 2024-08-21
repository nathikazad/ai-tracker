//
//  GoalsListV.swift
//  History
//
//  Created by Nathik Azad on 8/20/24.
//

import SwiftUI
struct GoalListView: View {
    @State private var goals: [AggregateModel] = []
    @State private var searchText = ""
    var selectionAction: ((AggregateModel) -> Void)?
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        List {
            TextField("Search Goals...", text: $searchText)
                .padding(7)
                .cornerRadius(8)
                .padding(2)
                .alignmentGuide(.listRowSeparatorLeading) { _ in
                    -20
                }
            
            
            NavigationButton(destination: ListActionsTypesView(
                listActionType: .takeToAggregateCreateView
            )) {
                Label("Create New Goal", systemImage: "plus.circle")
            }
            .alignmentGuide(.listRowSeparatorLeading) { _ in
                -20
            }
            
            ForEach(filteredGoals, id: \.id) { goal in
                Button(action: {
                    selectionAction?(goal)
                    goBack()
                }) {
                    Text(goal.metadata.name)
                }
                .alignmentGuide(.listRowSeparatorLeading) { _ in
                    -20
                }
            }
        }
        .navigationBarTitle(Text("Select Goal"), displayMode: .inline)
        .onAppear(perform: fetchGoals)
    }
    
    private func fetchGoals() {
        Task {
            let fetchedTypes = await AggregateController.fetchAggregates(userId: auth.userId!)
            DispatchQueue.main.async {
                goals = fetchedTypes
                print("goals \(goals.count)")
            }
        }
    }
    
    private var filteredGoals: [AggregateModel] {
        if searchText.isEmpty {
            return goals.sorted { $0.metadata.name < $1.metadata.name }
        } else {
            return goals.filter { $0.metadata.name.lowercased().contains(searchText.lowercased()) }
                .sorted { $0.metadata.name < $1.metadata.name }
        }
    }
    
    private func goBack() {
        presentationMode.wrappedValue.dismiss()
    }
}
