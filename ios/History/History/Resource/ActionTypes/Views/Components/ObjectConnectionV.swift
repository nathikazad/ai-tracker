//
//  ObjectConnectionV.swift
//  History
//
//  Created by Nathik Azad on 8/14/24.
//

import SwiftUI
struct ObjectConnectionView: View {
    @ObservedObject var model: ObjectConnection
    @State var changesToSave:Bool = false
    var deleteActionTypeCallback: ((Int) -> Void)
    
    var body: some View {
        DisclosureGroup {
            VStack(alignment: .leading) {
                HStack {
                    Text("Name:")
                        .frame(alignment: .leading)
                    Spacer()
                    TextField("Name", text: Binding(
                        get: {
                            model.name
                        },
                        set: { newValue in
                            model.name = newValue
                            model.objectWillChange.send()
                            changesToSave = true
                        }
                    ))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .multilineTextAlignment(.trailing)
                    .frame(width: 100)
                }
                
                HStack {
                    if changesToSave {
                        Button(action: {
                            Task {
                                let _ = await ActionTypeObjectTypeController.updateActionTypeObjectType(id: model.id, metadata: model.metadataToHasura)
                                changesToSave = false
                            }
                        }) {
                            Label("Update", systemImage: "square.and.arrow.up")
                        }
                        .transition(.move(edge: .leading).combined(with: .opacity))
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        Task {
                            let _ = await ActionTypeObjectTypeController.deleteActionTypeObjectType(id: model.id)
                            deleteActionTypeCallback(model.id)
                        }
                    }) {
                        Label("Delete", systemImage: "trash")
                            .foregroundColor(.red)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    
                    Spacer()
                }
                .animation(.default, value: changesToSave)
            }
        } label: {
            Text(model.name).font(.headline)
        }
        .alignmentGuide(.listRowSeparatorLeading) { _ in -20 } 
    }
}
