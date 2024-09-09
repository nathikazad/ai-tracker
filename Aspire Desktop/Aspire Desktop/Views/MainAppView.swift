//
//  MainAppView.swift
//  Aspire Desktop
//
//  Created by Nathik Azad on 9/9/24.
//

import SwiftUI
struct MainAppView: View {
    @ObservedObject var appState: AppState
    
    var body: some View {
        VStack {
            Text("Aspire Desktop \(appState.isRunning)")
                .font(.title)
            
            Button(action: appState.toggleScreenshots) {
                Text(appState.isRunning ? "Stop Screenshots" : "Start Screenshots")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            
            HStack {
                Text("Interval:")
                Stepper(value: $appState.interval, in: 5...60, step: 5) {
                    Text("\(appState.interval) seconds")
                }
            }
            
            Button("Refresh Screenshot List") {
                appState.fetchScreenshotFiles()
            }
            .buttonStyle(.bordered)
            
            List {
                ForEach(appState.screenshotFiles, id: \.self) { file in
                    HStack {
                        Button(action: {
                            appState.loadImage(filename: file)
                        }) {
                            Text(file)
                        }
                        Spacer()
                        Button(action: {
                            appState.deleteImage(filename: file)
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .frame(height: 200)
            
            if let errorMessage = appState.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .frame(width: 400, height: 500)
        .sheet(isPresented: $appState.isImagePresented) {
            ImageViewer(image: $appState.selectedImage, isPresented: $appState.isImagePresented)
        }
        .onAppear {
            appState.fetchScreenshotFiles()
        }
    }
}
