//
//  ViewAggregate.swift
//  History
//
//  Created by Nathik Azad on 8/1/24.
//

import Foundation
import SwiftUI

struct ShowAggregateView: View {
    @StateObject private var aggregate: AggregateModel
    @State private var changesToSave: Bool = false
    @Environment(\.presentationMode) var presentationMode
    
    init(aggregateModel: AggregateModel) {
        _aggregate = StateObject(wrappedValue: aggregateModel)
    }
    
    var body: some View {
        Form {
            Section {
                Picker("Aggregator Type", selection: $aggregate.metadata.aggregatorType)
                {
                    ForEach(AggregatorType.allCases, id: \.self) { type in
                        Text(type.rawValue.capitalized).tag(type)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .onChange(of: aggregate.metadata.aggregatorType) {
                    changesToSave = true
                }
                
                
                if (aggregate.metadata.aggregatorType != .count) {
                    Picker("Field", selection: $aggregate.metadata.field) {
                        if (aggregate.metadata.aggregatorType == .compare) {
                            Text("Start Time").tag("Start Time")
                            Text("End Time").tag("End Time")
                        }
                        if (aggregate.metadata.aggregatorType == .sum) {
                            Text("Duration").tag("Duration")
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .onChange(of: aggregate.metadata.aggregatorType) {
                        changesToSave = true
                    }
                }
                
                
                Picker("Window", selection: $aggregate.metadata.window) {
                    ForEach(ASWindow.allCases, id: \.self) { window in
                        Text(window.rawValue.capitalized).tag(window)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .onChange(of: aggregate.metadata.aggregatorType) {
                    changesToSave = true
                }
            }
                
                
            Section ("Conditions") {
                List {
                    ForEach(aggregate.metadata.conditions.indices, id: \.self) { index in
                        ConditionView(condition: Binding(
                            get: { aggregate.metadata.conditions[index] },
                            set: { newValue in
                                aggregate.metadata.conditions[index] = newValue
                                aggregate.objectWillChange.send()
                                changesToSave = true
                            }
                        ))
                    }
                    .onDelete { indices in
                        aggregate.metadata.conditions.remove(atOffsets: indices)
                        changesToSave = true
                    }
                }
                .navigationTitle("Track")
            }

                
//                if !aggregate.metadata.goals.isEmpty {
//                    NavigationLink("Goals (\(aggregate.metadata.goals.count))") {
//                        List {
//                            ForEach(aggregate.metadata.goals.indices, id: \.self) { index in
//                                GoalView(goal: $aggregate.metadata.goals[index])
//                            }
//                            .onDelete { indices in
//                                aggregate.metadata.goals.remove(atOffsets: indices)
//                                changesToSave = true
//                            }
//                        }
//                        .navigationTitle("Goals")
//                    }
//                }
//            }
            
            Section {
                HStack {
                    Spacer()
                    Button("Save") {
                        saveChanges()
                        self.changesToSave = false
                    }
                    .disabled(!self.changesToSave)
                    Spacer()
                }
            }
        }
        .navigationTitle(aggregate.id == nil ? "Create Aggregate" : "Edit Aggregate")
    }
    
    private func saveChanges() {
        // Implement save logic here
        // This could involve calling an API or updating a database
        print("Saving changes to Aggregate: \(aggregate)")
        self.presentationMode.wrappedValue.dismiss()
    }
}

struct ConditionView: View {
    @Binding var condition: Condition
    
    let fieldOptions = ["Start Time", "End Time", "Duration"]
    
    var body: some View {
        DisclosureGroup("Condition") {
            VStack(spacing: 10) {
                HStack {
                    Text("Field").frame(width: 80, alignment: .leading)
                    Picker("", selection: $condition.field) {
                        ForEach(fieldOptions, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                HStack {
                    Text("Comparison").frame(width: 100, alignment: .leading)
                    Spacer()
                    Picker("", selection: $condition.comparisonOperator) {
                        ForEach(ComparisonOperator.allCases, id: \.self) { op in
                            Text(op.rawValue.capitalized).tag(op)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .onChange(of: condition.comparisonOperator) { newValue in
                        print("New value: \(newValue)")
                    }
                }
                
                HStack {
                    Text("Value").frame(width: 150, alignment: .leading)
                    TextField("", text: $condition.value)
                        .multilineTextAlignment(.trailing)
                        
                }
            }
        }
    }
}

struct GoalView: View {
    @Binding var goal: Goal
    
    var body: some View {
        VStack(alignment: .leading) {
            TextField("Comparison Operator", text: $goal.comparisonOperator)
            TextField("Value", value: Binding(
                get: { goal.value as? String ?? "" },
                set: { goal.value = $0 }
            ), formatter: Formatter())
        }
    }
}
