//
//  ConditionComponent.swift
//  History
//
//  Created by Nathik Azad on 8/3/24.
//

import SwiftUI

struct GoalView: View {
    var index: Int
    var dataType: String
    
    @Binding var goal: Goal
    @State private var isExpanded: Bool = true
    
    var body: some View {
        DisclosureGroup(
            isExpanded: $isExpanded,
            content: {
                VStack(spacing: 10) {
                    HStack {
                        Text("Comparison").frame(width: 100, alignment: .leading)
                        Spacer()
                        Picker("", selection: $goal.comparisonOperator) {
                            ForEach(ComparisonOperator.allCases, id: \.self) { op in
                                Text(op.rawValue.capitalized).tag(op)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    
                    ViewDataType(
                        dataType: dataType,
                        name: "Target",
                        enums: [],
                        value: $goal.value
                    )
                    
                    WeekdaySelector(
                        selectedDays: $goal.selectedDays
                    )
//                    .padding(.vertical)
                    
                    HStack {
                        Text("Priority").frame(width: 100, alignment: .leading)
                        Spacer()
                        Picker("", selection: $goal.priority) {
                            ForEach(GoalPriority.allCases, id: \.self) { op in
                                Text(op.rawValue.capitalized).tag(op)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }
            },
            label: {
                Text("Goal")
            }
        )
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
