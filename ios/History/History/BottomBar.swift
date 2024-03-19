//
//  MicButtonView.swift
//  History
//
//  Created by Nathik Azad on 3/18/24.
//

import SwiftUI

struct BottomBar: View {
    @State private var isListening = false
    @State private var text = "Press the button and start speaking"
//    @StateObject var speechRecognizer = SpeechRecognizer()
    @StateObject var audioRecorder = AudioRecorder();
    
    var body: some View {
        HStack {
//            Text(isListening ? speechRecognizer.transcript : text)
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
//        speechRecognizer.resetTranscript()
//        speechRecognizer.startTranscribing()
    }
    
    private func stopListening() async {
        
        let filename = await audioRecorder.stopRecording()
        print("Audio was saved in file: \(filename)")
//        speechRecognizer.stopTranscribing()
//        print(speechRecognizer.transcript)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
