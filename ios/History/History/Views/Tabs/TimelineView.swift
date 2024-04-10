//
//  File.swift
//  History
//
//  Created by Nathik Azad on 4/8/24.
//

import SwiftUI

// Define your custom views for each tab
struct TimelineView: View {
    @StateObject var interactionModel = InteractionsModel()    
    var body: some View {
        List {
            ForEach(interactionModel.interactions, id: \.id) { interaction in
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
                await interactionModel.fetchInteractions()
                interactionModel.listenToInteractions()
            }
        }
        .onDisappear {
            interactionModel.cancelListener()
            print("View has disappeared")
        }
    }

}


#Preview {
    TimelineView()
}
