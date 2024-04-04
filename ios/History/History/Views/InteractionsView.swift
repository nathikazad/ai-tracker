//
//  EventView.swift
//  History
//
//  Created by Nathik Azad on 3/18/24.
//

import SwiftUI

struct InteractionsView: View {
    @StateObject var interactionModel = InteractionModel()

    var body: some View {
        ScrollView {
            interactionsList
        }
        .onAppear(perform: interactionModel.fetchInteractions)
    }

    private var interactionsList: some View {
        ScrollViewReader { scrollView in
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(interactionModel.interactionsGroupedByDate.enumerated()), id: \.element.date) { index, group in
                    Section(header: Text(group.date).font(.headline).padding(.vertical)) {
                        ForEach(group.interactions, id: \.id) { interaction in
                            interactionRow(interaction)
                        }
                    }
                }
            }
            .onChange(of: interactionModel.interactions) { _ in
                scrollToLastInteraction(using: scrollView)
            }
        }
    }

    private func interactionRow(_ interaction: Interaction) -> some View {
        HStack {
            interactionDetails(interaction)
            deleteButton(for: interaction.id)
        }
        .id(interaction.id)
    }

    private func interactionDetails(_ interaction: Interaction) -> some View {
        VStack(alignment: .leading) {
            Text(interaction.formattedTime)
            Text(interaction.content)
        }
        .padding()
    }

    private func deleteButton(for id: Int) -> some View {
        Button(action: {
            interactionModel.deleteInteraction(id: id)
        }) {
            Image(systemName: "trash")
        }
    }

    private func scrollToLastInteraction(using scrollView: ScrollViewProxy) {
        if let lastId = interactionModel.interactions.last?.id {
            scrollView.scrollTo(lastId, anchor: .bottom)
        }
    }
}


