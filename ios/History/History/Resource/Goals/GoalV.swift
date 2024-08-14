//
//  ViewAggregate.swift
//  History
//
//  Created by Nathik Azad on 8/1/24.
//

import Foundation
import SwiftUI

struct ShowGoalView: View {
    @StateObject private var aggregate: AggregateModel
    @StateObject private var actionType: ActionTypeModel
    @State private var actions: [ActionModel] = []
    @State private var changesToSave: Bool = false
    var clickAction: (() -> Void)?
    @Environment(\.presentationMode) var presentationMode
    
    init(aggregateModel: AggregateModel, clickAction: (() -> Void)? = nil) {
        _aggregate = StateObject(wrappedValue: aggregateModel)
        _actionType = StateObject(wrappedValue:aggregateModel.actionType ?? ActionTypeModel(id: aggregateModel.actionTypeId, name: "Unknown"))
        self.clickAction = clickAction
    }
    
    init(actionTypeId: Int) {
        _aggregate = StateObject(wrappedValue: AggregateModel(actionTypeId: actionTypeId))
        _actionType = StateObject(wrappedValue: ActionTypeModel(id: actionTypeId, name: "Unknown"))
    }
    
    var changesToSaveBinding: Binding<Bool> {
        Binding(
            get: { changesToSave },
            set: {
                Task { @MainActor in
                    aggregate.objectWillChange.send()
                }
                changesToSave = $0
            })
    }
    
    var title: String {
        let name = aggregate.metadata.name == "" ? "\(aggregate.actionType?.name ?? "") Goal" : aggregate.metadata.name
        return aggregate.id == nil ? "Create \(name)" : "Edit \(name)"
    }
    
    var body: some View {
        Form {
            AggregatorFieldsSection(model: aggregate, actionTypeModel: actionType, changesToSave: changesToSaveBinding)
            AggregateChartView(aggregate: aggregate, actionsParam: actions, actionTypeModel: actionType)
            ButtonsSection(aggregate: aggregate, changesToSave: $changesToSave, saveChanges: saveChanges, deleteAggregate: deleteAggregate)
            
        }
        .navigationTitle(title)
        .onAppear {
            Task {
                let actions = await ActionController.fetchActions(userId: Authentication.shared.userId!, actionTypeId: aggregate.actionTypeId)
                self.actions = actions
                if let actionTypeId = actionType.id {
                    if let actionType = await ActionTypesController.fetchActionType(userId: Authentication.shared.userId!, actionTypeId: actionTypeId) {
                        self.actionType.copy(actionType)
                    }
                }
            }
        }
    }
    
    private func saveChanges() {
        Task {
            if aggregate.id != nil {
                await AggregateController.updateAggregate(aggregate: aggregate)
            } else {
                await AggregateController.createAggregate(aggregate: aggregate)
            }
            self.presentationMode.wrappedValue.dismiss()
            clickAction?()
        }
    }
    private func deleteAggregate() {
        Task {
            if let id = aggregate.id {
                await AggregateController.deleteAggregate(id: id)
            }
            self.presentationMode.wrappedValue.dismiss()
        }
    }
}

