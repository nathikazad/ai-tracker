//
//  ContentView.swift
//  History
//
//  Created by Nathik Azad on 3/17/24.
//

import SwiftUI

struct ContentView: View {    
    var body: some View {
        VStack {
            Text("Observe and Improve")
                .font(.largeTitle)
                .padding()
            
            Spacer()
                        
                        // Toggle Button for Expandable Widget
            DailyRemindersView()
            InteractionsView()
            
            Spacer()
            

            BottomBar()
        }
    }
}

#Preview {
    ContentView()
}
