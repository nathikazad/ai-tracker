import Foundation
import SwiftUI
import Cocoa
import ZIPFoundation


class ImageOperations {
    static func takeScreenshot(saveDirectory: String, interval: Int, uploadToCloud: Bool = false) -> Result<String, Error> {
        let pathResult = FileOperations.prepareScreenshotPath(saveDirectory: saveDirectory)
        
        guard case .success(let screenshotInfo) = pathResult else {
            if case .failure(let error) = pathResult {
                return .failure(error)
            }
            return .failure(NSError(domain: "ImageOperations", code: 5, userInfo: [NSLocalizedDescriptionKey: "Failed to prepare screenshot path"]))
        }
        
        if let cgImage = CGDisplayCreateImage(CGMainDisplayID()) {
            let newSize = CGSize(width: 1280, height: 720)
            
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
                    try pngData.write(to: screenshotInfo.url)
                    
//                    let fileSizeBytes = try FileManager.default.attributesOfItem(atPath: screenshotInfo.url.path)[.size] as? Int64 ?? 0
//                    let fileSizeKB = Double(fileSizeBytes) / 1024.0
//                    print("Screenshot saved: \(screenshotInfo.dateFolderName)/\(screenshotInfo.filename)")
//                    print("File size: \(String(format: "%.2f", fileSizeKB)) KB")
//                    print("Active application: \(screenshotInfo.activeAppName)")
//                    print("Saving screenshot to: \(screenshotInfo.url.deletingLastPathComponent().path)")
                    return .success("\(screenshotInfo.dateFolderName)/\(screenshotInfo.filename)")
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
