import Foundation
import SwiftUI
import SwiftData
import AVFoundation
import Cocoa

struct ScreenshotView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settings: [ScreenshotSettings]
    @State private var isRunning = false
    @State private var timer: Timer?
    @State private var errorMessage: String?
    @State private var screenshotFiles: [String] = []
    @State private var selectedImage: NSImage?
    @State private var isImagePresented = false
    
    var body: some View {
        VStack {
            Toggle("Take Screenshots", isOn: $isRunning)
                .onChange(of: isRunning) { oldValue, newValue in
                    if newValue {
                        startScreenshots()
                    } else {
                        stopScreenshots()
                    }
                }
            
            Text("Interval: \(currentSettings.interval) seconds")
            
            Button("Change Settings") {
                showSettings()
            }
            
            Button("Refresh Screenshot List") {
                fetchScreenshotFiles()
            }
            
            Button("Quit App") {
                NSApplication.shared.terminate(nil)
            }
            .foregroundColor(.red)
            
            List {
                ForEach(screenshotFiles, id: \.self) { file in
                    HStack {
                        Button(action: {
                            loadImage(filename: file)
                        }) {
                            Text(file)
                        }
                        Spacer()
                        Button(action: {
                            deleteImage(filename: file)
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .frame(height: 200)
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .onAppear {
            if settings.isEmpty {
                let defaultSettings = ScreenshotSettings(interval: 10, saveDirectory: "Screenshots")
                modelContext.insert(defaultSettings)
            }
            fetchScreenshotFiles()
        }
        .sheet(isPresented: $isImagePresented) {
            ImageViewer(image: $selectedImage, isPresented: $isImagePresented)
        }
    }
    
    private var currentSettings: ScreenshotSettings {
        settings.first ?? ScreenshotSettings(interval: 10, saveDirectory: "Screenshots")
    }
    
    private func startScreenshots() {
        createSaveDirectoryIfNeeded()
        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(10), repeats: true) { _ in
            
            let inactivityThreshold: TimeInterval = 10 // 1 minute
                let lastEventTime = CGEventSource.secondsSinceLastEventType(.combinedSessionState, eventType: .mouseMoved)
            
            print("Time since last \(lastEventTime)")
                
            if lastEventTime > inactivityThreshold {
                print("User inactive. Skipping screenshot.")
                return
            }
            takeScreenshot()
        }
    }
    
    func stopScreenshots() {
        timer?.invalidate()
        timer = nil
    }
    
    private func takeScreenshot() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
        let timestamp = dateFormatter.string(from: Date())
        let filename = "screenshot_\(timestamp).png"
        
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            errorMessage = "Unable to access Documents directory"
            return
        }
        
        let screenshotsDirectory = documentsDirectory.appendingPathComponent(currentSettings.saveDirectory)
        let url = screenshotsDirectory.appendingPathComponent(filename)
        
        if let cgImage = CGDisplayCreateImage(CGMainDisplayID()) {
            // Define the new size (e.g., 640x360)
            let newSize = CGSize(width: 320, height: 180)
            
            // Create a new bitmap context
            let colorSpace = CGColorSpaceCreateDeviceGray()
            guard let context = CGContext(data: nil,
                                          width: Int(newSize.width),
                                          height: Int(newSize.height),
                                          bitsPerComponent: 8,
                                          bytesPerRow: 0,
                                          space: colorSpace,
                                          bitmapInfo: CGImageAlphaInfo.none.rawValue) else {
                errorMessage = "Unable to create graphics context"
                return
            }
            
            // Set the interpolation quality
            context.interpolationQuality = .high
            
            // Draw the original image in the new context, effectively resizing and converting to grayscale
            context.draw(cgImage, in: CGRect(origin: .zero, size: newSize))
            
            // Get the resized grayscale image
            guard let resizedImage = context.makeImage() else {
                errorMessage = "Unable to create resized image"
                return
            }
            
            // Create an NSBitmapImageRep from the resized image
            let bitmapRep = NSBitmapImageRep(cgImage: resizedImage)
            
            // Compress the image (you can adjust the compression factor)
            if let pngData = bitmapRep.representation(using: .png, properties: [.compressionFactor: 0.7]) {
                do {
                    try pngData.write(to: url)
                    errorMessage = nil  // Clear any previous error message on success
                    fetchScreenshotFiles()  // Refresh the file list after taking a new screenshot
                    
                    // Get and print the file size
                    let fileSizeBytes = try FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int64 ?? 0
                    let fileSizeKB = Double(fileSizeBytes) / 1024.0
                    print("Screenshot saved: \(filename)")
                    print("File size: \(String(format: "%.2f", fileSizeKB)) KB")
                    
                } catch {
                    errorMessage = "Error saving screenshot: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func deleteImage(filename: String) {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            errorMessage = "Unable to access Documents directory"
            return
        }
        
        let screenshotsDirectory = documentsDirectory.appendingPathComponent(currentSettings.saveDirectory)
        let fileUrl = screenshotsDirectory.appendingPathComponent(filename)
        
        do {
            try FileManager.default.removeItem(at: fileUrl)
            fetchScreenshotFiles() // Refresh the list after deletion
            errorMessage = nil
        } catch {
            errorMessage = "Error deleting file: \(error.localizedDescription)"
        }
    }
    
    private func createSaveDirectoryIfNeeded() {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            errorMessage = "Unable to access Documents directory"
            return
        }
        
        let screenshotsDirectory = documentsDirectory.appendingPathComponent(currentSettings.saveDirectory)
        
        do {
            try FileManager.default.createDirectory(at: screenshotsDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            errorMessage = "Error creating directory: \(error.localizedDescription)"
        }
    }
    
    private func showSettings() {
        // In a real app, you'd show a proper settings view.
        // For simplicity, we'll just update the interval here.
        if let settings = settings.first {
            settings.interval += 5 // Increase interval by 5 seconds
            if settings.interval > 60 {
                settings.interval = 10 // Reset to 10 if it goes above 60
            }
            do {
                try modelContext.save()
            } catch {
                errorMessage = "Error saving settings: \(error.localizedDescription)"
            }
        }
    }
    
    private func fetchScreenshotFiles() {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            errorMessage = "Unable to access Documents directory"
            return
        }
        
        let screenshotsDirectory = documentsDirectory.appendingPathComponent(currentSettings.saveDirectory)
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: screenshotsDirectory, includingPropertiesForKeys: nil)
            screenshotFiles = fileURLs.map { $0.lastPathComponent }.sorted(by: >)
        } catch {
            errorMessage = "Error fetching screenshot files: \(error.localizedDescription)"
        }
    }
    
    private func loadImage(filename: String) {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            errorMessage = "Unable to access Documents directory"
            return
        }
        
        let screenshotsDirectory = documentsDirectory.appendingPathComponent(currentSettings.saveDirectory)
        let imageUrl = screenshotsDirectory.appendingPathComponent(filename)
        
        if let image = NSImage(contentsOf: imageUrl) {
            selectedImage = image
            isImagePresented = true
        } else {
            errorMessage = "Error loading image: \(filename)"
        }
    }
}

struct ImageViewer: View {
    @Binding var image: NSImage?
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            if let image = image {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Text("No image selected")
            }
            
            Button("Close") {
                isPresented = false
            }
            .padding()
        }
        .padding()
        .frame(width: 600, height: 400)
    }
}

@Model
final class ScreenshotSettings {
    var interval: Int
    var saveDirectory: String
    
    init(interval: Int, saveDirectory: String) {
        self.interval = interval
        self.saveDirectory = saveDirectory
    }
}
