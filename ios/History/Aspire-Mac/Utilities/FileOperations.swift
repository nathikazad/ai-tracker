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
}
