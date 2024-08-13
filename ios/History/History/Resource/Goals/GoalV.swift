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
    @State private var actions: [ActionModel] = []
    @State private var changesToSave: Bool = false
    var clickAction: (() -> Void)?
    @Environment(\.presentationMode) var presentationMode
    
    init(aggregateModel: AggregateModel, clickAction: (() -> Void)? = nil) {
        _aggregate = StateObject(wrappedValue: aggregateModel)
        self.clickAction = clickAction
    }
    
    var dataType: String {
        if aggregate.metadata.aggregatorType == .compare {
            return "Time"
        } else if aggregate.metadata.aggregatorType == .count {
            return "Number"
        } else {
            // TODO check for the right data type
            return "Duration"
        }
    }
    
    var changesToSaveBinding: Binding<Bool> {
        Binding(
            get: { changesToSave },
            set: {
                aggregate.objectWillChange.send()
                changesToSave = $0
            })
    }
    
    var title: String {
        let name = aggregate.metadata.name == "" ? "\(aggregate.actionType?.name ?? "") Goal" : aggregate.metadata.name
        return aggregate.id == nil ? "Create \(name)" : "Edit \(name)"
    }
    
    var body: some View {
        Form {
            AggregatorFieldsSection(model: aggregate, changesToSave: changesToSaveBinding, dataType: dataType)
            AggregateChartView(aggregate: aggregate, actionsParam: actions)
            ButtonsSection(aggregate: aggregate, changesToSave: $changesToSave, saveChanges: saveChanges, deleteAggregate: deleteAggregate)
            
        }
        .navigationTitle(title)
        .onAppear {
            Task {
                let actions = await ActionController.fetchActions(userId: Authentication.shared.userId!, actionTypeId: aggregate.actionTypeId)
                self.actions = actions
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

