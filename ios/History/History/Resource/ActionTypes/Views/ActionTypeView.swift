//
//  EditActionTypeView.swift
//  History
//
//  Created by Nathik Azad on 7/24/24.
//
import SwiftUI

import Foundation
struct ActionTypeView: View {
    @State private var changesToSave:Bool = false
    @StateObject var model: ActionTypeModel = ActionTypeModel(name: "", meta: ActionTypeMeta(), staticFields: ActionModelTypeStaticSchema())
    var updateActionTypeCallback: ((ActionTypeModel) -> Void)?
    var deleteActionTypeCallback: ((Int) -> Void)?
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Name:")
                    TextField("Name", text: Binding(
                        get: { model.name },
                        set: {
                            newValue in model.name = newValue
                            changesToSave = true
                        }
                    ))
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
                        changesToSave = true
                    }
                
                VStack(alignment: .leading) {
                    Text("Description:")
                    TextEditor(text: Binding(
                        get: { model.meta.description ?? "" },
                        set: {
                            newValue in model.meta.description = newValue
                            changesToSave = true
                        }
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
                        set: {
                            newValue in model.staticFields.startTime = newValue
                            changesToSave = true
                        }
                    ), dataType: "DateTime")
                } label: {
                    Text("Start Time").font(.headline)
                }
                
                DisclosureGroup {
                    SchemaView(schema: Binding(
                        get: { model.staticFields.endTime ?? Schema(
                            name:"End Time", dataType: "DateTime", description: "") },
                        set: {
                            newValue in model.staticFields.endTime = newValue
                            changesToSave = true
                        }
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
                        set: {
                            newValue in model.staticFields.time = newValue
                            changesToSave = true
                        }
                    ), dataType: "DateTime")
                } label: {
                    Text("Time").font(.headline)
                }
            }
            
            Section(header: Text("Dynamic Fields")) {
                let sortedDynamicFields = Array(model.dynamicFields.keys).sorted(by: { model.dynamicFields[$0]?.rank ?? 0 < model.dynamicFields[$1]?.rank ?? 0 })
                ForEach(sortedDynamicFields, id: \.self) { originalKey in
                    DynamicFieldView(
                        model: model,
                        changesToSave: $changesToSave, 
                        originalKey: originalKey
                    )
                }
                Button(action: {
                    let existingMaxRank = model.dynamicFields.values.max(by: { $0.rank < $1.rank })?.rank ?? 0
                    model.dynamicFields[generateRandomString()] = Schema(name: "New Field", dataType: "ShortString", description: "", rank: existingMaxRank + 1)
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
                        updateActionTypeCallback?(model)
                        changesToSave = false
                    }
                }) {
                    Label("Update \(model.name)", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .disabled(!changesToSave)

                Button(role: .destructive, action: {
                    Task {
                        await ActionTypesController.deleteActionTypeModel(id: model.id!)
                        self.presentationMode.wrappedValue.dismiss()
                        deleteActionTypeCallback?(model.id!)
                    }
                }) {
                    Label("Delete \(model.name)", systemImage: "trash")
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            } else {
                Button(action: {
                    Task {
                        if let id = await ActionTypesController.createActionTypeModel(model: model) {
                            model.id = id
                        }
                        changesToSave = false
                        updateActionTypeCallback?(model)
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    Text("Create \(model.name) Action")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .disabled(!changesToSave)
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




