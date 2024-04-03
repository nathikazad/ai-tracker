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
        NavigationView {
            ScrollView {
                ScrollViewReader { scrollView in
                    VStack(alignment: .leading) {
                        ForEach(interactionModel.interactions, id: \.id) { interaction in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(interaction.formattedTime)
                                    Text(interaction.content)
                                }
                                .padding()
                                .id(interaction.id)
                                
                                Button(action: {
                                    interactionModel.deleteInteraction(id: interaction.id)
                                }) {
                                    Image(systemName: "trash")
                                }
                            }
                        }
                    }
                    // VStack(alignment: .leading) {
                    //     ForEach(interactionModel.interactions, id: \.id) { interaction in
                    //         VStack(alignment: .leading) {
                    //             Text(interaction.formattedTime)
                    //             Text(interaction.content)
                    //         }
                    //         .padding()
                    //         .id(interaction.id)
                    //     }
                    // }
                    .onChange(of: interactionModel.interactions) { [oldInteractions = interactionModel.interactions] in
                        scrollView.scrollTo(interactionModel.interactions.last?.id, anchor: .bottom)
                    }
                }
            }
            .navigationTitle("Interactions")
        }
        .onAppear(perform: interactionModel.fetchInteractions)
    }
}
