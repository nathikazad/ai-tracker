//
//  File.swift
//  History
//
//  Created by Nathik Azad on 3/19/24.
//

import Foundation

class ServerCommunicator: ObservableObject {
    static func uploadAudioFile(at fileUrl: URL, to uploadUrlString: String, token: String? = nil) throws -> Data? {
        guard let uploadUrl = URL(string: uploadUrlString) else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Invalid upload URL."])
        }
        
        var request = URLRequest(url: uploadUrl)
        request.httpMethod = "POST"
        
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
            
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try createBodyForAudiofile(with: fileUrl, boundary: boundary)
            
            var responseData: Data? = nil
            let semaphore = DispatchSemaphore(value: 0)
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
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
    
    static private func createBodyForAudiofile(with fileUrl: URL, boundary: String) throws -> Data {
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
    
    static func sendPostRequest(to uploadUrlString: String, body: [String: Any]? = [:], token: String?) async throws -> Data? {
        guard let uploadUrl = URL(string: uploadUrlString) else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Invalid upload URL."])
        }
        
        var request = URLRequest(url: uploadUrl)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                return data
            } else {
                print("Invalid response received from the server")
                return nil
            }

        } catch {
            print("Error sending apple key to server or parsing server response: \(error.localizedDescription)")
            return nil
        }
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