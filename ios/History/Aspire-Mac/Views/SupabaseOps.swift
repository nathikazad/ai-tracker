//
//  SupabaseOps.swift
//  Aspire-Mac
//
//  Created by Nathik Azad on 9/9/24.
//

import Foundation
import Storage

#if os(iOS)
import UIKit
typealias PlatformImage = UIImage
#elseif os(macOS)
import AppKit
typealias PlatformImage = NSImage
#endif



class Supabase {
    
    static private let batchSize = 200
    
    struct ConsoleLogger: SupabaseLogger {
        func log(message: SupabaseLogMessage) {
            print(message.description)
        }
    }
    
    static var client: SupabaseStorageClient {
        let config = StorageClientConfiguration(
            url: URL(string: supabaseUrl)!.appendingPathComponent("storage/v1"),
            headers: [
                "apikey": supabaseKey,
                "Authorization": "Bearer \(supabaseKey)"
            ],
            logger: ConsoleLogger()
        )
        return SupabaseStorageClient(configuration: config)
    }
    
    
    
    static func uploadFile(data: Data, path: String, bucketName: String) {
        let fileApi = client.from(bucketName)
        let options = FileOptions(contentType: "image/jpeg", upsert: true)
        let userId = Authentication.shared.userId ?? 0
        Task {
            do {
                let path = try await fileApi.upload(path: "\(userId)/\(path)", file: data, options: options)
                print("Uploaded to \(path)")
            } catch {
                print("Supabase Upload Error")
            }
        }
        
    }
    static func downloadZipFile(path: String, bucketName: String) async throws -> URL {
        let fileApi = client.from(bucketName)
        let userId = Authentication.shared.userId ?? 0
        let fullPath = "\(userId)/\(path)"
        let zipData = try await fileApi.download(path: fullPath)
        
        // Create a temporary URL for the zip file
        let tempZipURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".zip")
        try zipData.write(to: tempZipURL)
        
        return tempZipURL
    }
    
    static func zipAndUploadImages(folderPath: String, bucketName: String) {
        let fileManager = FileManager.default
        let folderURL = URL(fileURLWithPath: folderPath)
        let folderName = folderURL.lastPathComponent
        let zipURL = fileManager.temporaryDirectory.appendingPathComponent("\(folderName).zip")
        do {
            try fileManager.zipItem(at: folderURL, to: zipURL)
            let zipData = try Data(contentsOf: zipURL)
            Supabase.uploadFile(data: zipData, path: "\(folderName).zip", bucketName: bucketName)
            try? fileManager.removeItem(at: zipURL)
        } catch {
            try? fileManager.removeItem(at: zipURL)
        }
    }
     
    static func downloadAndUnzipImages(dateFolderName: String, bucketName: String, saveDirectory: String) async throws -> [PlatformImage] {
        let fileManager = FileManager.default
        
        // Extract the date from the path
        
        // Construct the path to the screenshots directory
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw NSError(domain: "ImageOperations", code: 2, userInfo: [NSLocalizedDescriptionKey: "Unable to access Documents directory"])
        }
        
        let screenshotsDirectory = documentsDirectory
            .appendingPathComponent(saveDirectory)
        
        // Ensure the directory exists
        try fileManager.createDirectory(at: screenshotsDirectory, withIntermediateDirectories: true, attributes: nil)
        
        var images: [PlatformImage] = []
        let userId = Authentication.shared.userId ?? 0
        let path = "\(dateFolderName).zip"
        do {
            let zipURL = try await Supabase.downloadZipFile(path: path, bucketName: bucketName)
            
            // Unzip directly to the screenshots directory
            try fileManager.unzipItem(at: zipURL, to: screenshotsDirectory)
            
            // Process unzipped files
            let fileURLs = try fileManager.contentsOfDirectory(at: screenshotsDirectory, includingPropertiesForKeys: nil)
            for fileURL in fileURLs {
                if let image = PlatformImage(contentsOfFile: fileURL.path) {
                    images.append(image)
                }
                // If the file is not an image, it's gracefully skipped
            }
            
            // Clean up the downloaded zip file
            try? fileManager.removeItem(at: zipURL)
            
            print("Unzipped images to: \(screenshotsDirectory.path)")
        } catch {
            print("Download or unzip error: \(error)")
            throw error
        }
        
        return images
    }
 }

//downloader.downloadAllImages(fromFolder: "your_folder_name",
//    progress: { downloadedCount in
//        print("Downloaded \(downloadedCount) images so far")
//    },
//    completion: { result in
//        switch result {
//        case .success(let images):
//            print("Successfully downloaded all \(images.count) images")
//            // Do something with the images
//        case .failure(let error):
//            print("Error downloading images: \(error)")
//        }
//    }
//)
