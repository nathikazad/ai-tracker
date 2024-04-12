//
//  MicrophoneButton.swift
//  History
//
//  Created by Nathik Azad on 4/8/24.
//

import SwiftUI

struct MicrophoneButton: View {
    @State private var isRecording: Bool = false
    @ObservedObject var appState = AppState.shared
    @StateObject var audioRecorder = AudioRecorder();
    
    var body: some View {
        VStack {
            Button(action: {
                clickButton()
                print("Mic button tapped!")
            }) {
                Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipped()
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(30)
                    .shadow(radius: 4)
            }
            .offset(y: -30)
            .padding(.bottom, -30)
            // Applying the long press gesture
            .simultaneousGesture(LongPressGesture().onEnded { _ in
                appState.showChat(newChatViewToShow: .normal)
                print("long press")
            })
        }
    }
    
    func clickButton() {
        if isRecording == false {
            Task.init {
                await audioRecorder.startRecording();
                print("recording started")
                isRecording = true
            }
        } else if isRecording == true {
            Task.init {
                isRecording = false
                await stopListening()
                print("recording stopped")
            }
        }
        
    }
    
    private func stopListening() async {
        let fileUrl = await audioRecorder.stopRecording()
        do {
            let data = try AudioUploader().uploadAudioFile(at: fileUrl, to: parseAudioEndpoint, token: Authentication.shared.hasuraJwt)
            if let data = data, let responseText = String(data: data, encoding: .utf8)
            {
                DispatchQueue.main.async {
                    print("Received text: \(responseText)")
                }
                
            }
        } catch {
            DispatchQueue.main.async {
                print("Some uploading error")
            }
        }
    }
}

