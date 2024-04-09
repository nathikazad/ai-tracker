//
//  File.swift
//  History
//
//  Created by Nathik Azad on 4/8/24.
//

import SwiftUI

// Define your custom views for each tab
struct TimelineView: View {
    @StateObject var interactionModel = InteractionModel()    
    var body: some View {
        NavigationView {
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
            .navigationTitle("Timeline")
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

}


#Preview {
    TimelineView()
}
