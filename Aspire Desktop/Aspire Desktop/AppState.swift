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
    @Published var isSignedIn = false
    @Published var userID: String? {
        didSet {
            if let userID = userID {
                UserDefaults.standard.set(userID, forKey: "savedUserID")
            } else {
                UserDefaults.standard.removeObject(forKey: "savedUserID")
            }
        }
    }
    @Published var isRunning = false
    @Published var interval = 10
    @Published var screenshotFiles: [String] = []
    @Published var selectedImage: NSImage?
    @Published var isImagePresented = false
    @Published var errorMessage: String?
    @State private var settings: ScreenshotSettings = ScreenshotSettings(interval: 10, saveDirectory: "Screenshots")
    private var timer: DispatchSourceTimer?
    
    init() {
        if let savedUserID = UserDefaults.standard.string(forKey: "savedUserID") {
            self.userID = savedUserID
            self.isSignedIn = true
        }
    }
    
    func toggleScreenshots() {
        if isRunning {
            stopScreenshots()
        } else {
            startScreenshots()
        }
    }
    
    private func startScreenshots() {
        guard !isRunning else { return }
        isRunning = true
        
        let queue = DispatchQueue.global(qos: .background)
        timer = DispatchSource.makeTimerSource(queue: queue)
        timer?.schedule(deadline: .now(), repeating: .seconds(settings.interval))
        timer?.setEventHandler { [weak self] in
            self?.takeScreenshot()
        }
        timer?.resume()
        
        print("Screenshots started")
    }
    
    func stopScreenshots() {
        isRunning = false
        timer?.cancel()
        timer = nil
        print("Screenshots stopped")
    }
    
    private func takeScreenshot() {
        guard isRunning else { return }
        
        let inactivityThreshold: TimeInterval = 10 // 10 seconds
        let lastEventTime = CGEventSource.secondsSinceLastEventType(.combinedSessionState, eventType: CGEventType(rawValue: ~0)!)
        
        print("Time since last activity: \(lastEventTime) seconds")
        
        if lastEventTime > inactivityThreshold {
            print("User inactive. Skipping screenshot.")
            return
        }
        
        DispatchQueue.main.async {
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
    
    func signIn(with userId: String) {
        print(userId)
        self.userID = userId
        self.isSignedIn = true
    }
    
    func signOut() {
        self.userID = nil
        self.isSignedIn = false
    }
}
