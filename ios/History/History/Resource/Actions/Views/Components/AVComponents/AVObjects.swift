//
//  AVObjects.swift
//  History
//
//  Created by Nathik Azad on 8/19/24.
//

import SwiftUI
// Object Connections Section
struct ObjectConnectionsSection: View {
    @ObservedObject var action: ActionModel
    @Binding var objectConnectionsToAdd: [(Int, Int)]
    var fetchAction: () -> Void
    
    var body: some View {
        ForEach(Array(action.actionTypeModel.objectConnections), id: \.key) { objectConnectionId, objectConnection in
            Section(objectConnection.name) {
                if let connections = action.objectConnections[objectConnection.id] {
                    ForEach(connections, id: \.objectId) { connection in
                        ObjectConnectionRow(connection: connection, objectConnection: objectConnection, action: action, fetchAction: fetchAction)
                    }
                }
                
                if let objectType = objectConnection.objectType {
                    AddObjectConnectionButton(
                        objectType: objectType,
                        objectConnection: objectConnection,
                        action: action,
                        objectConnectionsToAdd: $objectConnectionsToAdd,
                        fetchAction: fetchAction)
                }
            }
        }
    }
}

// Object Connection Row
struct ObjectConnectionRow: View {
    let connection: ObjectAction
    let objectConnection: ObjectConnection
    @ObservedObject var action: ActionModel
    var fetchAction: () -> Void
    
    var body: some View {
        NavigationLink(destination: ObjectView(objectId: connection.objectId)) {
            Text(connection.objectName)
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

// Add Object Connection Button
struct AddObjectConnectionButton: View {
    let objectType: ObjectTypeModel
    let objectConnection: ObjectConnection
    @ObservedObject var action: ActionModel
    @Binding var objectConnectionsToAdd: [(Int, Int)]
    var fetchAction: () -> Void
    
    var body: some View {
        NavigationLink(destination: ObjectListView(
            objectType: objectType,
            selectionAction: { object in
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
            },
            listActionType: .returnToActionView
        )) {
            Label("Add \(objectType.name)", systemImage: "plus")
        }
    }
}
