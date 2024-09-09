//
//  StatusBarView.swift
//  Aspire Desktop
//
//  Created by Nathik Azad on 9/9/24.
//

import SwiftUI
struct StatusBarView: View {
    @ObservedObject var appState: AppState
    var quitAction: () -> Void
    var showMainWindowAction: () -> Void
    
    var body: some View {
        VStack(spacing: 10) {
            Button(action: appState.toggleScreenshots) {
                Text(appState.isRunning ? "Stop" : "Start")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            
            HStack {
                Text("Interval:")
                Stepper(value: $appState.interval, in: 5...60, step: 5) {
                    Text("\(appState.interval) seconds")
                }
            }
            
            Button("Show App") {
                showMainWindowAction()
            }
            .buttonStyle(.bordered)
            
            Button("Quit App") {
                quitAction()
            }
            .buttonStyle(.bordered)
            .foregroundColor(.red)
        }
        .padding()
        .frame(width: 250)
    }
}
