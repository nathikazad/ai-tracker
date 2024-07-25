//
//  EditActionTypeView.swift
//  History
//
//  Created by Nathik Azad on 7/24/24.
//
import SwiftUI
import WrappingHStack
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
                    EditableSchemaView(schema: Binding(
                        get: { model.staticFields.startTime ?? Schema(
                            name:"Start Time", dataType: "String", description: "") },
                        set: { newValue in model.staticFields.startTime = newValue }
                    ), dataType: "DateTime")
                } label: {
                    Text("Start Time").font(.headline)
                }
                
                DisclosureGroup {
                    EditableSchemaView(schema: Binding(
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
                    EditableSchemaView(schema: Binding(
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
                    Label("Add Internal Type", systemImage: "plus")
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

private func generateRandomString() -> String {
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    return String((0..<10).map{ _ in letters.randomElement()! })
}

struct DynamicFieldView: View {
    @ObservedObject var model: ActionTypeModel
    let originalKey: String
    
    var body: some View {
        DisclosureGroup {
            VStack(alignment: .leading) {
                EditableSchemaView(schema: Binding(
                    get: {
                        model.dynamicFields[originalKey] ?? Schema(name: "", dataType: "String", description: "")
                    },
                    set: { newValue in
                        model.dynamicFields[originalKey] = newValue
                        model.objectWillChange.send()
                    }
                ), validDataTypes: model.internalDataTypes + externalDataTypes)
                
                Button(action: {
                    model.dynamicFields.removeValue(forKey: originalKey)
                }) {
                    Label("Delete", systemImage: "trash")
                        .foregroundColor(.red)
                }
                .buttonStyle(BorderlessButtonStyle())
                .padding(.top)
            }
        } label: {
            Text(model.dynamicFields[originalKey]?.name ?? "").font(.headline)
        }
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
                EditableSchemaView(schema: Binding(
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

struct InternalObjectView: View {
    @ObservedObject var model: ActionTypeModel
    let objectKey: String
    @State private var object: InternalObject
    
    init(model: ActionTypeModel, objectKey: String) {
        self._model = ObservedObject(wrappedValue: model)
        self.objectKey = objectKey
        self._object = State(initialValue: model.internalObjects[objectKey] ?? InternalObject(name: "", description: "", fields: [:]))
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
//        .onChange(of: model.internalObjects[objectKey]) { newValue in
//            if let newValue = newValue {
//                object = newValue
//            }
//        }
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


struct EditableSchemaView: View {
    @Binding var schema: Schema
    var dataType: String?
    var validDataTypes: [String] = []
    
    init(schema: Binding<Schema>, dataType: String? = nil, validDataTypes: [String]? = nil) {
        self._schema = schema
        self.dataType = dataType
        self.validDataTypes = ["String", "number", "enum"] + (validDataTypes ?? [])
        
        if let dataType = dataType {
            self._schema.wrappedValue.dataType = dataType
        }
    }
    
    var body: some View {
        HStack {
            Text("Name:")
            TextField("Name", text: $schema.name)
        }
        
        HStack {
            Text("Type:")
            if dataType == nil {
                Picker("", selection: $schema.dataType) {
                    ForEach(validDataTypes, id: \.self) { type in
                        Text(type).tag(type)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            } else {
                Text(schema.dataType)
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
        
        if schema.dataType == "enum" {
            EnumView(items: $schema.enumValues)
        }
    }
}


struct EnumView: View {
    @State private var newItem = ""
    @Binding var items: [String]
    
    var body: some View {
        VStack {
            HStack {
                Text("Enums:")
                TextField("Add Enum", text: $newItem)
                Button(action: addItem) {
                    Image(systemName: "plus")
                }
            }
            .padding()
            WrappingHStack(items, id: \.self) { item in
                ZStack(alignment: .topTrailing) {
                    Button(action: { deleteItem(item) }) {
                        Text(item)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                        .font(.system(size: 16))
                        .offset(x: 6, y: -6)
                }
                .padding(3)
            }
            .frame(minWidth: 250)
            .padding()
            
            
            
        }
    }
    private func addItem() {
        DispatchQueue.main.async {
            if !newItem.isEmpty {
                items.append(newItem)
                newItem = ""
            }
        }
    }
    
    private func deleteItem(_ item: String) {
        DispatchQueue.main.async {
            items.removeAll { $0 == item }
        }
    }
}
