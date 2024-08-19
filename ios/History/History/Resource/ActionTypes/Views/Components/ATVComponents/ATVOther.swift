//
//  ATVOther.swift
//  History
//
//  Created by Nathik Azad on 8/18/24.
//

import SwiftUI

// Name Section
struct NameSection: View {
    @Binding var name: String
    @Binding var changesToSave: Bool

    var body: some View {
        Section {
            HStack {
                Text("Name:")
                TextField("Name", text: Binding(
                    get: { name },
                    set: { newValue in
                        name = newValue
                        changesToSave = true
                    }
                ))
            }
        }
    }
}
// Dynamic Fields Section
struct DynamicFieldsSection: View {
    @ObservedObject var model: ActionTypeModel
    @Binding var changesToSave: Bool

    var body: some View {
        Section(header: Text("Dynamic Fields")) {
            let sortedDynamicFields = Array(model.dynamicFields.keys).sorted(by: { model.dynamicFields[$0]?.rank ?? 0 < model.dynamicFields[$1]?.rank ?? 0 })
            ForEach(sortedDynamicFields, id: \.self) { originalKey in
                DynamicFieldView(
                    model: model,
                    changesToSave: $changesToSave,
                    originalKey: originalKey
                )
            }
            Button(action: {
                let existingMaxRank = model.dynamicFields.values.max(by: { $0.rank < $1.rank })?.rank ?? 0
                model.dynamicFields[generateRandomString()] = Schema(name: "New Field", dataType: .shortString, description: "", rank: existingMaxRank + 1)
            }) {
                Label("Add Dynamic Field", systemImage: "plus")
            }
        }
    }
}
// Goals Section
struct ATVGoalsSection: View {
    @ObservedObject var model: ActionTypeModel

    var body: some View {
        Section(header: Text("Goals")) {
            ForEach(Array(model.aggregates)) { aggregate in
                NavigationLink(destination: ShowGoalView(aggregateModel: aggregate)) {
                    Text(aggregate.metadata.name)
                }
            }
            NavigationLink(destination: ShowGoalView(aggregateModel: AggregateModel(actionTypeId: model.id!))) {
                Label("Add Goal", systemImage: "plus")
            }
        }
    }
}
