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
            Button(action: {
                if auth.areJwtSet {
                    appState.toggleScreenshots()
                } else {
                    showMainWindowAction()
                }
            }) {
                Text(appState.isRunning ? "Stop" : "Start")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            
            HStack {
                Text("Interval:")
                Stepper(value: $appState.interval, in: 10...300, step: 10) {
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
