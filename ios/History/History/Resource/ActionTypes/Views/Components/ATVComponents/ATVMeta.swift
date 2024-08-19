//
//  ATVMeta.swift
//  History
//
//  Created by Nathik Azad on 8/18/24.
//

import SwiftUI
// Meta Section
struct MetaSection: View {
    @ObservedObject var model: ActionTypeModel
    @Binding var changesToSave: Bool
    var body: some View {
        DisclosureGroup {
            Toggle("Has Duration", isOn: $model.meta.hasDuration)
                .onChange(of: model.meta.hasDuration) {
                    if (model.meta.hasDuration) {
                        model.staticFields.startTime = Schema(
                            name: "Start Time", dataType: .dateTime, description: "Start time of the action")
                        model.staticFields.endTime = Schema(
                            name: "End Time", dataType: .dateTime, description: "End time of the action")
                        model.staticFields.time = nil
                        
                    } else {
                        model.staticFields.startTime = nil
                        model.staticFields.endTime = nil
                        model.staticFields.time = Schema(
                            name:"Time", dataType: .dateTime, description: "Time of the action")
                    }
                    changesToSave = true
                }
            
            VStack(alignment: .leading) {
                Text("Description:")
                TextEditor(text: Binding(
                    get: { model.meta.description ?? "" },
                    set: { newValue in
                        model.meta.description = newValue
                        changesToSave = true
                    }
                ))
                .frame(height: 100)
                .padding(4)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(8)
            }
            CompactColorPickerWithLabel(selectedColor: Binding(
                get: { model.staticFields.color },
                set: {
                    model.staticFields.color = $0
                    changesToSave = true
                }
            ))
        } label: {
            Text("Meta").font(.headline)
        }
    }
}
