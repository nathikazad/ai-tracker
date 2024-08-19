//
//  AVChildren.swift
//  History
//
//  Created by Nathik Azad on 8/19/24.
//

import SwiftUI
struct ChildrenSection: View {
    @ObservedObject var action: ActionModel
    
    var body: some View {
        ForEach(Array(action.actionTypeModel.childConnections), id: \.key) { actionTypeId, actionTypeName in
            Section(actionTypeName) {
                if let children = action.children[actionTypeId] {
                    ForEach(children, id: \.id) { child in
                        NavigationLink(destination: ShowActionView(actionModel: child, showParent: false))
                        {
                            Text("Expense \(child.id!)")
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(action: {
                                action.children.removeChild(childId: child.id!, forId: actionTypeId)
                            }) {
                                Image(systemName: "trash.fill")
                            }
                            .tint(.red)
                        }
                    }
                }
                
                NavigationLink(destination: ShowActionView(
                    actionTypeId: actionTypeId,
                    clickAction: {
                        action in
                        action.children.addChild(action, forId: actionTypeId)
                    }, parentId: action.id
                )) {
                    Label("Add \(actionTypeName)", systemImage: "plus")
                }

            }
        }
    }
}
