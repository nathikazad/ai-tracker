//
//  ButtonsComponent.swift
//  History
//
//  Created by Nathik Azad on 8/3/24.
//

import SwiftUI
struct ButtonsSection: View {
    let aggregate: AggregateModel
    @Binding var changesToSave: Bool
    let saveChanges: () -> Void
    let deleteAggregate: () -> Void
    
    var body: some View {
        Section {
            HStack {
                Spacer()
                Button("Save", action: {
                    saveChanges()
                    changesToSave = false
                })
                .disabled(aggregate.id != nil && !changesToSave)
                Spacer()
            }
        }
        if aggregate.id != nil {
            Section {
                HStack {
                    Spacer()
                    Button(role: .destructive, action: {
                        deleteAggregate()
                    }) {
                        Label("Delete", systemImage: "trash")
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    Spacer()
                }
            }
        }
    }
}
