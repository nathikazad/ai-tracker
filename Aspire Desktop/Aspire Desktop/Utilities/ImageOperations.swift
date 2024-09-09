import Foundation
import SwiftUI
import Cocoa

class ImageOperations {
    static func takeScreenshot(saveDirectory: String, interval: Int) -> Result<String, Error> {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let dateFolderName = dateFormatter.string(from: Date())
        
        dateFormatter.dateFormat = "HHmmss"
        let timeString = dateFormatter.string(from: Date())
        
        // Get the name of the current active application
        let activeAppName = NSWorkspace.shared.frontmostApplication?.localizedName ?? "Unknown"
        let sanitizedAppName = activeAppName.replacingOccurrences(of: " ", with: "_")
                                            .replacingOccurrences(of: "/", with: "_")
                                            .replacingOccurrences(of: ":", with: "_")
        
        let filename = "\(timeString)_\(sanitizedAppName).png"
        
        // Ensure the save directory exists
        let directoryResult = FileOperations.createSaveDirectoryIfNeeded(in: saveDirectory, dateFolderName: dateFolderName)
        if case .failure(let error) = directoryResult {
            return .failure(error)
        }
        
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return .failure(NSError(domain: "ImageOperations", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to access Documents directory"]))
        }
        
        let screenshotsDirectory = documentsDirectory.appendingPathComponent(saveDirectory)
                                                     .appendingPathComponent(dateFolderName)
        let url = screenshotsDirectory.appendingPathComponent(filename)
        
        if let cgImage = CGDisplayCreateImage(CGMainDisplayID()) {
            let newSize = CGSize(width: 320, height: 180)
            
            let colorSpace = CGColorSpaceCreateDeviceGray()
            guard let context = CGContext(data: nil,
                                          width: Int(newSize.width),
                                          height: Int(newSize.height),
                                          bitsPerComponent: 8,
                                          bytesPerRow: 0,
                                          space: colorSpace,
                                          bitmapInfo: CGImageAlphaInfo.none.rawValue) else {
                return .failure(NSError(domain: "ImageOperations", code: 2, userInfo: [NSLocalizedDescriptionKey: "Unable to create graphics context"]))
            }
            
            context.interpolationQuality = .high
            context.draw(cgImage, in: CGRect(origin: .zero, size: newSize))
            
            guard let resizedImage = context.makeImage() else {
                return .failure(NSError(domain: "ImageOperations", code: 3, userInfo: [NSLocalizedDescriptionKey: "Unable to create resized image"]))
            }
            
            let bitmapRep = NSBitmapImageRep(cgImage: resizedImage)
            
            if let pngData = bitmapRep.representation(using: .png, properties: [.compressionFactor: 0.7]) {
                do {
                    try pngData.write(to: url)
                    
                    let fileSizeBytes = try FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int64 ?? 0
                    let fileSizeKB = Double(fileSizeBytes) / 1024.0
                    print("Screenshot saved: \(dateFolderName)/\(filename)")
                    print("File size: \(String(format: "%.2f", fileSizeKB)) KB")
                    print("Active application: \(activeAppName)")
                    
                    return .success("\(dateFolderName)/\(filename)")
                } catch {
                    return .failure(error)
                }
            }
        }
        
        return .failure(NSError(domain: "ImageOperations", code: 4, userInfo: [NSLocalizedDescriptionKey: "Failed to create screenshot"]))
    }
    
    static func loadImage(filename: String, in directory: String) -> Result<NSImage, Error> {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return .failure(NSError(domain: "ImageOperations", code: 5, userInfo: [NSLocalizedDescriptionKey: "Unable to access Documents directory"]))
        }
        
        let screenshotsDirectory = documentsDirectory.appendingPathComponent(directory)
        let imageUrl = screenshotsDirectory.appendingPathComponent(filename)
        
        if let image = NSImage(contentsOf: imageUrl) {
            return .success(image)
        } else {
            return .failure(NSError(domain: "ImageOperations", code: 6, userInfo: [NSLocalizedDescriptionKey: "Error loading image: \(filename)"]))
        }
    }
}
