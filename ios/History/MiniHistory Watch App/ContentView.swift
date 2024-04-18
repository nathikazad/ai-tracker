//
//  ContentView.swift
//  MiniHistory Watch App
//
//  Created by Nathik Azad on 3/17/24.
//

import SwiftUI

class AppState: ObservableObject, MicrophoneDelegate {
    @Published private(set) var isRecording: Bool = false
    @Published var isProcessingRecording: Bool = false
    var microphone = Microphone()

    init() {
        microphone.delegate = self
    }

    func didStartRecording() {
        print("ViewController is aware: Recording has started")
        isRecording = true
        isProcessingRecording = false
    }

    func didStopRecording(response: String) {
        print("ViewController is aware: Recording has stopped with response \(response)")
        isRecording = false
        isProcessingRecording = false
    }
    
    func didStartProcessingRecording() {
        isProcessingRecording = true
    }
    
    func microphoneButtonClick() {
        microphone.microphoneButtonClick()
    }
}

struct ContentView: View {
    @StateObject var phoneCommunicator = PhoneCommunicator()
    @ObservedObject var appState = AppState()
    @State private var responseText: String?

    var body: some View {
        VStack {
            if let responseText = responseText {
                Text(responseText).padding()
            }
            Button(action: appState.microphoneButtonClick) {
                Image(systemName: systemImageNameForRecordingState)
                    .font(.largeTitle)
                    .padding()
            }
            .disabled(appState.isProcessingRecording)
        }
        .onAppear{
            phoneCommunicator.sendDataToiOS()
        }
        .padding()
    }
    

    
    
    var systemImageNameForRecordingState: String {
        if appState.isProcessingRecording {
            return "heart.fill"
        } else if appState.isRecording {
            return "stop.fill"
        } else {
            return "mic.fill"
        }
    }
}

#Preview {
    ContentView()
}
