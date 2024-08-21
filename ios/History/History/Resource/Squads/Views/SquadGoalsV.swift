//
//  SquadGraphV.swift
//  History
//
//  Created by Nathik Azad on 8/20/24.
//

import SwiftUI
struct SquadGoalsView: View {
    @ObservedObject var squad: SquadModel
    @State private var aggregates: [AggregateModel] = []
    @State private var actions: [ActionModel] = []
    @State private var loading = true
    @State var selectedMemberId: Int
    @State private var weekBoundary: WeekBoundary = Date().getWeekBoundary
    @State private var openDisclosures: Set<Int> = []
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
                        WeekNavigator
                            .alignmentGuide(.listRowSeparatorLeading) { _ in -20 }
                        GoalsGraphsView(
                            aggregates: $aggregates,
                            actions: $actions,
                            weekBoundary: $weekBoundary,
                            openDisclosures: $openDisclosures,
                            goalEditable: false
                            
                        )
                    }
                }
            }
        }

        .onAppear {
                loadData()
        }
    }
    
    var squadMember: GroupMemberModel? {
        return squad.members[selectedMemberId]
    }
    
    private func loadData() {
        Task {
            loading = true
            if let member = squadMember {
                Task {
                    let aggregates = await AggregateController.fetchAggregates(ids: member.aggregates)
                    let actionTypeIds: [Int] = aggregates.map { $0.actionTypeId }
                    let actions = await ActionController.fetchActions(userId: member.user.id, startDate: weekBoundary.start, endDate: weekBoundary.end, actionTypeIds: actionTypeIds)
                    DispatchQueue.main.async {
                        self.aggregates = aggregates
                        self.actions = actions
                        loading = false
                    }
                }
            }
        }
    }
    
    var WeekNavigator: some View {
            HStack {
                Spacer()
                Button(action: {
                    weekBoundary = weekBoundary.previousWeek()
                    loadData()
                }) {
                    Image(systemName: "chevron.left.circle.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                }
                .buttonStyle(PlainButtonStyle())
                
                HStack {
                    Text(weekBoundary.formatString)
                        .font(.headline)
                }.frame(minWidth: 130)
                
                Button(action: {
                    weekBoundary = weekBoundary.nextWeek()
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
