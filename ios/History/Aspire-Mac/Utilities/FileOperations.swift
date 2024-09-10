import Foundation
import SwiftUI

class FileOperations {
    static func createSaveDirectoryIfNeeded(in directory: String, dateFolderName: String) -> Result<Void, Error> {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return .failure(NSError(domain: "FileOperations", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to access Documents directory"]))
        }
        
        let screenshotsDirectory = documentsDirectory.appendingPathComponent(directory)
            .appendingPathComponent(dateFolderName)
        
        do {
            try FileManager.default.createDirectory(at: screenshotsDirectory, withIntermediateDirectories: true, attributes: nil)
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    static func fetchScreenshotFiles(in directory: String, for date: Date? = nil) -> Result<[String], Error> {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return .failure(NSError(domain: "FileOperations", code: 2, userInfo: [NSLocalizedDescriptionKey: "Unable to access Documents directory"]))
        }
        
        let screenshotsDirectory = documentsDirectory.appendingPathComponent(directory)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let dateFolderName = date.map { dateFormatter.string(from: $0) } ?? dateFormatter.string(from: Date())
        
        do {
            let dateFolderURL = screenshotsDirectory.appendingPathComponent(dateFolderName)
            
            // Check if the date folder exists
            var isDirectory: ObjCBool = false
            guard FileManager.default.fileExists(atPath: dateFolderURL.path, isDirectory: &isDirectory), isDirectory.boolValue else {
                // If the folder doesn't exist, return an empty array
                return .success([])
            }
            
            let files = try FileManager.default.contentsOfDirectory(at: dateFolderURL, includingPropertiesForKeys: nil)
            let relativePaths = files.map { file -> String in
                let fileName = file.lastPathComponent
                return "\(dateFolderName)/\(fileName)"
            }
            
            return .success(relativePaths.sorted(by: >))
        } catch {
            return .failure(error)
        }
    }
    
    static func deleteImage(filename: String, in directory: String) -> Result<Void, Error> {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return .failure(NSError(domain: "FileOperations", code: 3, userInfo: [NSLocalizedDescriptionKey: "Unable to access Documents directory"]))
        }
        
        let screenshotsDirectory = documentsDirectory.appendingPathComponent(directory)
        let fileUrl = screenshotsDirectory.appendingPathComponent(filename)
        
        do {
            try FileManager.default.removeItem(at: fileUrl)
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    struct ScreenshotInfo {
        let url: URL
        let filename: String
        let dateFolderName: String
        let activeAppName: String
        let path: String
    }

    static func prepareScreenshotPath(saveDirectory: String) -> Result<ScreenshotInfo, Error> {
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
        
        return .success(ScreenshotInfo(url: url, filename: filename, dateFolderName: dateFolderName, activeAppName: activeAppName, path: screenshotsDirectory.path ))
    }
}
