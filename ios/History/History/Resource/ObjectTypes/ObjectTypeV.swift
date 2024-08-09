
import Foundation
import SwiftUI

struct ObjectTypeView: View {
    @ObservedObject var model: ActionTypeModel
    let objectKey: String
    @State private var object: ObjectType
    
    init(model: ActionTypeModel, objectKey: String) {
        self._model = ObservedObject(wrappedValue: model)
        self.objectKey = objectKey
        self._object = State(initialValue: model.internalObjects[objectKey] ?? ObjectType(name: "", description: "", fields: [:]))
    }
    
    var body: some View {
        DisclosureGroup {
            HStack {
                Text("Name:")
                TextField("Name", text: $object.name)
            }
            VStack(alignment: .leading) {
                Text("Description:")
                TextEditor(text: $object.description)
                    .frame(height: 100)  // Adjust this value to approximate 4 lines
                    .padding(4)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)
            }
            
            ForEach(Array(object.fields.keys.sorted()), id: \.self) { fieldKey in
                InternalObjectFieldView(
                    model: model,
                    objectKey: objectKey,
                    fieldKey: fieldKey,
                    deleteField:  {
                        object.fields.removeValue(forKey: fieldKey)
                        model.internalObjects[objectKey] = object
                    }
                )
            }
            
            Button(action: addNewField) {
                Label("Add Item To Object", systemImage: "plus")
            }
            
            Button(action: deleteObject) {
                Label("Delete Object", systemImage: "trash")
                    .foregroundColor(.red)
            }
            .buttonStyle(BorderlessButtonStyle())
            .padding(.top)
        } label: {
            Text(object.name).font(.headline)
        }
    }
    
    private func addNewField() {
        let newKey = generateRandomString()
        object.fields[newKey] = Schema(name: "New Field", dataType: "String", description: "")
        model.internalObjects[objectKey] = object
    }
    
    
    private func deleteObject() {
        model.internalObjects.removeValue(forKey: objectKey)
    }
}

struct InternalObjectFieldView: View {
    @ObservedObject var model: ActionTypeModel
    let objectKey: String
    let fieldKey: String
    var deleteField: (() -> Void)
    
    var body: some View {
        DisclosureGroup {
            VStack(alignment: .leading) {
                SchemaView(schema: Binding(
                    get: {
                        model.internalObjects[objectKey]?.fields[fieldKey] ?? Schema(name: "", dataType: "String", description: "")
                    },
                    set: { newValue in
                        model.internalObjects[objectKey]?.fields[fieldKey] = newValue
                        model.objectWillChange.send()
                    }
                ), validDataTypes: model.internalDataTypes + externalDataTypes)
                
                Button(action: deleteField) {
                    Label("Delete", systemImage: "trash")
                        .foregroundColor(.red)
                }
                .buttonStyle(BorderlessButtonStyle())
                .padding(.top)
            }
        } label: {
            Text(model.internalObjects[objectKey]?.fields[fieldKey]?.name ?? "").font(.headline)
        }
    }
}
