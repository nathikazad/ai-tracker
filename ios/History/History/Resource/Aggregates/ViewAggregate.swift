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
                .onChange(of: aggregate.metadata.aggregatorType) { old, new in
                    if new == .sum && aggregate.metadata.field == "" {
                        aggregate.metadata.field = "Duration"
                    }
                    if new == .compare && aggregate.metadata.field == "" {
                        aggregate.metadata.field = "Start Time"
                    }
                    changesToSave = true
                }
                
                
                if (aggregate.metadata.aggregatorType != .count) {
                    Picker("Field", selection:$aggregate.metadata.field ) {
                        if (aggregate.metadata.aggregatorType == .compare) {
                            Text("Start Time").tag("Start Time")
                            Text("End Time").tag("End Time")
                        }
                        if (aggregate.metadata.aggregatorType == .sum) {
                            Text("Duration").tag("Duration")
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .onChange(of: aggregate.metadata.window) {
                        changesToSave = true
                    }
                }
                
                
                Picker("Window", selection: $aggregate.metadata.window) {
                    ForEach(ASWindow.allCases, id: \.self) { window in
                        Text(window.rawValue.capitalized).tag(window)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .onChange(of: aggregate.metadata.window) {
                    changesToSave = true
                }
            }
            
            
//            Section ("Conditions") {
//                List {
//                    ForEach(aggregate.metadata.conditions.indices, id: \.self) { index in
//                        ConditionView(index: index, condition: Binding(
//                            get: { aggregate.metadata.conditions[index] },
//                            set: { newValue in
//                                aggregate.metadata.conditions[index] = newValue
//                                aggregate.objectWillChange.send()
//                                changesToSave = true
//                            }
//                        ))
//                    }
//                    .onDelete { indices in
//                        aggregate.metadata.conditions.remove(atOffsets: indices)
//                        changesToSave = true
//                    }
//                    Button(action: {
//                        let newCondition = Condition()
//                        aggregate.metadata.conditions.append(newCondition)
//                        aggregate.objectWillChange.send()
//                        changesToSave = true
//                    }) {
//                        HStack {
//                            Image(systemName: "plus.circle.fill")
//                            Text("Add New Condition")
//                        }
//                    }
//                    .foregroundColor(.blue)
//                }
//                .navigationTitle("Track")
//            }
//            
            Section ("Goals") {
                List {
                    ForEach(aggregate.metadata.goals.indices, id: \.self) { index in
                        ConditionView(index: index, showField: false, condition: Binding(
                            get: { aggregate.metadata.goals[index] },
                            set: { newValue in
                                aggregate.metadata.goals[index] = newValue
                                aggregate.objectWillChange.send()
                                changesToSave = true
                            }
                        ))
                    }
                    .onDelete { indices in
                        aggregate.metadata.goals.remove(atOffsets: indices)
                        changesToSave = true
                    }
                    if aggregate.metadata.goals.count == 0 {
                        Button(action: {
                            let newGoal = Condition()
                            aggregate.metadata.goals.append(newGoal)
                            aggregate.objectWillChange.send()
                            changesToSave = true
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add New Goal")
                            }
                        }
                        .foregroundColor(.blue)
                    }
                }
                .navigationTitle("Track")
            }
            
            
            Section {
                HStack {
                    Spacer()
                    Button("Save") {
                        saveChanges()
                        self.changesToSave = false
                    }
                    .disabled(aggregate.id != nil && !self.changesToSave)
                    Spacer()
                }
            }
            
            if (aggregate.id != nil) {
                Section {
                    HStack {
                        Spacer()
                        Button(role: .destructive, action: {
                            Task {
                                await AggregateController.deleteAggregate(id: aggregate.id!)
                                self.presentationMode.wrappedValue.dismiss()
                            }
                        }) {
                            Label("Delete", systemImage: "trash")
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle(aggregate.id == nil ? "Create Aggregate" : "Edit Aggregate")
    }
    
    private func saveChanges() {
        print("Saving changes to Aggregate: \(aggregate)")
        Task {
            if aggregate.id != nil {
                await AggregateController.updateAggregate(aggregate: aggregate)
            } else {
                await AggregateController.createAggregate(aggregate: aggregate)
            }
            self.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct ConditionView: View {
    var index: Int
    var showField: Bool = true
    @Binding var condition: Condition
    @State private var isExpanded: Bool = true
    
    let fieldOptions = ["Start Time", "End Time", "Duration"]
    
    var body: some View {
        DisclosureGroup(
            isExpanded: $isExpanded,
            content: {
                VStack(spacing: 10) {
                    if (showField) {
                        HStack {
                            Text("Field").frame(width: 80, alignment: .leading)
                            Picker("", selection: $condition.field) {
                                ForEach(fieldOptions, id: \.self) {
                                    Text($0)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
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
                        .onChange(of: condition.comparisonOperator) { _, newValue in
                            print("New value: \(newValue)")
                        }
                    }
                    
                    if condition.field == "Start Time" || condition.field == "End Time" {
                        TimeComponent(fieldName: condition.field, time: Binding(
                            get: {
                                let formatter = DateFormatter()
                                formatter.timeStyle = .short
                                return formatter.date(from: condition.value) ?? Date()
                            },
                            set: { newValue in
                                let formatter = DateFormatter()
                                formatter.timeStyle = .short
                                condition.value = formatter.string(from: newValue)
                            }
                        ))
                    } else {
                        HStack {
                            Text("Value").frame(width: 150, alignment: .leading)
                            TextField("", text: $condition.value)
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.numberPad)
                            
                        }
                    }
                }
            },
            label: {
                Text("\(showField ? "Condition \(index+1)" : "Goal")")
            })
    }
}
