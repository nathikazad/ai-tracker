//
//  File.swift
//  History
//
//  Created by Nathik Azad on 4/8/24.
//

import SwiftUI
import Combine

struct AggregatesTabView: View {
    @State private var aggregates: [AggregateModel] = []
    @State private var actions: [ActionModel] = []
    @State private var loading = true
    @State private var endDate: Date
    @State private var startDate: Date
    @State private var selectedUser = 0
    @State private var selectedPriority: GoalPriority = .high
    @State private var openDisclosures: Set<Int> = []
    let options = ["You", "Nathik"]
    init() {
        let endDate = Date()
        self.endDate = endDate
        self.startDate = Calendar.current.date(byAdding: .day, value: -7, to: endDate) ?? Date()
    }
    
    var filteredAggregates: [AggregateModel] {
        aggregates.filter( {$0.metadata.goals.contains(where: {$0.priority == selectedPriority} ) } )
    }
    
    var body: some View {
        VStack {
            if loading == true {
                Text("Loading...")
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center) // This will center-align the text horizontally
                    .padding(.horizontal, 20)
            } else {
                if aggregates.isEmpty {
                    VStack {
                        Spacer()
                        Text("No Aggregates Yet")
                            .foregroundColor(.primary)
                            .font(.title2)
                        Text("Create an event by clicking the microphone below")
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center) // This will center-align the text horizontally
                            .padding(.horizontal, 20)
                        Spacer()
                    }
                } else {
                    //                    if (selectedGraphs == .goals) {
                    List {
                        HStack (spacing: 20) {
                            Picker("Priority: ", selection: $selectedPriority) {
                                Text("High")
                                    .tag(GoalPriority.high)
                                Text("Low")
                                    .tag(GoalPriority.low)
                            }
                            
                            .clipped()
                            .contentShape(Rectangle())
                            .onChange(of: selectedPriority) { _, newValue in
                                print(newValue)
                                
                            }
                        }
                        graphs
                    }
                }
            }
        }
        .onAppear {
            print("EventsView: onAppear")
            if(auth.areJwtSet) {
                loadData(userId: auth.userId!)
            }
        }
    }
    
    private func loadData(userId: Int) {
        Task {
            print(userId)
            aggregates = await AggregateController.fetchAggregates(userId: userId, withAggregates: true)
            actions = await ActionController.fetchActions(userId: userId)
            openDisclosures = Set(aggregates.prefix(2).map { $0.id! })
            loading = false
        }
    }
    
    private var graphs: some View {
        Group {
            ForEach(filteredAggregates, id: \.id) { aggregate in
                DisclosureGroup (
                    isExpanded: Binding(
                        get: { openDisclosures.contains(aggregate.id!) },
                        set: { isExpanded in
                            if isExpanded {
                                openDisclosures.insert(aggregate.id!)
                            } else {
                                openDisclosures.remove(aggregate.id!)
                            }
                        }
                    )
                ) {
                    
                    AggregateChartView(
                        aggregate: aggregate,
                        actionsParam: actions,
                        startDate: startDate,
                        endDate: endDate
                    )
                } label: {
                    Text(aggregate.metadata.name == "" ? aggregate.toString : aggregate.metadata.name)
                    
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    NavigationLink(destination: ShowAggregateView(aggregateModel: aggregate))
                    {
                        Image(systemName: "gear")
                    }
                    .tint(.gray)
                }
            }
        }
    }
}


