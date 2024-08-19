//
//  ATVTimeSection.swift
//  History
//
//  Created by Nathik Azad on 8/18/24.
//

import SwiftUI
// Time Section
struct TimeSection: View {
    @ObservedObject var model: ActionTypeModel
    @Binding var changesToSave: Bool

    var body: some View {
        Group {
            if model.meta.hasDuration {
                DisclosureGroup {
                    SchemaView(schema: Binding(
                        get: { model.staticFields.startTime ?? Schema(name:"Start Time", dataType: .dateTime, description: "") },
                        set: { newValue in
                            model.staticFields.startTime = newValue
                            changesToSave = true
                        }
                    ), changesToSave: $changesToSave, dataType: .dateTime)
                } label: {
                    Text("Start Time").font(.headline)
                }
                
                DisclosureGroup {
                    SchemaView(schema: Binding(
                        get: { model.staticFields.endTime ?? Schema(name:"End Time", dataType: .dateTime, description: "") },
                        set: { newValue in
                            model.staticFields.endTime = newValue
                            changesToSave = true
                        }
                    ), changesToSave: $changesToSave, dataType: .dateTime)
                } label: {
                    Text("End Time").font(.headline)
                }
            } else {
                DisclosureGroup {
                    SchemaView(schema: Binding(
                        get: { model.staticFields.time ?? Schema(name:"Time", dataType: .dateTime, description: "") },
                        set: { newValue in
                            model.staticFields.time = newValue
                            changesToSave = true
                        }
                    ), changesToSave: $changesToSave, dataType: .dateTime)
                } label: {
                    Text("Time").font(.headline)
                }
            }
        }
    }
}
