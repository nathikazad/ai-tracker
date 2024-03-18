//
//  ContentView.swift
//  MiniHistory Watch App
//
//  Created by Nathik Azad on 3/17/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var watchConnector = WatchToiOS()
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            Button {
                print("button clicked")
                sendData()
            } label: {
                Text("Send")
            }
        }
        .padding()
    }
    
    func sendData() {
        print("send data")
        watchConnector.sendDataToiOS(data: "Testing")
    }
}

#Preview {
    ContentView()
}
