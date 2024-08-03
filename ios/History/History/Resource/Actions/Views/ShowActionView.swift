//
//  ShowActionView.swift
//  History
//
//  Created by Nathik Azad on 7/27/24.
//

import SwiftUI
import UserNotifications

struct ShowActionView: View {
    @StateObject private var action: ActionModel
    @State private var changesToSave:Bool
    var clickAction: ((ActionModel) -> Void)?
    @Environment(\.presentationMode) var presentationMode
    
    init(actionModel: ActionModel) {
        _action = StateObject(wrappedValue: actionModel)
        _changesToSave = State(initialValue: false)
    }
    
    init(actionType: ActionTypeModel, clickAction: ((ActionModel) -> Void)? = nil) {
        _action = StateObject(wrappedValue:  ActionModel(actionTypeId: actionType.id!, startTime: Date(), actionTypeModel: actionType))
        _changesToSave = State(initialValue: true)
        self.clickAction = clickAction
    }
    
    var body: some View {
        Form {
            Section(header: Text("Time Information")) {
                let startTimeLabel = action.actionTypeModel.staticFields.startTime?.name ??
                (action.actionTypeModel.meta.hasDuration ? "Start Time" : "Time")
                DatePicker(
                    "\(startTimeLabel):",
                    selection: Binding(
                        get: { self.action.startTime},
                        set: { 
                            self.action.startTime = $0
                            self.changesToSave = true
                        }
                    ),
                    displayedComponents: [.date, .hourAndMinute]
                )
                
                if action.actionTypeModel.meta.hasDuration {
                    let endTimeLabel = action.actionTypeModel.staticFields.endTime?.name ??
                    "End Time"
                    DatePicker(
                        "\(endTimeLabel):",
                        selection: Binding(
                            get: { self.action.endTime ?? Date() },
                            set: { 
                                self.action.endTime = $0
                                self.changesToSave = true
                            }
                        ),
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    if (action.id != nil && action.endTime == nil) {
                        TimerComponent(timerId: action.id!)
                    }
                }
            }
            
            if(Array(action.actionTypeModel.dynamicFields.keys).count > 0) {
                DynamicFieldsView(
                    dynamicFields: $action.actionTypeModel.dynamicFields,
                    dynamicData: $action.dynamicData,
                    updateView: {
                        self.action.objectWillChange.send()
                        self.changesToSave = true
                    })
            }
            
            Section {
                HStack {
                    Spacer()
                    Button("Save") {
                        saveChanges()
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        self.changesToSave = false
                    }
                    .disabled(!self.changesToSave)
                    Spacer()
                }
            }
        }
        .navigationTitle(action.id == nil ?  "Create \(action.actionTypeModel.name) Action": "Edit \(action.actionTypeModel.name) Action")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: ActionTypeView(
                    model: action.actionTypeModel,
                    updateActionTypeCallback: {
                        model in
                        action.actionTypeModel = model
                    },
                    deleteActionTypeCallback: {
                        actionTypeId in
                        self.presentationMode.wrappedValue.dismiss()
                    }
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

    private func saveChanges() {
        Task {
            if action.id != nil {
                await ActionController.updateActionModel(model: action)
            } else {
                let actionId = await ActionController.createActionModel(model: action)
                action.id = actionId
                self.presentationMode.wrappedValue.dismiss()
                clickAction?(action)
            }
        }
    }
}

