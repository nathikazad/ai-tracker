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
