//
//  File.swift
//  History
//
//  Created by Nathik Azad on 3/19/24.
//

import Foundation

class AudioUploader: ObservableObject {
    let session = URLSession.shared
    
    func uploadAudioFile(at fileUrl: URL, to uploadUrlString: String) throws -> Data? {
        guard let uploadUrl = URL(string: uploadUrlString) else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Invalid upload URL."])
        }
        
        var request = URLRequest(url: uploadUrl)
        request.httpMethod = "POST"
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try createBody(with: fileUrl, boundary: boundary)
            
            var responseData: Data? = nil
            let semaphore = DispatchSemaphore(value: 0)
            
            let task = session.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error: \(error)")
                    semaphore.signal()
                    return
                }
                
                if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                    responseData = data
                } else {
                    print("Failed to upload file.")
                }
                semaphore.signal()
            }
            
            task.resume()
            semaphore.wait()
            
            if responseData == nil {
                throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Failed to upload file."])
            }
            
            return responseData
            
        } catch {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Failed to create request body: \(error)"])
        }
    }
    
    private func createBody(with fileUrl: URL, boundary: String) throws -> Data {
        var data = Data()
        
        let mimeType = "audio/mp4"  // Updated MIME type for .m4a files
        let fieldName = "audioFile"
        let fileName = fileUrl.lastPathComponent
        
        data.append("--\(boundary)\r\n")
        data.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n")
        data.append("Content-Type: \(mimeType)\r\n\r\n")
        
        data.append(try Data(contentsOf: fileUrl))
        data.append("\r\n")
        
        data.append("--\(boundary)--\r\n")
        
        return data
    }
}

// MARK: - Data Extension for Multipart/Form-Data
extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
