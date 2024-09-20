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
    @State private var currentTime: Double = 0
    @State private var currentImage: NSImage?
    
    func deleteImage(filename: String) {
        let result = FileOperations.deleteImage(filename: filename, in: appState.saveDirectory)
        switch result {
        case .success:
            appState.fetchScreenshotFiles()
            appState.errorMessage = nil
        case .failure(let error):
            appState.errorMessage = "Error deleting file: \(error.localizedDescription)"
        }
    }
    
    func loadImage(filename: String) {
        let result = ImageOperations.loadImage(filename: filename, in: appState.saveDirectory)
        switch result {
        case .success(let image):
            currentImage = image
            appState.errorMessage = nil
        case .failure(let error):
            appState.errorMessage = "Error loading image: \(error.localizedDescription)"
        }
    }
    
    
    func formatFileInfo(filename: String) -> (time: String, app: String) {
        let components = filename.split(separator: "/")
        guard components.count == 2 else { return ("Unknown", "Unknown") }
        
        let filenameParts = components[1].split(separator: "_")
        guard filenameParts.count >= 2 else { return ("Unknown", "Unknown") }
        
        let timeString = String(filenameParts[0])
        let appName = filenameParts[1...].joined(separator: "_").replacingOccurrences(of: ".png", with: "")
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HHmmss"
        if let date = formatter.date(from: timeString) {
            formatter.dateFormat = "h:mm a"
            return (formatter.string(from: date), appName)
        }
        
        return ("Unknown", appName)
    }
    
    var sortedScreenshots: [(filename: String, timestamp: Double)] {
        appState.screenshotFiles.compactMap { filename -> (String, Double)? in
            if let timestamp = timestampFromFilename(filename) {
                return (filename, timestamp)
            }
            return nil
        }.sorted { $0.timestamp < $1.timestamp }
    }
    
    var minTime: Double { sortedScreenshots.first?.timestamp ?? 0 }
    var maxTime: Double { sortedScreenshots.last?.timestamp ?? 0 }
    
    var currentScreenshot: (filename: String, timestamp: Double)? {
        sortedScreenshots.last { $0.timestamp <= currentTime }
    }
    
    func timestampFromFilename(_ filename: String) -> Double? {
        let components = filename.split(separator: "/")
        guard components.count == 2 else { return nil }
        
        let datePart = String(components[0])
        let timePart = String(components[1].prefix(6))
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        
        if let date = dateFormatter.date(from: datePart + timePart) {
            return date.timeIntervalSince1970
        }
        
        return nil
    }
    
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
                Stepper(value: $appState.interval, in: 10...300, step: 10) {
                    Text("\(appState.interval) seconds")
                }
            }
            
//            Button("Refresh Screenshot List") {
//                appState.fetchScreenshotFiles()
//            }
//            .buttonStyle(.bordered)
//            
//            Button("Download Screenshots") {
//                Task {
//                    do {
//                        print("Download and unzipping")
//                        try await Supabase.downloadAndUnzipImages(dateFolderName: "20240910", bucketName: "desktop", saveDirectory: appState.saveDirectory)
//                        appState.fetchScreenshotFiles()
//                    } catch {
//                        print("Error")
//                    }
//                }
//            }
//            .buttonStyle(.bordered)
            VStack {
                if !appState.screenshotFiles.isEmpty {
                    TimelineSlider(value: $currentTime,
                                   in: minTime...maxTime,
                                   step: 1,
                                   marks: sortedScreenshots.map { $0.timestamp })
                    .onChange(of: currentTime) { newValue in
                        if let (filename, _) = currentScreenshot {
                            loadImage(filename: filename)
                        }
                    }
                    .padding(.top, 10)
                    
                    if let (filename, _) = currentScreenshot {
                        let fileInfo = formatFileInfo(filename: filename)
                        HStack {
                            Spacer()
                            Text("Time: \(fileInfo.time)")
                            Text("App: \(fileInfo.app)")
                            Spacer()
                        }
                    }
                    
                    if let image = currentImage {
                        Image(nsImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 250)
                    } else {
                        Text("No image loaded")
                            .padding()
                    }
                } else {
                    Text("No screenshots available")
                        .padding()
                }
            }
            // SpeechViewer()
            //     .padding()

            
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
            if let firstImage = sortedScreenshots.first {
                loadImage(filename: firstImage.filename)
                currentTime = firstImage.timestamp
            }
        }
    }
}

struct TimelineSlider: View {
    @Binding var value: Double
    let bounds: ClosedRange<Double>
    let step: Double
    let marks: [Double]

    init(value: Binding<Double>, in bounds: ClosedRange<Double>, step: Double, marks: [Double]) {
        self._value = value
        self.bounds = bounds
        self.step = step
        self.marks = marks
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 4)
                
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: self.getThumbPosition(in: geometry), height: 4)
                
                ForEach(marks, id: \.self) { mark in
                    Rectangle()
                        .fill(Color.black)
                        .frame(width: 2, height: 10)
                        .position(x: self.getMarkPosition(for: mark, in: geometry), y: 2)
                }
                
                Circle()
                    .fill(Color.gray)
                    .frame(width: 20, height: 20)
                    .position(x: self.getThumbPosition(in: geometry), y: 2)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { gesture in
                                let newValue = self.getValue(from: gesture.location.x, in: geometry)
                                self.value = min(max(newValue, self.bounds.lowerBound), self.bounds.upperBound)
                            }
                    )
            }
        }
        .frame(height: 20)
    }

    private func getThumbPosition(in geometry: GeometryProxy) -> CGFloat {
        let range = bounds.upperBound - bounds.lowerBound
        let percentage = (value - bounds.lowerBound) / range
        return geometry.size.width * CGFloat(percentage)
    }
    
    private func getMarkPosition(for mark: Double, in geometry: GeometryProxy) -> CGFloat {
        let range = bounds.upperBound - bounds.lowerBound
        let percentage = (mark - bounds.lowerBound) / range
        return geometry.size.width * CGFloat(percentage)
    }

    private func getValue(from position: CGFloat, in geometry: GeometryProxy) -> Double {
        let percentage = Double(position / geometry.size.width)
        let range = bounds.upperBound - bounds.lowerBound
        return bounds.lowerBound + range * percentage
    }
}
