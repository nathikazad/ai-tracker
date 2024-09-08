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
    @State private var selectedUser = 0
    @State private var selectedPriority: GoalPriority = .high
    @State private var selectedAggregateId: Int? = nil
    @State private var coreStateSubcription: AnyCancellable?
    
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
                            selectedAggregateId: $selectedAggregateId,
                            loadActions: loadActions
                        )
                    }
                }
            }
        }

        .onAppear {
            if state.timePickerToShow == .day {
                state.setTimePicker(.week)
            }
            if(auth.areJwtSet) {
                loadData()
                coreStateSubcription?.cancel()
                coreStateSubcription = state.subscribeToCoreStateChanges {
                    print("AggregatesTab Core state occurred")
                    loadData()
                }
            }
        }
        .onDisappear {
            coreStateSubcription?.cancel()
        }
    }
    
    private func loadData() {
        Task {
            loading = true
            let aggregates = await AggregateController.fetchAggregates(userId: auth.userId!, withActionTypes: true)
            if selectedAggregateId == nil {
                selectedAggregateId = aggregates.first?.id
            }
            await MainActor.run {
                self.aggregates = aggregates
                self.loading = false
            }
            loadActions()
        }
    }
    
    private func loadActions() {
        Task {
            if let actionTypeId = aggregates.first(where: { $0.id == selectedAggregateId })?.actionTypeId  {
                print("Action Type Id \(actionTypeId)")
                let actions = await ActionController.fetchActions(userId: auth.userId!, actionTypeId: actionTypeId, startDate: state.bounds.start, endDate: state.bounds.end)
                print("actions \(actions.count)")
                await MainActor.run {
                    self.actions = actions
                }
            }
        }
    }
}

struct GoalsGraphsView: View {
    @Binding var aggregates: [AggregateModel]
    @Binding var actions: [ActionModel]
    @Binding var selectedAggregateId: Int?
    var goalEditable: Bool = true
    var loadActions: (() -> Void)

    var body: some View {
        ForEach(aggregates, id: \.id) { aggregate in
            DisclosureGroup(
                isExpanded: Binding(
                    get: { selectedAggregateId == aggregate.id },
                    set: { isExpanded in
                        if isExpanded {
                            selectedAggregateId = aggregate.id
                            loadActions()
                        } else {
                            selectedAggregateId = nil
                        }
                    }
                )
            ) {
                AggregateChartView(
                    aggregate: aggregate,
                    actionsParam: actions,
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
