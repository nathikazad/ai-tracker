//
//  ContentView.swift
//  MiniHistory Watch App
//
//  Created by Nathik Azad on 3/17/24.
//

import SwiftUI

enum RecordingState {
    case ready
    case waitingForRecordingToStart
    case recording
    case waitingForRecordingToStop
}

struct ContentView: View {
    @StateObject var watchConnector = WatchToiOS()
    @State private var processingClickButton = false;
    @State var recordingState: RecordingState = .ready
    @State private var responseText: String?
    @StateObject var audioRecorder = AudioRecorder();
    var body: some View {
        VStack {
            if let responseText = responseText {
                Text(responseText).padding()
            }
            Button(action: clickButton) {
                Image(systemName: systemImageNameForRecordingState())
                    .font(.largeTitle)
                    .padding()
            }
            .disabled(recordingState == .waitingForRecordingToStart || recordingState == .waitingForRecordingToStop)
        }
        .padding()
        .onAppear {
            appeared();
        }
    }
    
    func clickButton() {
        if recordingState == .recording {
            self.recordingState = .waitingForRecordingToStop
            print("waitingForRecordingToStop")
            Task.init {
                await stopListening()
                print("recording stopped")

            }
        } else if recordingState == .ready {
            self.recordingState = .waitingForRecordingToStart
            print("waitingForRecordingToStart")
            Task.init {
                await startListening()
                print("recording started")
            }
        }
    }
    
    
    func sendData() {
        print("send data")
        watchConnector.sendDataToiOS(data: "Testing")
    }
    
    private func systemImageNameForRecordingState() -> String {
            switch recordingState {
            case .ready:
                    return "mic.fill"
            case .recording:
                    return "stop.fill"
            case .waitingForRecordingToStart:
                return "heart.fill"
            case .waitingForRecordingToStop:
                return "heart.fill"
            }
        }
    
    func appeared() {
//        NotificationCenter.default.addObserver(forName: .startListeningNotification, object: nil, queue: .main) { _ in
//            Task.init {
//                await self.startListening()
//            }
//        }
    }
    
    private func startListening() async {
        print("start listenting")
        responseText = nil
        
        await audioRecorder.startRecording();
        self.recordingState = .recording
    }
    
    private func stopListening() async {
        let fileUrl = await audioRecorder.stopRecording()
        do {
            let data = try AudioUploader().uploadAudioFile(at: fileUrl, to: uploadAudioEndpoint)
            if let data = data, let responseText = String(data: data, encoding: .utf8)
            {
                DispatchQueue.main.async {
                    self.responseText = responseText //
                    self.recordingState = .ready
                }
                print("Received text: \(responseText)")
            }
        } catch {
            DispatchQueue.main.async {
                self.responseText = "Some uploading error"
                self.recordingState = .ready
            }
            print("Some uploading error")
        }
    }
}

#Preview {
    ContentView()
}
