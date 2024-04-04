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
                Text("Bias towards action.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 10)
                
                Text("If tired or overwhelmed, work out, cook or do nothing. Don't scroll on insta, news or twitter.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 10)
                
                Text("You don't accept to be sick, then why is it ok to be poor? Seek abundance, there is enough for everyone.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 10)
                
                Text("You are experimenting to find what consumers want, everything else is secondary for now.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 10)
            }
            .frame(maxHeight: 400) // Adjust the height as needed
            .transition(.push(from: Edge.top))
        }
    }
}

#Preview {
    DailyRemindersView()
}
