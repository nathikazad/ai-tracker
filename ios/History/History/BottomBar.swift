//
//  MicButtonView.swift
//  History
//
//  Created by Nathik Azad on 3/18/24.
//

import SwiftUI
import AVFoundation

struct BottomBar: View {
    @State private var isListening = false
    @State private var text = "Press the button and start speaking"
    @StateObject var audioRecorder = AudioRecorder();
    
    var body: some View {
        HStack {
            Text(text)
                .font(.title)
                .padding()
            
            Spacer()
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
    }
    
    private func startListening() {
        audioRecorder.startRecording();
    }
    
    private func stopListening() async {
        let fileUrl = await audioRecorder.stopRecording()
        do {
            let data = try AudioUploader().uploadAudioFile(at: fileUrl, to: "http://100.87.137.10:3000/convertAudioToInteraction")
            if let data = data, let responseText = String(data: data, encoding: .utf8) {
                print("Received text: \(responseText)")
            }
        } catch {
            print("Some uploading error")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
