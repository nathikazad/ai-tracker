
import Foundation
import SwiftUI

struct ObjectTypeView: View {
    @StateObject var objectType: ObjectTypeModel
    var updateObjectTypeCallback: ((ObjectTypeModel) -> Void)?
    var deleteObjectTypeCallback: ((ObjectTypeModel) -> Void)?
    @State private var changesToSave:Bool = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Form {
            ShortStringComponent(fieldName: "Name", value: $objectType.name)
                .onChange(of: objectType.name) {
                    changesToSave = true
                }
            .alignmentGuide(.listRowSeparatorLeading) { _ in
                -20
            }

            LongStringComponent(fieldName: "Description", value: $objectType.description)
                .onChange(of: objectType.description) {
                    changesToSave = true
            }
            .alignmentGuide(.listRowSeparatorLeading) { _ in
                -20
            }
            
            ForEach(Array(objectType.fields.keys.sorted()), id: \.self) { fieldKey in
                InternalObjectFieldView(
                    objectType: objectType,
                    fieldKey: fieldKey,
                    deleteField:  {
                        objectType.fields.removeValue(forKey: fieldKey)
                    }
                )
                .alignmentGuide(.listRowSeparatorLeading) { _ in
                    -20
                }
            }
            Button(action: addNewField) {
                Label("Add New Field To \(objectType.name)", systemImage: "plus")
            }
            .alignmentGuide(.listRowSeparatorLeading) { _ in
                -20
            }
            
            
            if objectType.id != nil {
                Button(action: {
                    Task {
                        await ObjectTypeController.updateObjectType(objectType: objectType)
                        updateObjectTypeCallback?(objectType)
                        changesToSave = false
                    }
                }) {
                    Label("Update \(objectType.name)", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .alignmentGuide(.listRowSeparatorLeading) { _ in
                    -20
                }
                .disabled(!changesToSave)
                
                Button(role: .destructive, action: {
                    Task {
                        await ObjectTypeController.deleteObjectType(id: objectType.id!)
                        self.presentationMode.wrappedValue.dismiss()
                        deleteObjectTypeCallback?(objectType)
                    }
                }) {
                    Label("Delete \(objectType.name)", systemImage: "trash")
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            } else {
                Button(action: {
                    Task {
                        if let id = await ObjectTypeController.createObjectType(objectType: objectType ) {
                            objectType.id = id
                        }
                        changesToSave = false
                        updateObjectTypeCallback?(objectType)
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    Text("Create \(objectType.name) Object")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .alignmentGuide(.listRowSeparatorLeading) { _ in
                    -50
                }
                .disabled(!changesToSave)
            }
        }
    }
    
    private func addNewField() {
        let newKey = generateRandomString()
        objectType.fields[newKey] = Schema(name: "New Field", dataType: .shortString, description: "")
        print(objectType.fields.count)
    }
    
    
    private func deleteObject() {
        //call delete Callback
        //model.internalObjects.removeValue(forKey: objectKey)
    }
}

struct InternalObjectFieldView: View {
    @ObservedObject var objectType: ObjectTypeModel
    let fieldKey: String
    var deleteField: (() -> Void)
    
    var body: some View {
        DisclosureGroup {
            VStack(alignment: .leading) {
                SchemaView(schema: Binding(
                    get: {
                        objectType.fields[fieldKey] ?? Schema(name: "", dataType: .shortString, description: "")
                    },
                    set: { newValue in
                        objectType.fields[fieldKey] = newValue
                        objectType.objectWillChange.send()
                    }
                ))
                
                
                Button(action: deleteField) {
                    Label("Delete", systemImage: "trash")
                        .foregroundColor(.red)
                }
                .buttonStyle(BorderlessButtonStyle())
                .padding(.top)
            }
        } label: {
            Text(objectType.fields[fieldKey]?.name ?? "").font(.headline)
        }
    }
}
