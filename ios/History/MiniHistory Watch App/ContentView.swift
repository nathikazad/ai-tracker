//
//  ContentView.swift
//  MiniHistory Watch App
//
//  Created by Nathik Azad on 3/17/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var watchConnector = WatchToiOS()
    @State private var isListening = false
    @StateObject var audioRecorder = AudioRecorder();
    var body: some View {
        VStack {
            Button(action: {
                if isListening {
                    Task.init { await stopListening() }
                } else {
                    startListening()
                }
                isListening.toggle()
            }) {
                Image(systemName: isListening ? "stop.fill" : "mic.fill")
                    .font(.largeTitle)
                    .padding()
            }
        }
        .padding()
//        .onAppear(perform: startListening)
    }
    
    func sendData() {
        print("send data")
        watchConnector.sendDataToiOS(data: "Testing")
    }
    
    private func startListening() {
        print("start listenting")
        audioRecorder.startRecording();
    }
    
    private func stopListening() async {
        print("start listenting")
        let filename = await audioRecorder.stopRecording()
        print("Audio was saved in file: \(filename)")
    }
}

#Preview {
    ContentView()
}
