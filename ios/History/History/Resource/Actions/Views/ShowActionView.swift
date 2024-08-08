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
                TimeInformationView(
                    startTime: $action.startTime,
                    endTime: $action.endTime,
                    hasDuration: action.actionTypeModel.meta.hasDuration,
                    startTimeLabel: action.actionTypeModel.staticFields.startTime?.name ?? "Start Time",
                    endTimeLabel: action.actionTypeModel.staticFields.endTime?.name ?? "End Time",
                    changesToSave: $changesToSave
                )
                if (action.actionTypeModel.meta.hasDuration && action.id != nil && action.endTime == nil) {
                    TimerComponent(timerId: action.id!)
                }
            }
            
            if(Array(action.actionTypeModel.dynamicFields.keys).count > 0) {
                DynamicFieldsView(
                    dynamicFields: $action.actionTypeModel.dynamicFields,
                    dynamicData: $action.dynamicData,
                    changesToSave: $changesToSave
                )
            }
            
            Section {
                HStack {
                    Spacer()
                    let showStart = action.actionTypeModel.meta.hasDuration && action.endTime == nil
                    Button(showStart ? "Start" : "Save") {
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
                self.presentationMode.wrappedValue.dismiss()
                clickAction?(action)
            } else {
                let actionId = await ActionController.createActionModel(model: action)
                action.id = actionId
                if action.actionTypeModel.meta.hasDuration && action.endTime == nil {
                    // stay here, maybe they want to start timer
                } else {
                    // else go back
                    self.presentationMode.wrappedValue.dismiss()
                    clickAction?(action)
                }
            }
        }
    }
}

