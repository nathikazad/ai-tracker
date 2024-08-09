
import Foundation
import SwiftUI

struct ObjectTypeView: View {
    @StateObject var objectType: ObjectType
    var updateObjectTypeCallback: ((ObjectType) -> Void)?
    var deleteObjectTypeCallback: ((ObjectType) -> Void)?
    @State private var changesToSave:Bool = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        List {
            HStack {
                Text("Name:")
                TextField("Name", text: $objectType.name)
                    .onChange(of: objectType.name) {
                        changesToSave = true
                    }
            }

            LongStringComponent(fieldName: "Description", value: $objectType.description)
                .onChange(of: objectType.description) {
                    changesToSave = true
            }
            
            ForEach(Array(objectType.fields.keys.sorted()), id: \.self) { fieldKey in
                InternalObjectFieldView(
                    objectType: objectType,
                    fieldKey: fieldKey,
                    deleteField:  {
                        objectType.fields.removeValue(forKey: fieldKey)
                    }
                )
            }
            Button(action: addNewField) {
                Label("Add New Field To \(objectType.name)", systemImage: "plus")
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
                .disabled(!changesToSave)
            }
        }
    }
    
    private func addNewField() {
        let newKey = generateRandomString()
        objectType.fields[newKey] = Schema(name: "New Field", dataType: "ShortString", description: "")
        print(objectType.fields.count)
    }
    
    
    private func deleteObject() {
        //call delete Callback
        //model.internalObjects.removeValue(forKey: objectKey)
    }
}

struct InternalObjectFieldView: View {
    @ObservedObject var objectType: ObjectType
    let fieldKey: String
    var deleteField: (() -> Void)
    
    var body: some View {
        DisclosureGroup {
            VStack(alignment: .leading) {
                SchemaView(schema: Binding(
                    get: {
                        objectType.fields[fieldKey] ?? Schema(name: "", dataType: "ShortString", description: "")
                    },
                    set: { newValue in
                        objectType.fields[fieldKey] = newValue
                        objectType.objectWillChange.send()
                    }
                ), validDataTypes:  ["DateTime", "ShortString", "LongString", "Enum"] + externalDataTypes)
                
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
