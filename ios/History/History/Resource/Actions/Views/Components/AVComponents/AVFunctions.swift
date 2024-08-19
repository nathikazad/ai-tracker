//
//  AVFunctions.swift
//  History
//
//  Created by Nathik Azad on 8/19/24.
//

import Foundation

extension ShowActionView {
    func fetchAction() {
        Task {
            let actions = await ActionController.fetchActions(
                userId: Authentication.shared.userId!,
                actionId: action.id,
                withObjectConnections: true,
                withChildren: true,
                withParent: true)
            if (!actions.isEmpty) {
                self.action.copy(actions[0])
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
    
    func saveChanges() {
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
            let _ = await ObjectActionController.createObjectAction(
                objectTypeActionTypeId: objectTypeActionTypeId,
                objectId: objectId,
                actionId: actionId
            )
        }
        objectConnectionsToAdd.removeAll()
        fetchAction()
    }
}
