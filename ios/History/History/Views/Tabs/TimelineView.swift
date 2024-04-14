//
//  File.swift
//  History
//
//  Created by Nathik Azad on 4/8/24.
//

import SwiftUI

// Define your custom views for each tab
struct TimelineView: View {
    
    init() {
        print("timeline init")
    }
    @StateObject var interactionController = InteractionsController()
    @State private var refreshID = UUID()
    var body: some View {
        Group {
            if interactionController.interactions.isEmpty {
                VStack {
                    Spacer()
                    Text("No Events Yet")
                        .foregroundColor(.black)
                        .font(.title2)
                    Text("Create an event by clicking the microphone below")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center) // This will center-align the text horizontally
                        .padding(.horizontal, 20)
                    Spacer()
                }
            } else {
                listView
            }
        }
        .id(refreshID)
        .onAppear {
            print("Timelineview has appeared")
            
            if(Authentication.shared.areJwtSet) {
                Task {
                    await interactionController.fetchInteractions(userId: Authentication.shared.userId!)
                    interactionController.listenToInteractions(userId: Authentication.shared.userId!)
                }
            }
        }
        .onDisappear {
            print("Timelineview has disappeared")
            interactionController.cancelListener()
        }
    }
    
    private var emptyStateView: some View {
        VStack {
            Spacer()
            Text("No Events Yet")
                .foregroundColor(.black)
                .font(.title2)
            Text("Record your first event by clicking the microphone below and saying what you did.")
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Spacer()
        }
    }
    
    private var listView: some View {
        List {
            ForEach(interactionController.interactions, id: \.id) { interaction in
                HStack {
                    Text(interaction.formattedTime)
                        .font(.headline)
                        .frame(width: 100, alignment: .leading)
                    Divider()
                    Text(interaction.content)
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .onDelete { indices in
                indices.forEach { index in
                    let interactionId = interactionController.interactions[index].id
                    interactionController.deleteInteraction(id: interactionId)
                }
            }
        }
    }
}


#Preview {
    TimelineView()
}
