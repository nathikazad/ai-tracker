//
//  MicrophoneButton.swift
//  History
//
//  Created by Nathik Azad on 4/8/24.
//

import SwiftUI

struct MicrophoneButton: View {
    @ObservedObject var appState = AppState.shared
    
    var body: some View {
        VStack {
            Button(action: {
                appState.microphoneButtonClick()
                print("Mic button tapped!")
            }) {
                Image(systemName: appState.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipped()
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(30)
                    .shadow(radius: 4)
            }
            .offset(y: -60)
            .padding(.bottom, -30)
            // Applying the long press gesture
            .simultaneousGesture(LongPressGesture().onEnded { _ in
                appState.showChat(newChatViewToShow: .normal)
                print("long press")
            })
        }
    }
}

