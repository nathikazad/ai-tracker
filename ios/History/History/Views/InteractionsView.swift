//
//  EventView.swift
//  History
//
//  Created by Nathik Azad on 3/18/24.
//

import SwiftUI

struct InteractionsView: View {
    @StateObject var interactionController = InteractionsController()
    
    var body: some View {
        ScrollView {
            interactionsList
        }
        .onAppear(perform: {
            Task {
                await interactionController.fetchInteractions()
                interactionController.listenToInteractions()
            }
        })
    }
    
    private var interactionsList: some View {
        ScrollViewReader { scrollView in
            VStack(alignment: .leading, spacing: 0) {
                Section() {
                    ForEach(interactionController.interactions, id: \.id) { interaction in
                        interactionRow(interaction)
                    }
                }
            }
            .onChange(of: interactionController.interactions) { _ in
                scrollToLastInteraction(using: scrollView)
            }
        }
    }
    
    private func interactionRow(_ interaction: InteractionModel) -> some View {
        HStack {
            interactionDetails(interaction)
            deleteButton(for: interaction.id)
        }
        .id(interaction.id)
    }
    
    private func interactionDetails(_ interaction: InteractionModel) -> some View {
        VStack(alignment: .leading) {
            Text(interaction.formattedTime)
            Text(interaction.content)
        }
        .padding()
    }
    
    private func deleteButton(for id: Int) -> some View {
        Button(action: {
            interactionController.deleteInteraction(id: id)
        }) {
            Image(systemName: "trash")
        }
    }
    
    private func scrollToLastInteraction(using scrollView: ScrollViewProxy) {
        if let lastId = interactionController.interactions.last?.id {
            scrollView.scrollTo(lastId, anchor: .bottom)
        }
    }
}


