//
//  ShowActionView.swift
//  History
//
//  Created by Nathik Azad on 7/27/24.
//

import SwiftUI
import UserNotifications

struct ShowActionView: View {
    @StateObject var action: ActionModel
    @State var changesToSave: Bool
    var clickAction: ((ActionModel) -> Void)?
    @State var objectConnectionsToAdd: [(Int, Int)] = []
    @Environment(\.presentationMode) var presentationMode
    var showParent:Bool = true
    
    init(actionModel: ActionModel,  showParent:Bool = true) {
        _action = StateObject(wrappedValue: actionModel)
        _changesToSave = State(initialValue: false)
        self.showParent = showParent
    }
    
    init(actionModelId: Int) {
        _action = StateObject(wrappedValue: ActionModel(actionTypeId: actionModelId))
        _changesToSave = State(initialValue: false)
        
    }
    
    init(actionTypeId: Int, clickAction: ((ActionModel) -> Void)? = nil, parentId:Int? = nil) {
        _action = StateObject(wrappedValue: ActionModel(
            actionTypeId: actionTypeId,
            startTime: Date(),
            parentId: parentId,
            actionTypeModel: ActionTypeModel(id: actionTypeId, name: "")))
        _changesToSave = State(initialValue: true)
        self.clickAction = clickAction
    }
    
    enum ActionState: String, CaseIterable { case start, save, schedule }
    
    var body: some View {
        Form {
            if showParent {
                if let parent = action.parent  {
                    Section("Parent") {
                        NavigationLink(destination: ShowActionView(actionModel: parent))
                        {
                            Text("\(parent.actionTypeModel.name)")
                        }
                    }
                    
                }
            }
            TimeInformationSection(action: action, changesToSave: $changesToSave)
            if !action.actionTypeModel.dynamicFields.isEmpty {
                DynamicFieldsView(
                    dynamicFields: $action.actionTypeModel.dynamicFields,
                    dynamicData: $action.dynamicData,
                    changesToSave: $changesToSave
                )
            }
            
            ObjectConnectionsSection(action: action, objectConnectionsToAdd: $objectConnectionsToAdd, fetchAction: fetchAction)
            
            ChildrenSection(action: action)
            
            SaveButtonSection(action: action, changesToSave: $changesToSave, saveChanges: saveChanges)
        }
        .navigationTitle(action.id == nil ? "Create \(action.actionTypeModel.name) Action" : "Edit \(action.actionTypeModel.name) Action")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: ActionTypeView(
                    model: action.actionTypeModel,
                    updateActionTypeCallback: { model in
                        action.actionTypeModel = model
                    },
                    deleteActionTypeCallback: { actionTypeId in
                        self.presentationMode.wrappedValue.dismiss()
                    }
                )) {
                    Image(systemName: "gear")
                }
            }
        }
        .onAppear {
            Task {
                if action.id != nil {
                    print("ActionV onAppear")
                    fetchAction()
                } else {
                    if let actionType = await ActionTypesController.fetchActionType(
                        userId: Authentication.shared.userId!,
                        actionTypeId: action.actionTypeId,
                        withObjectConnections: true) {
                        action.actionTypeModel = actionType
                    }
                }
            }
        }
    }
}
