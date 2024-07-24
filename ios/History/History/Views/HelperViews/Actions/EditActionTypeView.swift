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
                                name: "Start Time", type: "String", description: "Start time of the action")
                            model.staticFields.endTime = Schema(
                                name: "End Time", type: "String", description: "End time of the action")
                            model.staticFields.time = nil
                            
                        } else {
                            model.staticFields.startTime = nil
                            model.staticFields.endTime = nil
                            model.staticFields.time = Schema(
                                name:"Time", type: "String", description: "Time of the action")
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
                        get: { model.staticFields.startTime ?? Schema(
                            name:"Start Time", type: "String", description: "") },
                        set: { newValue in model.staticFields.startTime = newValue }
                    ), dataType: "DateTime")
                } label: {
                    Text("Start Time").font(.headline)
                }
                
                DisclosureGroup {
                    EditableSchemaView(schema: Binding(
                        get: { model.staticFields.endTime ?? Schema(
                            name:"End Time", type: "String", description: "") },
                        set: { newValue in model.staticFields.endTime = newValue }
                    ), dataType: "DateTime")
                } label: {
                    Text("End Time").font(.headline)
                }
                
            } else {
                DisclosureGroup {
                    EditableSchemaView(schema: Binding(
                        get: { model.staticFields.time ?? Schema(
                            name:"Time", type: "String", description: "") },
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
                Button(action: addNewDynamicField) {
                    Label("Add Dynamic Field", systemImage: "plus")
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
    private func addNewDynamicField() {
        model.dynamicFields[generateRandomString()] = Schema(name: "New Field", type: "String", description: "")
    }
    
    private func generateRandomString() -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        return String((0..<10).map{ _ in letters.randomElement()! })
    }
}

struct DynamicFieldView: View {
    @ObservedObject var model: ActionTypeModel
    let originalKey: String
    
    init(model: ActionTypeModel, originalKey: String) {
        self.model = model
        self.originalKey = originalKey
    }
    
    var body: some View {
        DisclosureGroup {
            VStack(alignment: .leading) {
                HStack {
                    Button(action: {
                        model.dynamicFields.removeValue(forKey: originalKey)
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
                
                EditableSchemaView(schema: Binding(
                    get: {
                        model.dynamicFields[originalKey] ?? Schema(name: "", type: "String", description: "")
                    },
                    set: { newValue in
                        model.dynamicFields[originalKey] = newValue
                        // Force view update
                        model.objectWillChange.send()
                    }
                ))
            }
        } label: {
            Text(model.dynamicFields[originalKey]?.name ?? "").font(.headline)
        }
    }
}

struct EditableSchemaView: View {
    @Binding var schema: Schema
    var dataType: String?
    
    var body: some View {
        HStack {
            Text("Name:")
            TextField("Name", text: $schema.name)
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

