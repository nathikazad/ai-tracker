//
//  ATVObjectRelations.swift
//  History
//
//  Created by Nathik Azad on 8/19/24.
//

import SwiftUI
// Object Relations Section
struct ObjectRelationsSection: View {
    @ObservedObject var model: ActionTypeModel
    
    var body: some View {
        Section(header: Text("Objects Relations")) {
            ForEach(Array(model.objectConnections.keys), id: \.self) { objectKey in
                ObjectConnectionView(
                    model: model.objectConnections[objectKey]!,
                    deleteActionTypeCallback: { id in
                        model.objectConnections.removeValue(forKey: String(id))
                    })
            }
            
            NavigationLink(destination: ObjectTypeListView(
                selectionAction: { objectType in
                    Task {
                        if let id = await ActionTypeObjectTypeController.createActionTypeObjectType(actionTypeId: model.id!, objectTypeId: objectType.id!, metadata: ActionTypeConnectionMetadataForHasura(name: objectType.name)) {
                            model.objectConnections[String(id)] = ObjectConnection(id: id, name: objectType.name, objectTypeId: objectType.id!, actionTypeId: model.id!)
                        }
                    }
                }, listType: .forObjectConnection
            )) {
                Label("Add Object Relationship", systemImage: "plus")
            }
            .alignmentGuide(.listRowSeparatorLeading) { _ in -20 }
        }
    }
}
