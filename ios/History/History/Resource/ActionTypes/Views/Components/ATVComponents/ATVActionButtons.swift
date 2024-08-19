//
//  ATVActionButtons.swift
//  History
//
//  Created by Nathik Azad on 8/18/24.
//

import SwiftUI
struct ActionButtons: View {
    @ObservedObject var model: ActionTypeModel
    @Binding var changesToSave: Bool
    var updateActionTypeCallback: ((ActionTypeModel) -> Void)?
    var deleteActionTypeCallback: ((Int) -> Void)?
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        Group {
            if model.id != nil {
                Button(action: {
                    Task {
                        await ActionTypesController.updateActionTypeModel(model: model)
                        updateActionTypeCallback?(model)
                        changesToSave = false
                    }
                }) {
                    Label("Update \(model.name)", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .disabled(!changesToSave)
                
                Button(role: .destructive, action: {
                    Task {
                        await ActionTypesController.deleteActionTypeModel(id: model.id!)
                        self.presentationMode.wrappedValue.dismiss()
                        deleteActionTypeCallback?(model.id!)
                    }
                }) {
                    Label("Delete \(model.name)", systemImage: "trash")
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            } else {
                Button(action: {
                    Task {
                        if let id = await ActionTypesController.createActionTypeModel(model: model) {
                            model.id = id
                        }
                        changesToSave = false
                        updateActionTypeCallback?(model)
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    Text("Create \(model.name) Verb")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .disabled(!changesToSave)
            }
        }
    }
}
