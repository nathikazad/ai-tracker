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
    @State private var selectedOption = 0
    let options = ["You", "Nathik"]
    init() {
        let endDate = Date()
        self.endDate = endDate
        self.startDate = Calendar.current.date(byAdding: .day, value: -7, to: endDate) ?? Date()
    }
    
    var body: some View {
        List {
            HStack {
                Picker("", selection: $selectedOption) {
                    Text("You")
                        .foregroundColor(.black)
                        .tag(0)
                    Text("Nathik")
                        .foregroundColor(.black)
                        .tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: selectedOption) { _, newValue in
                    print(newValue)
                    loadData(userId: newValue == 1 ? newValue : auth.userId!)
                    loading = true
                }
            }
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
                    graphs
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
            print(aggregates.count)
            loading = false
        }
    }
    
    private var graphs: some View {
        Group {
            let groupedAggregates = Dictionary(grouping: aggregates) { aggregate in
                aggregate.actionType?.name ?? "Unknown"
            }
            
            ForEach(groupedAggregates.keys.sorted(), id: \.self) { actionTypeName in
                Section(header: Text(actionTypeName)) {
                    ForEach(groupedAggregates[actionTypeName] ?? [], id: \.id) { aggregate in
                        DisclosureGroup {
                            AggregateChartView(
                                aggregate: aggregate,
                                actionsParam: actions,
                                startDate: startDate,
                                endDate: endDate
                            )
                        } label: {
                            Text(aggregate.toString)
                        }
                    }
                }
            }
        }
    }
}


