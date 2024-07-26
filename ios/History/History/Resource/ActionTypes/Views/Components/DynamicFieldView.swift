//
//  DynamicFieldView.swift
//  History
//
//  Created by Nathik Azad on 7/24/24.
//

import SwiftUI

struct DynamicFieldView: View {
    @ObservedObject var model: ActionTypeModel
    let originalKey: String
    
    var body: some View {
        DisclosureGroup {
            VStack(alignment: .leading) {
                SchemaView(schema: Binding(
                    get: {
                        model.dynamicFields[originalKey] ?? Schema(name: "", dataType: "String", description: "")
                    },
                    set: { newValue in
                        model.dynamicFields[originalKey] = newValue
                        model.objectWillChange.send()
                    }
                ), validDataTypes: model.internalDataTypes + externalDataTypes)
                
                Button(action: {
                    model.dynamicFields.removeValue(forKey: originalKey)
                }) {
                    Label("Delete", systemImage: "trash")
                        .foregroundColor(.red)
                }
                .buttonStyle(BorderlessButtonStyle())
                .padding(.top)
            }
        } label: {
            Text(model.dynamicFields[originalKey]?.name ?? "").font(.headline)
        }
    }
}
