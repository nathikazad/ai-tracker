//
//  File.swift
//  History
//
//  Created by Nathik Azad on 4/3/24.
//

import SwiftUI

struct DailyRemindersView: View {
    @State private var isExpanded = false
    var body: some View {
        Button(action: {
            withAnimation {
                isExpanded.toggle()
            }
        }) {
            Text(isExpanded ? "Close" : "Expand")
                .foregroundColor(.blue)
                .padding()
        }
        
        // Expandable Scrollable Widget
        if isExpanded {
            ScrollView {
                // Your scrollable content here
                Text("Your scrollable content goes here.")
                    .padding()
                // Add more content as needed
            }
            .frame(maxHeight: 200) // Adjust the height as needed
            .transition(.push(from: Edge.top))
        }
    }
}
