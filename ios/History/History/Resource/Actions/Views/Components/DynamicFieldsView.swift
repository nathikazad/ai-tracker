//
//  DynamicFieldsView.swift
//  History
//
//  Created by Nathik Azad on 7/31/24.
//

import SwiftUI
struct DynamicFieldsView: View {
    @Binding var dynamicFields: [String: Schema]
    @Binding var dynamicData: [String: AnyCodable]
    var updateView: (() -> Void)
    var body: some View {
        Section(header: Text("Dynamic Fields")) {
            let dynamicFieldsArray = Array(dynamicFields.keys)
            let sortedDynamicFieldsArray = dynamicFieldsArray.sorted { dynamicFields[$0]?.rank ?? 0 < dynamicFields[$1]?.rank ?? 0 }
            ForEach(sortedDynamicFieldsArray, id: \.self) { key in
                if let field = dynamicFields[key] {
                    ViewDataType(
                        dataType: field.dataType,
                        name: field.name,
                        enums: field.getEnums,
                        value: bindingFor(key),
                        updateView: updateView
                    )
                }
            }
        }
    }
    
    private func bindingFor(_ key: String) -> Binding<AnyCodable?> {
        return Binding(
            get: { dynamicData[key] },
            set: { newValue in
                if let newValue = newValue {
                    dynamicData[key] = newValue
                } else {
                    dynamicData.removeValue(forKey: key)
                }
                updateView()
            }
        )
    }
}
