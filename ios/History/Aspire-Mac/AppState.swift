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
    @Published var isRunning: Bool {
        didSet {
            UserDefaults.standard.set(isRunning, forKey: "isRunning")
        }
    }
    
    @Published var interval: Int {
        didSet {
            UserDefaults.standard.set(interval, forKey: "interval")
        }
    }
    
    @Published var errorMessage: String?
    let saveDirectory = "Screenshots"
    private var timer: DispatchSourceTimer?
    @Published var screenshotFiles: [String] = []
    
    init() {
        isSignedIn = auth.areJwtSet
        self.isRunning = false
        
        self.interval = UserDefaults.standard.integer(forKey: "interval")
        if self.interval == 0 {
            self.interval = 10
        }
        
        if isSignedIn {
            let shouldBeRunning = UserDefaults.standard.bool(forKey: "isRunning")
            if shouldBeRunning {
                startScreenshots()
            }
        }
    }
    
    func fetchScreenshotFiles() {
        let result = FileOperations.fetchScreenshotFiles(in: saveDirectory)
        switch result {
        case .success(let files):
            screenshotFiles = files.sorted { (file1, file2) -> Bool in
                let date1 = dateFromFilename(file1)
                let date2 = dateFromFilename(file2)
                return date1 < date2
            }
        case .failure(let error):
            errorMessage = "Error fetching screenshot files: \(error.localizedDescription)"
        }
    }
    
    func dateFromFilename(_ filename: String) -> Date {
        let components = filename.split(separator: "/")
        guard components.count == 2 else { return Date.distantPast }
        
        let datePart = String(components[0])
        let timePart = String(components[1].prefix(6))
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        
        if let date = dateFormatter.date(from: datePart + timePart) {
            return date
        }
        
        return Date.distantPast
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
        timer?.schedule(deadline: .now(), repeating: .seconds(interval))
        timer?.setEventHandler { [weak self] in
            self?.takeScreenshot()
        }
        timer?.resume()
    }
    
    func stopScreenshots() {
        isRunning = false
        timer?.cancel()
        timer = nil
    }
    
    private func takeScreenshot() {
        guard isRunning else { return }
        
        let inactivityThreshold: TimeInterval = Double(interval - 5)
        let lastEventTime = CGEventSource.secondsSinceLastEventType(.combinedSessionState, eventType: CGEventType(rawValue: ~0)!)
        
        print("Time since last activity: \(lastEventTime) seconds")
        
        if lastEventTime > inactivityThreshold {
            print("User inactive. Skipping screenshot.")
            return
        }
        
        
        let result = ImageOperations.takeScreenshot(saveDirectory: self.saveDirectory, interval: self.interval)
        uploadImages()
        DispatchQueue.main.async {
            switch result {
            case .success(_):
                self.errorMessage = nil
                self.fetchScreenshotFiles()
            case .failure(let error):
                self.errorMessage = "Error taking screenshot: \(error.localizedDescription)"
            }
        }
    }
    
    private func uploadImages() {
        print("Checking if upload is needed")
        
        let userDefaults = UserDefaults.standard
        let lastUploadTimeKey = "lastImageUploadTime"
        let currentTime = Date()
        
        // Check if 10 minutes have passed since the last upload
        if let lastUploadTime = userDefaults.object(forKey: lastUploadTimeKey) as? Date {
            let timeSinceLastUpload = currentTime.timeIntervalSince(lastUploadTime)
            if timeSinceLastUpload < 600 {
                print("Less than 10 minutes since last upload. Skipping.")
                return
            }
        }
        
        print("Yes, needed...Uploading images")
        let pathResult = FileOperations.prepareScreenshotPath(saveDirectory: saveDirectory)
        if case .success(let screenshotInfo) = pathResult {
            Supabase.zipAndUploadImages(folderPath: screenshotInfo.path, bucketName: "desktop")
            userDefaults.set(currentTime, forKey: lastUploadTimeKey)
        }
    }
}
