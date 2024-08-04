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
    
    var dataType: String {
        if aggregate.metadata.aggregatorType == .compare {
            return "Time"
        } else {
            return "Number"
        }
    }
    
    var body: some View {
        Form {
            AggregatorTypeSection(model: aggregate, changesToSave: $changesToSave)
            GoalsSection(aggregate: aggregate, dataType: dataType, changesToSave: $changesToSave)
            
            SaveButtonSection(aggregate: aggregate, changesToSave: $changesToSave, saveChanges: saveChanges)
            if aggregate.id != nil {
                DeleteButtonSection(saveChanges: deleteAggregate)
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
    private func deleteAggregate() {
        Task {
            if let id = aggregate.id {
                await AggregateController.deleteAggregate(id: id)
            }
            self.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct SaveButtonSection: View {
    let aggregate: AggregateModel
    @Binding var changesToSave: Bool
    let saveChanges: () -> Void
    
    var body: some View {
        Section {
            HStack {
                Spacer()
                Button("Save", action: {
                    saveChanges()
                    changesToSave = false
                })
                .disabled(aggregate.id != nil && !changesToSave)
                Spacer()
            }
        }
    }
}

struct DeleteButtonSection: View {
    let saveChanges: () -> Void
    var body: some View {
        Section {
            HStack {
                Spacer()
                Button(role: .destructive, action: {
                    saveChanges()
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


//                    if (showField) {
//                        HStack {
//                            Text("Field").frame(width: 80, alignment: .leading)
//                            Picker("", selection: $condition.field) {
//                                ForEach(fieldOptions, id: \.self) {
//                                    Text($0)
//                                }
//                            }
//                            .pickerStyle(MenuPickerStyle())
//                        }
//                    }

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
