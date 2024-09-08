//
//  ShowObjectView.swift
//  History
//
//  Created by Nathik Azad on 7/27/24.
//

import SwiftUI
import UserNotifications

struct ObjectView: View {
    @StateObject private var object: ObjectModel
    @State private var changesToSave:Bool = false
    var clickObject: ((ObjectModel) -> Void)?
    @Environment(\.presentationMode) var presentationMode
    
    init(objectModel: ObjectModel) {
        _object = StateObject(wrappedValue: objectModel)
    }
    
    init(objectId: Int) {
        _object = StateObject(wrappedValue:  ObjectModel(id: objectId))
    }
    
    init(objectType: ObjectTypeModel, clickObject: ((ObjectModel) -> Void)? = nil) {
        _object = StateObject(wrappedValue:  ObjectModel(objectTypeId: objectType.id!, objectType: objectType))
        self.clickObject = clickObject
    }
    
    var body: some View {
        VStack {
            Form {
                HStack {
                    Text("Name:")
                    TextField("Name", text: $object.name)
                        .onChange(of: object.name) {
                            changesToSave = true
                        }
                }
                
                if(Array(object.objectTypeModel.fields.keys).count > 0) {
                    DynamicFieldsView(
                        dynamicFields: $object.objectTypeModel.fields,
                        dynamicData: $object.fields,
                        changesToSave: $changesToSave
                    )
                }
                
                NavigationLink(destination: GroupedActionsListView(actions: object.actions, fetchActions: fetchObject)) {
                    Text("View Associated Actions")
                }
                
                Section {
                    if object.id != nil {
                        Button(action: {
                            Task {
                                await ObjectV2Controller.updateObjectModel(model: object)
                                self.presentationMode.wrappedValue.dismiss()
                                clickObject?(object)
                                changesToSave = false
                            }
                        }) {
                            Label("Update \(object.name)", systemImage: "square.and.arrow.up")
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .alignmentGuide(.listRowSeparatorLeading) { _ in
                            -20
                        }
                        .disabled(!changesToSave)
                        
                        Button(role: .destructive, action: {
                            Task {
                                await ObjectV2Controller.deleteObjectModel(id: object.id!)
                                self.presentationMode.wrappedValue.dismiss()
                            }
                        }) {
                            Label("Delete \(object.name)", systemImage: "trash")
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    } else {
                        Button(action: {
                            Task {
                                if let id = await ObjectV2Controller.createObjectModel(model: object ) {
                                    object.id = id
                                }
                                changesToSave = false
                                self.presentationMode.wrappedValue.dismiss()
                                clickObject?(object)
                            }
                        }) {
                            Text("Create \(object.name)")
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .disabled(!changesToSave)
                    }
                }
                
            }
            
        }

//        .listSectionSpacing(0)
        .navigationTitle(object.id == nil ?  "Create \(object.objectTypeModel.name)": "Edit \(object.name)")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: ObjectTypeView(
                    objectType: object.objectTypeModel,
                    updateObjectTypeCallback: {
                        model in
                        object.objectTypeModel = model
                    },
                    deleteObjectTypeCallback: {
                        objectTypeId in
                        self.presentationMode.wrappedValue.dismiss()
                    }
                )) {
                    Image(systemName: "gear")
                }
            }
        }
        .onAppear {
            fetchObject()
        }
    }
    
    func fetchObject() {
        Task {
            if (object.id != nil) {
                let objects = await ObjectV2Controller.fetchObjects(userId: Authentication.shared.userId!, objectId: object.id, includeActions: true)
                if (!objects.isEmpty) {
                    self.object.copy(objects[0])
                }
            }
            DispatchQueue.main.async {
                changesToSave = false
            }
        }
    }
}

