//
//  File.swift
//  History
//
//  Created by Nathik Azad on 4/8/24.
//

import SwiftUI

// Define your custom views for each tab
struct TimelineView: View {
    @StateObject var interactionController = InteractionsController()    
    var body: some View {
        Group {
            if interactionController.interactions.isEmpty {
                // Fullscreen message for no todos
                VStack {
                    Spacer()
                    Text("No Events Yet")
                        .foregroundColor(.black)
                        .font(.title2)
                    Text("Record your first event by clicking the microphone below and saying what you did.")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center) // This will center-align the text horizontally
                        .padding(.horizontal)
                    Spacer()
                }
            } else {
                List {
                    ForEach(interactionController.interactions, id: \.id) { interaction in
                        HStack {
                            Text(interaction.formattedTime)
                                .font(.headline)
                                .frame(width: 100, alignment: .leading)
                            Divider()
                            Text(interaction.content)
                                .font(.subheadline)
                        }
                    }
                }
            }
        }
        .onAppear {
            Task {
                await interactionController.fetchInteractions()
                interactionController.listenToInteractions()
            }
        }
        .onDisappear {
            interactionController.cancelListener()
            print("View has disappeared")
        }
    }

}


#Preview {
    TimelineView()
}
