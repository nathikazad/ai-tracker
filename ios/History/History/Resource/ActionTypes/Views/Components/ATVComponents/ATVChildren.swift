//
//  ATVChildConnections.swift
//  History
//
//  Created by Nathik Azad on 8/19/24.
//

import SwiftUI
struct ChildConnectionSections: View {
    @ObservedObject var model: ActionTypeModel
    @Binding var changesToSave: Bool
    
    var body: some View {
        Section(header: Text("Child Connections")) {
            ForEach(Array(model.childConnections.keys), id: \.self) { objectKey in
                NavigationLink(destination: ActionTypeView(id: objectKey
                                                          ))
                {
                    Text("\(model.childConnections[objectKey]!)").font(.headline)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(action: {
                        model.childConnections.removeValue(forKey: objectKey)
                        changesToSave = true
                    }) {
                        Image(systemName: "trash.fill")
                    }
                    .tint(.red)
                }
            }
            
            NavigationLink(destination:
                            ListActionsTypesView(
                                clickAction: {
                                    actionType in
                                    model.childConnections[actionType.id!] = actionType.name
                                    changesToSave = true
                                }, listActionType: .returnToActionType
                            )
            ) {
                Label("Add Child Connection", systemImage: "plus")
            }
            .alignmentGuide(.listRowSeparatorLeading) { _ in -20 }
        }
    }
}
