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
                CompactColorPickerWithLabel(selectedColor: Binding(
                    get: { model.staticFields.color }, set:
                         { 
                             model.staticFields.color = $0
                             changesToSave = true
                             print($0)
                         }  ))
                    
            } label: {
                Text("Meta").font(.headline)
            }
            
            if model.meta.hasDuration {
                DisclosureGroup {
                    SchemaView(schema: Binding(
                        get: { model.staticFields.startTime ?? Schema(
                            name:"Start Time", dataType: .dateTime, description: "") },
                        set: {
                            newValue in model.staticFields.startTime = newValue
                            changesToSave = true
                        }
                    ), dataType: .dateTime)
                } label: {
                    Text("Start Time").font(.headline)
                }
                
                DisclosureGroup {
                    SchemaView(schema: Binding(
                        get: { model.staticFields.endTime ?? Schema(
                            name:"End Time", dataType: .dateTime, description: "") },
                        set: {
                            newValue in model.staticFields.endTime = newValue
                            changesToSave = true
                        }
                    ), dataType: .dateTime)
                } label: {
                    Text("End Time").font(.headline)
                }
                
            }
            else {
                DisclosureGroup {
                    SchemaView(schema: Binding(
                        get: { model.staticFields.time ?? Schema(
                            name:"Time", dataType: .dateTime, description: "") },
                        set: {
                            newValue in model.staticFields.time = newValue
                            changesToSave = true
                        }
                    ), dataType: .dateTime)
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
                    model.dynamicFields[generateRandomString()] = Schema(name: "New Field", dataType: .shortString, description: "", rank: existingMaxRank + 1)
                }) {
                    Label("Add Dynamic Field", systemImage: "plus")
                }
            }
            
            if model.id != nil {
                Section(header: Text("Objects Relations")) {
                    ForEach(Array(model.objectConnections.keys), id: \.self) { objectKey in
                        ObjectConnectionView(
                            model: model.objectConnections[objectKey]!,
                            deleteActionTypeCallback: {
                                id in
                                model.objectConnections.removeValue(forKey: String(id))
                            })
                    }
                    
                    NavigationLink(destination: ObjectTypeListView(
                        selectionAction: {
                            objectType in
                            Task {
                                if let id = await ActionTypeObjectTypeController.createActionTypeObjectType(actionTypeId: model.id!, objectTypeId: objectType.id!, metadata: ActionTypeConnectionMetadataForHasura(name: objectType.name)) {
                                    model.objectConnections[String(id)] = ObjectConnection(id: id, name: objectType.name, objectTypeId: objectType.id!, actionTypeId: model.id!)
                                }
                            }
                        }, listType: .forObjectConnection
                    )) {
                        Label("Add Object Relationship", systemImage: "plus")
                    }
                    .alignmentGuide(.listRowSeparatorLeading) { _ in -20 }
                    
                }
            }
            
            if let actionTypeId = model.id {
                Section(header: Text("Goals")) {
                    ForEach(Array(model.aggregates)) { aggregate in
                        NavigationLink(destination: ShowGoalView(aggregateModel: aggregate)) {
                            Text(aggregate.metadata.name)
                        }
                    }
                    NavigationLink(destination: ShowGoalView(aggregateModel: AggregateModel(actionTypeId: actionTypeId))) {
                        Label("Add Goal", systemImage: "plus")
                    }
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
                    Text("Create \(model.name) Verb")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .disabled(!changesToSave)
            }
        }
        .navigationTitle("\(model.name)")
        .onAppear {
            Task {
                if let id = self.model.id,
                   let m = await ActionTypesController.fetchActionType(
                    userId: Authentication.shared.userId!,
                    actionTypeId: id,
                    withAggregates: true,
                    withObjectConnections: true
                   ) {
                    DispatchQueue.main.async { self.model.copy(m) }
                }
            }
        }
    }
}
