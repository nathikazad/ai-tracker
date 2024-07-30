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
                        get: { self.action.startTime},
                        set: { self.action.startTime = $0 }
                    ),
                    displayedComponents: [.date, .hourAndMinute]
                )
                
                if action.actionTypeModel.meta.hasDuration {
                    DatePicker(
                        action.actionTypeModel.staticFields.endTime?.name ?? "End Time",
                        selection: Binding(
                            get: { self.action.endTime ?? Date() },
                            set: { self.action.endTime = $0 }
                        ),
                        displayedComponents: [.date, .hourAndMinute]
                    )
                }
            }
            
            if(Array(action.actionTypeModel.dynamicFields.keys).count > 0) {
                Section(header: Text("Dynamic Fields")) {
                    ForEach(Array(action.actionTypeModel.dynamicFields.keys), id: \.self) { key in
                        if let field = action.actionTypeModel.dynamicFields[key] {
                            Group {
                                switch field.dataType {
                                case "LongString":
                                    LongStringComponent(fieldName: field.name, value: bindingFor(key))
                                case "ShortString":
                                    ShortStringComponent(fieldName: field.name, value: bindingFor(key), isArray:field.array)
                                case "Enum":
                                    EnumComponent(fieldName: field.name, value: bindingFor(key), enumValues: field.getEnums)
                                case "Unit":
                                    UnitComponent(fieldName: field.name, value: bindingFor(key))
                                case "Currency":
                                    CurrencyComponent(fieldName: field.name, value: bindingFor(key))
                                case "Duration":
                                    DurationComponent(fieldName: field.name, value: bindingFor(key))
                                default:
                                    EmptyView()
                                }
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
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: ActionTypeView(
                    model: action.actionTypeModel
                )) {
                    Image(systemName: "gear")
                }
            }
        }
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
