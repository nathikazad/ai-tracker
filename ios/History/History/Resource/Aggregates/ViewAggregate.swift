//
//  ViewAggregate.swift
//  History
//
//  Created by Nathik Azad on 8/1/24.
//

import Foundation
import SwiftUI

struct ShowAggregateView: View {
    @StateObject private var aggregate: AggregateModel
    @State private var actions: [ActionModel] = []
    @State private var changesToSave: Bool = false
    @Environment(\.presentationMode) var presentationMode
    
    init(aggregateModel: AggregateModel) {
        _aggregate = StateObject(wrappedValue: aggregateModel)
    }
    
    var dataType: String {
        if aggregate.metadata.aggregatorType == .compare {
            return "Time"
        } else {
            return "Number"
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
    
    var body: some View {
        Form {
            AggregatorTypeSection(model: aggregate, changesToSave: changesToSaveBinding)
            GoalsSection(aggregate: aggregate, dataType: dataType, changesToSave: changesToSaveBinding)
            
            AggregateChartView(aggregate: aggregate, actionsParam: actions)

            ButtonsSection(aggregate: aggregate, changesToSave: $changesToSave, saveChanges: saveChanges, deleteAggregate: deleteAggregate)
            
        }
        .navigationTitle(aggregate.id == nil ? "Create Aggregate" : "Edit Aggregate")
        .onAppear {
            Task {
                let actions = await ActionController.fetchActions(userId: Authentication.shared.userId!, actionTypeId: aggregate.actionTypeId)
                self.actions = actions
            }
        }
    }
    
    private func saveChanges() {
        print("Saving changes to Aggregate: \(aggregate)")
        Task {
            if aggregate.id != nil {
                await AggregateController.updateAggregate(aggregate: aggregate)
            } else {
                await AggregateController.createAggregate(aggregate: aggregate)
            }
            self.presentationMode.wrappedValue.dismiss()
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

