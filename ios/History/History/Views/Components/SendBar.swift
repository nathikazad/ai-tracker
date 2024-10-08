//
//  SendBar.swift
//  History
//
//  Created by Nathik Azad on 4/27/24.
//

import SwiftUI
import Combine
struct SendBar: View {
    @Binding var currentMessage: String
    @Binding var showKeyboard: Bool
    var sendUserMessage: (String) -> Void
    @ObservedObject var appState = state
    @FocusState private var isTextFieldFocused: Bool
    @State private var recordingSubscription: AnyCancellable?
    
    
    
    private func getLineLimit(for text: String) -> Int {
        let lineCount = text.components(separatedBy: "\n").count
        let newLength = (text.count / 26) + lineCount
        return max(1, min(5, newLength))
    }
    
    var body: some View {
        HStack {
            TextField("Message", text: $currentMessage, axis: .vertical)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .focused($isTextFieldFocused)
                .lineLimit(getLineLimit(for: currentMessage), reservesSpace: true)
            Button(action: {
                // Toggle recording state
                appState.microphoneButtonClick(parse: false)
                isTextFieldFocused = false
                
            }) {
                Image(systemName: appState.isRecording ? "stop.fill" : "mic.fill") // Change icon based on recording state
                    .foregroundColor(Color("OppositeColor"))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 8)
                    .background(Color.primary)
                    .cornerRadius(8)
            }
            .padding(.trailing, 0)
            .padding(.leading, 0)
            .onChange(of: showKeyboard) {
                print("on changed showKeyboard")
                isTextFieldFocused = showKeyboard
            }
            .onChange(of: isTextFieldFocused) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    print("on changed isTextFieldFocused")
                    showKeyboard = isTextFieldFocused
                }
            }
            SendButton {
                if !currentMessage.isEmpty {
                    sendUserMessage(currentMessage)
                    currentMessage = ""
                }
            }
            .disabled(appState.isRecording || currentMessage.isEmpty)
        }
        .padding(.bottom, 10)
        .padding(.horizontal, 20)
        .onAppear {
            recordingSubscription?.cancel()
            recordingSubscription = state.subscribeToRecordingFinished { response in
                currentMessage.append(response)
            }
        }
        .onDisappear {
            recordingSubscription?.cancel()
            recordingSubscription = nil
        }
    }
        
    
}

struct SendButton: View {
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            Text("Send")
                .foregroundColor(Color("OppositeColor"))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.primary)
                .cornerRadius(8)
        }
    }
}
