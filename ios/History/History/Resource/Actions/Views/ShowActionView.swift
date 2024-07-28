//
//  ShowActionView.swift
//  History
//
//  Created by Nathik Azad on 7/27/24.
//

import SwiftUI

struct ShowActionView: View {
    @StateObject private var action: ActionModel
    @State private var startTime: Date
    @State private var endTime: Date?
    
    init(actionModel: ActionModel) {
        _action = StateObject(wrappedValue: actionModel)
        _startTime = State(initialValue: actionModel.startTime.getDate!)
        _endTime = State(initialValue: actionModel.endTime?.getDate)
    }
    
    init(actionType: ActionTypeModel) {
        _action = StateObject(wrappedValue:  ActionModel(actionTypeId: actionType.id!, startTime: "", actionTypeModel: actionType))
        _startTime = State(initialValue: Date())
        _endTime = State(initialValue: nil)
    }
    
    var body: some View {
        Form {
            Section(header: Text("Time Information")) {
                DatePicker(
                    action.actionTypeModel.staticFields.startTime?.name ?? "Start Time",
                    selection: $startTime,
                    displayedComponents: [.date, .hourAndMinute]
                )
                
                if action.actionTypeModel.meta.hasDuration {
                    DatePicker(
                        action.actionTypeModel.staticFields.endTime?.name ?? "End Time",
                        selection: Binding(
                            get: { self.endTime ?? self.startTime },
                            set: { self.endTime = $0 }
                        ),
                        displayedComponents: [.date, .hourAndMinute]
                    )
                }
            }
            
            Section(header: Text("Dynamic Fields")) {
                ForEach(Array(action.actionTypeModel.dynamicFields.keys), id: \.self) { key in
                    if let field = action.actionTypeModel.dynamicFields[key] {
                        if field.dataType != "LongString" {
                            HStack {
//                                                            Text("\(field.name): \(field.dataType) \(key)")
                                Text("\(field.name): ")
                                    .frame(alignment: .leading)
                                if field.dataType == "Enum" {
                                    Spacer()
                                    Picker("", selection: Binding(
                                        get: { action.dynamicData[key]?.toString ?? action.actionTypeModel.dynamicFields[key]?.getEnums.first ?? "None"},
                                        set: { newValue in
                                            action.dynamicData[key] = AnyCodable(newValue)
                                            action.objectWillChange.send()
                                        }
                                    )) {
                                        ForEach(action.actionTypeModel.dynamicFields[key]?.getEnums ?? ["None"], id: \.self) { type in
                                            Text(type).tag(type)
                                        }
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                } else if field.dataType == "ShortString" {
                                    Spacer()
                                    TextField(field.name, text: Binding(
                                        get: { action.dynamicData[key]?.toString ?? ""},
                                        set: { newValue in
                                            action.dynamicData[key] = AnyCodable(newValue)
                                            action.objectWillChange.send()
                                        }
                                    ))
                                    .frame(width: 150, alignment: .trailing)
                                    .multilineTextAlignment(.trailing)
                                }
                            }
                            
                        } else {
//                            Text("\(field.name): ")
//                            Text("\(field.name): \(field.dataType) \(key)")
                            VStack(alignment: .leading) {
                                Text("\(field.name): ")
                                TextEditor(text: Binding(
                                    get: { action.dynamicData[key]?.toString ?? ""},
                                    set: { newValue in
                                        action.dynamicData[key] = AnyCodable(newValue)
                                        action.objectWillChange.send()
                                    }))
                                .frame(height: 100)  // Adjust this value to approximate 4 lines
                                .padding(4)
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(8)
                            }
                        }
                    }
                }
            }
            
            Section {
                Button("Save") {
                    saveChanges()
                }
            }
        }
        .navigationTitle(action.id == nil ?  "Create \(action.actionTypeModel.name) Action": "Edit Action")
        .onAppear {
            Task {
                if (action.id != nil) {
                    let actions = await ActionController.fetchActions(userId: Authentication.shared.userId!, actionId: action.id)
                    if (!actions.isEmpty) {
                        self.action.copy(actions[0])
                    }
                }
            }
        }
    }
    
    private func saveChanges() {
        //        action.startTime = startTime
        //        action.endTime = endTime
        
        // Save updated action to your data source
        // This might involve calling a method on your view model or data manager
        // For example: DataManager.shared.updateAction(action)
        
        // Optionally, you might want to dismiss the view or show a confirmation message
    }
}
