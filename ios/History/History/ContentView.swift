//
//  ContentView.swift
//  History
//
//  Created by Nathik Azad on 3/17/24.
//

import SwiftUI

struct ContentView: View {
    @State private var isListening = false
    
    var body: some View {
        VStack {
            Text("Observe and Improve")
                .font(.largeTitle)
                .padding()
            
            InteractionsView() 
            
            Spacer()
            

            BottomBar()
        }
    }
}

#Preview {
    ContentView()
}
