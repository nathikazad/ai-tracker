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
        let fileUrl = await audioRecorder.stopRecording()
        do {
            let data = try AudioUploader().uploadAudioFile(at: fileUrl, to: "https://ai-tracker-server-613e3dd103bb.herokuapp.com/convertAudioToInteraction")
            if let data = data, let responseText = String(data: data, encoding: .utf8) {
                print("Received text: \(responseText)")
            }
        } catch {
            print("Some uploading error")
        }
    }
}

#Preview {
    ContentView()
}
