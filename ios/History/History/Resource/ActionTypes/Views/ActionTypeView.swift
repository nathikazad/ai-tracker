//
//  EditActionTypeView.swift
//  History
//
//  Created by Nathik Azad on 7/24/24.
//
import SwiftUI

import Foundation
struct ActionTypeView: View {
    @StateObject var model: ActionTypeModel = ActionTypeModel(name: "", meta: ActionTypeMeta(), staticFields: ActionModelTypeStaticSchema())
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
                            name:"Start Time", dataType: "DateTime", description: "") },
                        set: { newValue in model.staticFields.startTime = newValue }
                    ), dataType: "DateTime")
                } label: {
                    Text("Start Time").font(.headline)
                }
                
                DisclosureGroup {
                    SchemaView(schema: Binding(
                        get: { model.staticFields.endTime ?? Schema(
                            name:"End Time", dataType: "DateTime", description: "") },
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
                            name:"Time", dataType: "DateTime", description: "") },
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
                    model.dynamicFields[generateRandomString()] = Schema(name: "New Field", dataType: "ShortString", description: "")
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
            
            if model.id != nil {
                Button(action: {
                    Task {
                        await ActionTypesController.updateActionTypeModel(model: model)
                        createAction?(model)
                    }
                }) {
                    Label("Update \(model.name)", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            } else {
                Button(action: {
                    Task {
                        if let id = await ActionTypesController.createActionTypeModel(model: model) {
                            model.id = id
                        }
                        createAction?(model)
                    }
                }) {
                    Text("Create \(model.name) Action")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .navigationTitle(model.name)
        .onAppear {
            Task {
                if(self.model.id != nil) {
                    let m:[ActionTypeModel] = await ActionTypesController.fetchActionTypes(userId: Authentication.shared.userId!, actionTypeId: model.id!)
                    DispatchQueue.main.async {
                        if !m.isEmpty {
                            self.model.copy(m[0])
                        }
                    }
                }
            }
        }
    }
}




