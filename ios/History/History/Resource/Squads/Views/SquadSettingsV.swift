//
//  SquadSettingsV.swift
//  History
//
//  Created by Nathik Azad on 8/20/24.
//

import SwiftUI
struct SettingsTab: View {
    @ObservedObject var squad: SquadModel
    @State var aggregates: [AggregateModel] = []
    var body: some View {
        Form {
            Section ("Goals Shared") {
                ForEach(aggregates, id: \.id) { aggregate in
                    NavigationLink(destination: ShowGoalView(aggregateModel: aggregate)) {
                        Text(aggregate.metadata.name)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(action: {
                            print("Deleting \(aggregate.id)")
                            Task {
                                if let memberId = squad.memberIdOfUser(auth.userId!) {
                                    squad.members[memberId]?.removeFromAggregates(aggregate.id!)
                                    await SquadMembersController.updateMember(id: memberId, metadata: squad.members[memberId]!.metadata!)
                                    fetch()
                                }
                            }
                        }) {
                            Image(systemName: "trash.fill")
                        }
                        .tint(.red)
                    }
                }
                NavigationLink(destination: GoalListView(selectionAction: {
                    aggregate in
                    addGoal(goalId: aggregate.id!)
                })) {
                    Label("Add Goal To Share", systemImage: "plus")
                }
                .alignmentGuide(.listRowSeparatorLeading) { _ in -20 }
            }
        }
        .onAppear {
            fetch()
        }
    }
    
    func fetch() {
        if let memberId = squad.memberIdOfUser(auth.userId!), let aggregates = squad.members[memberId]?.aggregates {
            Task {
                let aggregates = await AggregateController.fetchAggregates(ids: aggregates)
                DispatchQueue.main.async {
                    self.aggregates = aggregates
                }
            }
        }
    }
    
    func addGoal(goalId: Int) {
        if let memberId = squad.memberIdOfUser(auth.userId!) {
            squad.members[memberId]?.addToAggregates(goalId)
            Task {
                await SquadMembersController.updateMember(id: memberId, metadata: squad.members[memberId]!.metadata!)
                fetch()
            }
        }
    }
}
