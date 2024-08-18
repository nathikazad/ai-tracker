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
    @State var objectConnectionsToAdd: [(Int, Int)] = []
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
    
    enum ActionState: String, CaseIterable { case start, save, schedule }
    
    
    func fetchAction() {
        Task {
            let actions = await ActionController.fetchActions(userId: Authentication.shared.userId!, actionId: action.id, withObjectConnections: true)
            if (!actions.isEmpty) {
                self.action.copy(actions[0])
            }
        }
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
            
            if(Array(action.actionTypeModel.objectConnections.keys).count > 0) {
                //                let sortedDynamicFieldsArray = dynamicFieldsArray.sorted { dynamicFields[$0]?.rank ?? 0 < dynamicFields[$1]?.rank ?? 0 }
                ForEach(Array(action.actionTypeModel.objectConnections), id: \.key) { objectConnectionId, objectConnection in
                    Section(objectConnection.name) {
                        if let connections = action.objectConnections[objectConnection.id] {
                            ForEach(connections, id: \.objectId) { connection in
                                NavigationLink(destination: ObjectView(objectId: connection.objectId)) {
                                    Text("\(connection.objectName)")
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(action: {
                                        if let connectionId = connection.id {
                                            print("connection exists")
                                            Task {
                                                await ObjectActionController.deleteObjectAction(id: connectionId)
                                                fetchAction()
                                            }
                                        } else {
                                            print("connection does not exist")
                                            action.objectConnections.removeObjectAction(objectId: connection.objectId, forId: objectConnection.id)
                                        }
                                    }) {
                                        Image(systemName: "trash.fill")
                                    }
                                    .tint(.red)
                                }
                            }
                        }
                        //                    } else {
                        if let objectType = objectConnection.objectType {
                            NavigationLink(destination: ObjectListView(
                                objectType: objectType,
                                selectionAction: {
                                    object in
                                    if (action.id != nil) {
                                        Task {
                                            await ObjectActionController.createObjectAction(objectTypeActionTypeId: objectConnection.id, objectId: object.id!, actionId: action.id!)
                                            fetchAction()
                                        }
                                    } else {
                                        action.objectConnections.addObjectAction(
                                            ObjectAction(
                                                objectTypeActionTypeId: objectConnection.id,
                                                objectId: object.id!,
                                                objectName: object.name),
                                            forId: objectConnection.id)
                                        objectConnectionsToAdd.append((objectConnection.id, object.id!))
                                    }
                                }, listActionType: .returnToActionView
                            )) {
                                Label("Add \(objectType.name)", systemImage: "plus")
                                
                            }
                        }
                        
                    }
                }
            }
            
            Section {
                HStack {
                    Spacer()
                    Button(getActionState.rawValue.capitalized) {
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
    
    private var getActionState: ActionState {
        if action.actionTypeModel.meta.hasDuration && action.endTime == nil && action.id == nil {
            if action.startTime.timeIntervalSince(Date()) > 300 {
                return .schedule
            } else {
                return .start
            }
        }
        return .save
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
                if let actionId = actionId {
                    await createPendingObjectActions(actionId: actionId)
                }
                if getActionState != .start {
                    self.presentationMode.wrappedValue.dismiss()
                    clickAction?(action)
                }
            }
        }
    }
    
    private func createPendingObjectActions(actionId: Int) async {
        for (objectTypeActionTypeId, objectId) in objectConnectionsToAdd {
            try await ObjectActionController.createObjectAction(
                objectTypeActionTypeId: objectTypeActionTypeId,
                objectId: objectId,
                actionId: actionId
            )
        }
        objectConnectionsToAdd.removeAll()
        await fetchAction()
    }
}

