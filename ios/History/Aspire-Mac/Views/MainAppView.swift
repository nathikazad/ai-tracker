//
//  MainAppView.swift
//  Aspire Desktop
//
//  Created by Nathik Azad on 9/9/24.
//

import SwiftUI
import AuthenticationServices
struct MainAppView: View {
    @ObservedObject var appState: AppState
    
    var body: some View {
        VStack {
            if appState.isSignedIn {
                SignedInView(appState: appState)
            } else {
                SignInView(appState: appState)
            }
        }
        .padding()
        .frame(width: 400, height: 500)
    }
}

struct SignInView: View {
    @ObservedObject var appState: AppState
    var body: some View {
        VStack {
            Text("Welcome to Aspire Desktop")
                .font(.title)
                .padding()
            
            SignInWithAppleButton(
                .signIn,
                onRequest: { request in
                    request.requestedScopes = [.fullName, .email]
                },
                onCompletion: { result in
                    Task {
                        let result = await handleSignIn(result: result)
                        appState.isSignedIn = true
                    }
                }
            )
            .frame(width: 200, height: 44)
        }
    }
}

struct SignedInView: View {
    @ObservedObject var appState: AppState
    
    var body: some View {
        VStack {
            Text("Aspire Desktop")
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
            
            Button("Download Screenshots") {
                Task {
                    do {
                        print("Download and unzipping")
                        try await Supabase.downloadAndUnzipImages(dateFolderName: "20240910", bucketName: "desktop", saveDirectory: appState.saveDirectory)
                        appState.fetchScreenshotFiles()
                    } catch {
                        print("Error")
                    }
                }
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
            
            Button("Sign Out") {
                auth.signOutCallback()
                appState.isSignedIn = false
            }
            .padding(.top)
        }
        .onAppear {
            appState.fetchScreenshotFiles()
        }
        .sheet(isPresented: $appState.isImagePresented) {
            ImageViewer(image: $appState.selectedImage, isPresented: $appState.isImagePresented)
        }
    }
}
