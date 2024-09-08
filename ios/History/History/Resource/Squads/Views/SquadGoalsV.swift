//
//  SquadGraphV.swift
//  History
//
//  Created by Nathik Azad on 8/20/24.
//
import Combine
import SwiftUI
struct SquadGoalsView: View {
    @ObservedObject var squad: SquadModel
    @State private var aggregates: [AggregateModel] = []
    @State private var actions: [ActionModel] = []
    @State private var loading = true
    @State var selectedMemberId: Int
    @State private var selectedAggregateId: Int? = nil
    @State private var openDisclosures: Set<Int> = []
    @State private var coreStateSubcription: AnyCancellable?
    
    var filteredAggregates: [AggregateModel] {
        aggregates
    }
    
    var body: some View {
        VStack {
            if loading == true {
                Text("Loading...")
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center) // This will center-align the text horizontally
                    .padding(.horizontal, 20)
            } else {

                List {
                    HStack (spacing: 20) {
                        Picker("", selection: $selectedMemberId) {
                            ForEach(Array(squad.members.values), id: \.id) { member in
                                Text(member.user.name).tag(member.id as Int?)
                            }
                        }
                        .clipped()
                        .contentShape(Rectangle())
                        .onChange(of: selectedMemberId) {
                            loadData()
                            
                        }
                    }
                    .alignmentGuide(.listRowSeparatorLeading) { _ in -20 }
                    if aggregates.isEmpty {
                        Text("\(squadMember?.user.name ?? "User") has not added any goals yet.")
                            .padding(.vertical, 10)
                            
                    } else {
                        HStack {
                            switchPeriodButton
                            Spacer()
                            TimeNavigator()
                            Spacer()
                        }
                            .alignmentGuide(.listRowSeparatorLeading) { _ in -20 }
                        NavigationLink(destination: CandleChartWithList(
                            fetchActionsCallback: {
                                return actions
                            })) {
                            Text("Timeline")
                        }
                        .alignmentGuide(.listRowSeparatorLeading) { _ in -20 }
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
                    loadData()
                }
            }
        }
        .onDisappear {
            coreStateSubcription?.cancel()
        }
    }
    
    var squadMember: GroupMemberModel? {
        return squad.members[selectedMemberId]
    }
    
//    private func loadData() {
//        Task {
//            loading = true
//            if let member = squadMember {
//                Task {
//                    let aggregates = await AggregateController.fetchAggregates(ids: member.aggregates)
//                    let actionTypeIds: [Int] = aggregates.map { $0.actionTypeId }
//                    let actions = await ActionController.fetchActions(userId: member.user.id, startDate: state.bounds.start, endDate: state.bounds.end, actionTypeIds: actionTypeIds)
//                    DispatchQueue.main.async {
//                        self.aggregates = aggregates
//                        self.actions = actions
//                        loading = false
//                    }
//                }
//            }
//        }
//    }
    
    private func loadData() {
        Task {
            loading = true
            let aggregates = await AggregateController.fetchAggregates(userId: squadMember!.user.id, withActionTypes: true)
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
                let actions = await ActionController.fetchActions(userId: squadMember!.user.id, actionTypeId: actionTypeId, startDate: state.bounds.start, endDate: state.bounds.end)
                print("actions \(actions.count)")
                await MainActor.run {
                    self.actions = actions
                }
            }
        }
    }
    
    
    
    var WeekNavigator: some View {
            HStack {
                Spacer()
                Button(action: {
                    state.goToPreviousWeek()
                    loadData()
                }) {
                    Image(systemName: "chevron.left.circle.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                }
                .buttonStyle(PlainButtonStyle())
                
                HStack {
                    Text(state.currentWeek.formatString)
                        .font(.headline)
                }.frame(minWidth: 130)
                
                Button(action: {
                    state.goToNextWeek()
                    loadData()
                }) {
                    Image(systemName: "chevron.right.circle.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                }
                .buttonStyle(PlainButtonStyle())
                Spacer()
            }
            .padding()
    }
}
