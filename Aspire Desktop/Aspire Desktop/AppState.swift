//
//  AppState.swift
//  Aspire Desktop
//
//  Created by Nathik Azad on 9/9/24.
//

import SwiftUI

final class ScreenshotSettings {
    var interval: Int
    var saveDirectory: String
    
    init(interval: Int, saveDirectory: String) {
        self.interval = interval
        self.saveDirectory = saveDirectory
    }
}

class AppState: ObservableObject {
    @Published var isRunning = false
    @Published var interval = 10
    @Published var screenshotFiles: [String] = []
    @Published var selectedImage: NSImage?
    @Published var isImagePresented = false
    @Published var errorMessage: String?
    @State private var settings: ScreenshotSettings = ScreenshotSettings(interval: 10, saveDirectory: "Screenshots")
    @State private var timer: Timer?
    
    func toggleScreenshots() {
        if isRunning {
            stopScreenshots()
        } else {
            startScreenshots()
        }
        self.isRunning.toggle()
    }
    
    private func startScreenshots() {
        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(settings.interval), repeats: true) { _ in
            let inactivityThreshold: TimeInterval = 10 // 1 minute
            let lastEventTime = CGEventSource.secondsSinceLastEventType(.combinedSessionState, eventType: CGEventType(rawValue: ~0)! )
            
            print("Time since last \(lastEventTime)")
            
            if lastEventTime > inactivityThreshold {
                print("User inactive. Skipping screenshot.")
                return
            }
            
            let result = ImageOperations.takeScreenshot(saveDirectory: self.settings.saveDirectory, interval: self.settings.interval)
            switch result {
            case .success(_):
                self.errorMessage = nil
                self.fetchScreenshotFiles()
            case .failure(let error):
                self.errorMessage = "Error taking screenshot: \(error.localizedDescription)"
            }
        }
    }
    
    func stopScreenshots() {
        timer?.invalidate()
        timer = nil
    }
    
    func deleteImage(filename: String) {
        let result = FileOperations.deleteImage(filename: filename, in: settings.saveDirectory)
        switch result {
        case .success:
            fetchScreenshotFiles()
            errorMessage = nil
        case .failure(let error):
            errorMessage = "Error deleting file: \(error.localizedDescription)"
        }
    }
    
    func fetchScreenshotFiles() {
        let result = FileOperations.fetchScreenshotFiles(in: settings.saveDirectory)
        switch result {
        case .success(let files):
            screenshotFiles = files
            errorMessage = nil
        case .failure(let error):
            errorMessage = "Error fetching screenshot files: \(error.localizedDescription)"
        }
    }
    
    func loadImage(filename: String) {
        let result = ImageOperations.loadImage(filename: filename, in: settings.saveDirectory)
        switch result {
        case .success(let image):
            selectedImage = image
            isImagePresented = true
            errorMessage = nil
        case .failure(let error):
            errorMessage = "Error loading image: \(error.localizedDescription)"
        }
    }
}
