//
//  File.swift
//  History
//
//  Created by Nathik Azad on 4/8/24.
//

import SwiftUI
import Combine

struct GoalsTabView: View {
    @State private var aggregates: [AggregateModel] = []
    @State private var actions: [ActionModel] = []
    @State private var loading = true
    @State private var weekBoundary: WeekBoundary
    @State private var selectedUser = 0
    @State private var selectedPriority: GoalPriority = .high
    @State private var openDisclosures: Set<Int> = []
    @State private var coreStateSubcription: AnyCancellable?
    init() {
        weekBoundary = state.currentWeek
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
                        Text("No Goals Yet")
                            .foregroundColor(.primary)
                            .font(.title2)
                        
                        NavigationLink(destination: ListActionsTypesView(listActionType: .takeToAggregateCreateView)) {
                            Label("Add Goal", systemImage: "plus")
                        }
                        .padding(.top, 10)
                        Spacer()
                    }
                } else {
                    List {
                        NavigationLink(destination: ListActionsTypesView(listActionType: .takeToAggregateCreateView)) {
                            Label("Add New Goal", systemImage: "plus")
                        }
                        .alignmentGuide(.listRowSeparatorLeading) { _ in
                            -20
                        }
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
                        .alignmentGuide(.listRowSeparatorLeading) { _ in
                            -20
                        }
                        GoalsGraphsView(
                            aggregates: Binding(
                                get: { self.filteredAggregates },
                                set: { _ in }
                            ),
                            actions: $actions,
                            openDisclosures: $openDisclosures
                        )
                    }
                }
            }
        }

        .onAppear {
            if(auth.areJwtSet) {
                loadData(userId: auth.userId!)
                coreStateSubcription?.cancel()
                coreStateSubcription = state.subscribeToCoreStateChanges {
                    print("AggregatesTab Core state occurred")
                    weekBoundary = state.currentWeek
                    loadData(userId: auth.userId!)
                }
            }
        }
        .onDisappear {
            coreStateSubcription?.cancel()
        }
    }
    
    private func loadData(userId: Int) {
        Task {
            loading = true
            let aggregates = await AggregateController.fetchAggregates(userId: userId, withActionTypes: true)
            let actions = await ActionController.fetchActions(userId: userId, startDate: state.currentWeek.start, endDate: state.currentWeek.end)
            await MainActor.run {
                self.aggregates = aggregates
                self.actions = actions
                loading = false
            }
        }
    }
}

struct GoalsGraphsView: View {
    @Binding var aggregates: [AggregateModel]
    @Binding var actions: [ActionModel]
    @Binding var openDisclosures: Set<Int>
    var goalEditable: Bool = true

    var body: some View {
        ForEach(aggregates, id: \.id) { aggregate in
            DisclosureGroup(
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
                    weekBoundary: state.currentWeek,
                    showWeekNavigator: false,
                    actionTypeModel: aggregate.actionType ?? ActionTypeModel(name: "Unknown")
                )
            } label: {
                Text(aggregate.metadata.name == "" ? aggregate.toString : aggregate.metadata.name)
            }
            .alignmentGuide(.listRowSeparatorLeading) { _ in
                -20
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                if goalEditable {
                    NavigationLink(destination: ShowGoalView(aggregateModel: aggregate)) {
                        Image(systemName: "gear")
                    }
                    .tint(.gray)
                }
            }
        }
    }
}
