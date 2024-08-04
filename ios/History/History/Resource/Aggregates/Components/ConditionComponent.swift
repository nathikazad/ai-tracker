//
//  ConditionComponent.swift
//  History
//
//  Created by Nathik Azad on 8/3/24.
//

import SwiftUI

struct ConditionView: View {
    var index: Int
    var dataType: String
    //    @Binding var value: AnyCodable?
    
    @Binding var condition: Condition
    @State private var isExpanded: Bool = true
    
    //    let fieldOptions = ["Start Time", "End Time", "Duration"]
    
    var body: some View {
        DisclosureGroup(
            isExpanded: $isExpanded,
            content: {
                VStack(spacing: 10) {
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
                    
                    ViewDataType(
                        dataType: dataType,
                        name: "Target",
                        enums: [],
                        value: $condition.value
                    )
                }
            },
            label: {
                Text("Goal")
            }
        )
    }
}
