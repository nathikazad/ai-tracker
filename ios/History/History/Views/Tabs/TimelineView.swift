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
//    let schedule = [
//        ("5:30 am", "Woke up"),
//        ("7:00 am", "Arrived at work"),
//        ("10:00 am - 10:45 am", "Gym 45 minutes"),
//        ("12:00 pm - 12:20 pm", "Practiced French"),
//        ("6:30 pm", "Left Work"),
//        ("7:00 pm", "Arrived home"),
//        ("7:30 pm - 8:30 pm", "Cooked Potato Curry"),
//        ("8:30 pm - 9:30 pm", "Danced"),
//        ("10:30 pm", "Went to sleep")
//    ]
    
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
