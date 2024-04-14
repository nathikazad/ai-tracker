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
        print("current state \(recordingState)")
        if recordingState == .recording {
            DispatchQueue.main.async {
                self.recordingState = .waitingForRecordingToStop
            }
            print("waitingForRecordingToStop")
            Task.init {
                await stopListening()
                print("recording stopped")

            }
        } else if recordingState == .ready {
            if(Authentication.shared.hasuraJwt != nil) {
                DispatchQueue.main.async {
                    self.recordingState = .waitingForRecordingToStart
                }
                print("waitingForRecordingToStart")
                Task.init {
                    await startListening()
                    print("recording started")
                }
            } else {
                responseText = "You need to sign in on ios"
            }
        }
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
        DispatchQueue.main.async {
            self.recordingState = .recording
        }
    }
    
    private func stopListening() async {
        let fileUrl = await audioRecorder.stopRecording()
        do {
            // get token from received end point
            let data = try AudioUploader().uploadAudioFile(at: fileUrl, to: parseAudioEndpoint, token: Authentication.shared.hasuraJwt)
            if let data = data {
                let decoder = JSONDecoder()
                do {
                    struct Response: Codable {
                        var status: String
                        var text: String
                    }
                    let jsonResponse = try decoder.decode(Response.self, from: data)
                    DispatchQueue.main.async {
                        self.responseText = jsonResponse.text
                        self.recordingState = .ready
                        print("Received text: \(responseText)")
                    }
                    
                }
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
