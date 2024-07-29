//
//  ShowActionView.swift
//  History
//
//  Created by Nathik Azad on 7/27/24.
//

import SwiftUI

struct ShowActionView: View {
    @StateObject private var action: ActionModel
    
    init(actionModel: ActionModel) {
        _action = StateObject(wrappedValue: actionModel)
    }
    
    init(actionType: ActionTypeModel) {
        _action = StateObject(wrappedValue:  ActionModel(actionTypeId: actionType.id!, startTime: Date().toUTCString, actionTypeModel: actionType))
    }
    
    var body: some View {
        Form {
            Section(header: Text("Time Information")) {
                DatePicker(
                    action.actionTypeModel.staticFields.startTime?.name ?? "Start Time",
                    selection: Binding(
                        get: { self.action.startTime.getDate ?? Date()},
                        set: { self.action.startTime = $0.toUTCString }
                    ),
                    displayedComponents: [.date, .hourAndMinute]
                )
                
                if action.actionTypeModel.meta.hasDuration {
                    DatePicker(
                        action.actionTypeModel.staticFields.endTime?.name ?? "End Time",
                        selection: Binding(
                            get: { self.action.endTime?.getDate ?? Date() },
                            set: { self.action.endTime = $0.toUTCString }
                        ),
                        displayedComponents: [.date, .hourAndMinute]
                    )
                }
            }
            
            Section(header: Text("Dynamic Fields")) {
                ForEach(Array(action.actionTypeModel.dynamicFields.keys), id: \.self) { key in
                    if let field = action.actionTypeModel.dynamicFields[key] {
                        Group {
                            switch field.dataType {
                            case "LongString":
                                LongStringComponent(fieldName: field.name, value: bindingFor(key))
                            case "ShortString":
                                ShortStringComponent(fieldName: field.name, value: bindingFor(key))
                            case "Enum":
                                EnumComponent(fieldName: field.name, value: bindingFor(key), enumValues: field.getEnums)
                            default:
                                EmptyView()
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
    
    private func bindingFor(_ key: String) -> Binding<AnyCodable?> {
        Binding(
            get: { action.dynamicData[key] },
            set: { 
                action.dynamicData[key] = $0
                action.objectWillChange.send()
            }
        )
    }
    
    private func saveChanges() {
        Task {
            print(action.id)
            if let actionId = action.id {
                print("updating")
                await ActionController.updateActionModel(model: action)
            } else {
                print("creating")
                let actionId = await ActionController.createActionModel(model: action)
                action.id = actionId
            }
        }
    }
}
