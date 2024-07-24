//
//  EditActionTypeView.swift
//  History
//
//  Created by Nathik Azad on 7/24/24.
//
import SwiftUI

import Foundation
struct EditActionTypeView: View {
    var actionTypeName: String
    @StateObject var model: ActionTypeModel
    var createAction: ((ActionTypeModel) -> Void)?
    
    var body: some View {
        Form {
            Section(header: Text("Action Type Details")) {
                HStack {
                    Text("Name:")
                    TextField("Name", text: $model.name)
                }
            }
            
            DisclosureGroup {
                Toggle("Has Duration", isOn: $model.meta.hasDuration)
                    .onChange(of: model.meta.hasDuration) {
                        print("Has Duration changed to: \( model.meta.hasDuration)")
                            if (model.meta.hasDuration) {
                                model.staticFields.startTime = Schema(type: "String", description: "Start time of the action")
                                model.staticFields.endTime = Schema(type: "String", description: "End time of the action")
                                model.staticFields.time = nil
                                
                            } else {
                                model.staticFields.startTime = nil
                                model.staticFields.endTime = nil
                                model.staticFields.time = Schema(type: "String", description: "Time of the action")
                            }
                    }
                
                VStack(alignment: .leading) {
                    Text("Description:")
                    TextEditor(text: Binding(
                        get: { model.meta.description ?? "" },
                        set: { newValue in model.meta.description = newValue }
                    ))
                    .frame(height: 100)  // Adjust this value to approximate 4 lines
                    .padding(4)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)
                }
            } label: {
                Text("Meta").font(.headline)
            }
            
            if model.meta.hasDuration {
                DisclosureGroup {
                    EditableSchemaView(schema: Binding(
                        get: { model.staticFields.startTime ?? Schema(type: "String", description: "") },
                        set: { newValue in model.staticFields.startTime = newValue }
                    ), dataType: "DateTime")
                } label: {
                    Text("Start Time").font(.headline)
                }
                
                DisclosureGroup {
                    EditableSchemaView(schema: Binding(
                        get: { model.staticFields.endTime ?? Schema(type: "String", description: "") },
                        set: { newValue in model.staticFields.endTime = newValue }
                    ), dataType: "DateTime")
                } label: {
                    Text("End Time").font(.headline)
                }

            } else {
                DisclosureGroup {
                    EditableSchemaView(schema: Binding(
                        get: { model.staticFields.time ?? Schema(type: "String", description: "") },
                        set: { newValue in model.staticFields.time = newValue }
                    ), dataType: "DateTime")
                } label: {
                    Text("Time").font(.headline)
                }
            }
        }
        .navigationTitle(model.name)
        .onAppear {
            Task {
                if let m = await fetchActionType(type: actionTypeName) {
                    DispatchQueue.main.async {
                        self.model.name = m.name
                        self.model.meta = m.meta
                        self.model.staticFields = m.staticFields
                    }
                }
            }
        }
    }
}

struct EditableSchemaView: View {
    @Binding var schema: Schema
    var dataType: String?
    
    var body: some View {
        HStack {
            Text("Name:")
            TextField("Name", text: Binding(
                get: { schema.name ?? "" },
                set: { newValue in schema.name = newValue.isEmpty ? nil : newValue }
            ))
        }
        
        if dataType == nil {
            HStack {
                Text("Type:")
                TextField("Type", text: $schema.type)
            }
        } else {
            HStack {
                Text("Type:")
                Text(schema.type)
            }
        }
        
        VStack(alignment: .leading) {
            Text("Description:")
            TextEditor(text: $schema.description)
            .frame(height: 100)  // Adjust this value to approximate 4 lines
            .padding(4)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(8)
        }
        .onAppear {
            if (dataType != nil) {
                self.schema.type = dataType!
            }
        }
    }
}

