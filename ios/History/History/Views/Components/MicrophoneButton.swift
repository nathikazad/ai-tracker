//
//  MicrophoneButton.swift
//  History
//
//  Created by Nathik Azad on 4/8/24.
//

import SwiftUI

struct MicrophoneButton: View {
    var body: some View {
        Button(action: {
            // Perform your action here
            print("Center button tapped!")
        }) {
            Image(systemName: "mic.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 60, height: 60)
                .clipped()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(30)
                .shadow(radius: 4)
        }
        .offset(y: -30)
        .padding(.bottom, -30)
    }
}
