//
//  MicButtonView.swift
//  History
//
//  Created by Nathik Azad on 3/18/24.
//

import SwiftUI
import Speech

struct BottomBar: View {
    @State private var isListening = false
    @State private var text = "Press the button and start speaking"
    @StateObject var speechRecognizer = SpeechRecognizer()
    
    var body: some View {
        HStack {
            Text(isListening ? speechRecognizer.transcript : text)
                .font(.title)
                .padding()
            
            Spacer()
            Button(action: toggleListening) {
                Image(systemName: isListening ? "stop.fill" : "mic.fill")
                    .font(.largeTitle)
                    .padding()
            }
        }
    }
    
    private func toggleListening() {
        isListening.toggle()
        if isListening {
            startListening()
        } else {
            stopListening()
        }
    }
    
    private func startListening() {
        speechRecognizer.resetTranscript()
        speechRecognizer.startTranscribing()
    }
    
    private func stopListening() {
        speechRecognizer.stopTranscribing()
        print(speechRecognizer.transcript)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
