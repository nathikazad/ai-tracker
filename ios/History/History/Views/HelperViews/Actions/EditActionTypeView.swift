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
            Section {
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
                            model.staticFields.startTime = Schema(
                                name: "Start Time", dataType: "String", description: "Start time of the action")
                            model.staticFields.endTime = Schema(
                                name: "End Time", dataType: "String", description: "End time of the action")
                            model.staticFields.time = nil
                            
                        } else {
                            model.staticFields.startTime = nil
                            model.staticFields.endTime = nil
                            model.staticFields.time = Schema(
                                name:"Time", dataType: "String", description: "Time of the action")
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
                    SchemaView(schema: Binding(
                        get: { model.staticFields.startTime ?? Schema(
                            name:"Start Time", dataType: "String", description: "") },
                        set: { newValue in model.staticFields.startTime = newValue }
                    ), dataType: "DateTime")
                } label: {
                    Text("Start Time").font(.headline)
                }
                
                DisclosureGroup {
                    SchemaView(schema: Binding(
                        get: { model.staticFields.endTime ?? Schema(
                            name:"End Time", dataType: "String", description: "") },
                        set: { newValue in model.staticFields.endTime = newValue }
                    ), dataType: "DateTime")
                } label: {
                    Text("End Time").font(.headline)
                }
                
            }
            else {
                DisclosureGroup {
                    SchemaView(schema: Binding(
                        get: { model.staticFields.time ?? Schema(
                            name:"Time", dataType: "String", description: "") },
                        set: { newValue in model.staticFields.time = newValue }
                    ), dataType: "DateTime")
                } label: {
                    Text("Time").font(.headline)
                }
            }
            
            Section(header: Text("Dynamic Fields")) {
                ForEach(Array(model.dynamicFields.keys), id: \.self) { originalKey in
                    DynamicFieldView(model: model, originalKey: originalKey)
                }
                Button(action: {
                    model.dynamicFields[generateRandomString()] = Schema(name: "New Field", dataType: "String", description: "")
                }) {
                    Label("Add Dynamic Field", systemImage: "plus")
                }
            }
            
            Section(header: Text("Internal Objects")) {
                ForEach(Array(model.internalObjects.keys), id: \.self) { objectKey in
                    InternalObjectView(model: model, objectKey: objectKey)
                }
                Button(action: {
                    model.internalObjects[generateRandomString()] = InternalObject(name: "New Field", description: "", fields: [:])
                }) {
                    Label("Add Internal Object", systemImage: "plus")
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




