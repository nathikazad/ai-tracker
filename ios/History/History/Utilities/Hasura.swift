//
//  Hasura.swift
//  History
//
//  Created by Nathik Azad on 4/5/24.
//

import Foundation
import SwiftUI

enum SubscriptionStatus {
    case registered
    case active
}

enum SocketStatus {
    case initialized
    case handshaking
    case ready
}


class Hasura {
    static let shared = Hasura()
    private var webSocketTask: URLSessionWebSocketTask?
    private var session: URLSession?
    private var currentID = 0
    private var socketStatus: SocketStatus = .initialized
    // Tracks callbacks for each subscription ID
    private var subscriptions = [String: (query: String, status: SubscriptionStatus, callback: (Any?) -> Void)]()
    
    struct GraphQLRequest: Codable {
        let query: String
    }

    private func decodeData<T: Decodable>(_ responseType: T.Type, _ data: Data) throws -> T {
        // Decode the data to the specified responseType and return it.
        do {
            let decodedResponse = try JSONDecoder().decode(responseType, from: data)
            return decodedResponse
//        } catch let DecodingError.dataCorrupted(context) {
//            print("Data corrupted: \(context)")
//        } catch let DecodingError.keyNotFound(key, context) {
//            print("Key '\(key)' not found: \(context.debugDescription), codingPath: \(context.codingPath)")
//        } catch let DecodingError.typeMismatch(type, context) {
//            print("Type '\(type)' mismatch: \(context.debugDescription), codingPath: \(context.codingPath)")
//        } catch let DecodingError.valueNotFound(value, context) {
//            print("Value '\(value)' not found: \(context.debugDescription), codingPath: \(context.codingPath)")
        } catch let error {
            // If decoding fails, print the raw data as a string for debugging.
            print("Error decoding data: \(error.localizedDescription)")
            if let rawResponse = String(data: data, encoding: .utf8) {
                print("Failed to decode response: \(rawResponse)")
            } else {
                print("Failed to decode response and could not convert data to string.")
            }
            throw error
        }
    }
    
    func sendGraphQL<T: Decodable>(query: String, responseType: T.Type) async throws -> T {
        let jsonData = try JSONEncoder().encode(["query": query])
        
        let urlString = "https://\(HasuraAddress)/v1/graphql"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let jwt = Authentication.shared.hasuraJwt {
            request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        if let httpResponse = response as? HTTPURLResponse {
//            print("HTTP Status Code: \(httpResponse.statusCode)")
//                    if let responseBody = String(data: data, encoding: .utf8) {
//                        print("Server Response:\n\(responseBody)")
//                    }

            if httpResponse.statusCode != 200, let responseBody = String(data: data, encoding: .utf8) {
                print("Response body: \(responseBody)")
            }
        }
        
        return try decodeData(responseType, data)
    }

    
     func setup() {
         print("setting up hasura socket")
         socketStatus = .handshaking
         Task {
             await Authentication.shared.checkAndReloadHasuraJwt()
             let url = URL(string: "wss://\(HasuraAddress)/v1/graphql")!
             var request = URLRequest(url: url)
             if(Authentication.shared.hasuraJwt == nil) { //sometimes socket tries to connect after logout, this is to catch that edge case, so don't remove
                 return
             }
             let token = Authentication.shared.hasuraJwt!
             request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
             request.addValue("graphql-ws", forHTTPHeaderField: "Sec-WebSocket-Protocol")
             
             session = URLSession(configuration: .default)
             webSocketTask = session?.webSocketTask(with: request)
             webSocketTask?.resume()
             sendInitializationMessage()
         }
        
    }
    
    private func sendInitializationMessage() {
        let initMessage = "{\"type\":\"connection_init\",\"payload\":{}}"
        sendMessage(text: initMessage)
        receiveMessage()
    }
    
    private func sendMessage(text: String) {
        let message = URLSessionWebSocketTask.Message.string(text)
        webSocketTask?.send(message) { error in
            if let error = error {
                print("WebSocket sending error: \(error)")
            }
        }
    }
    
    
    func startListening<T: Decodable>(subscriptionQuery: String, responseType: T.Type, callback: @escaping (Result<T, Error>) -> Void) -> String {
        if(socketStatus == .initialized) {
            print("calling setup because socket not initialized for listening")
            setup()
        }
        
        currentID += 1
        let uniqueID = String(currentID)
        
        // Register the subscription with a callback that correctly handles decoding.
        // Ensure the callback matches the expected signature.
        subscriptions[uniqueID] = (query: subscriptionQuery, status: .registered, callback: { message in
            guard let data = try? JSONSerialization.data(withJSONObject: message, options: []) else {
                callback(.failure(URLError(.cannotParseResponse)))
                return
            }
            
            do {
                let decodedResponse = try self.decodeData(responseType, data)
                callback(.success(decodedResponse))
            } catch {
                callback(.failure(error))
            }
        })
        
        if socketStatus == .ready {
            startSubscription(uniqueID: uniqueID, subscriptionQuery: subscriptionQuery)
        } else {
//            print("Socket not ready, subscription \(uniqueID) registered and will be activated upon connection.")
        }
        
        return uniqueID
    }
    
    struct SubscriptionMessage: Codable {
        let type: String
        let id: String
        let payload: GraphQLRequestPayload
    }

    struct GraphQLRequestPayload: Codable {
        let query: String
    }
     
    private func startSubscription(uniqueID: String, subscriptionQuery: String) {
        let queryPayload = GraphQLRequestPayload(query: subscriptionQuery.replacingOccurrences(of: "\n", with: " "))
        
        let subscriptionMessage = SubscriptionMessage(type: "start", id: uniqueID, payload: queryPayload)
        
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .withoutEscapingSlashes // Helps keep the query clean, but use if necessary
            let jsonData = try encoder.encode(subscriptionMessage)
            guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                print("Failed to encode subscription message to JSON string.")
                return
            }
            sendMessage(text: jsonString)
            subscriptions[uniqueID]?.status = .active
//            print("Subscription message sent for \(uniqueID), status updated to active.")
        } catch {
            print("Error encoding subscription message: \(error)")
        }
    }


    
     func stopListening(uniqueID: String) {
         guard subscriptions[uniqueID] != nil else {
             print("Subscription ID \(uniqueID) not found.")
             return
         }
         
         let stopMessage = """
         {
           "type": "stop",
           "id": "\(uniqueID)"
         }
         """
         sendMessage(text: stopMessage)
         subscriptions.removeValue(forKey: uniqueID)
     }


    
    private func receiveMessage() {
        webSocketTask?.receive { result in
            switch result {
            case .failure(let error):
                print("Error in receiving message: \(error)")
            case .success(let message):
                if case .string(let text) = message {
                    self.handleMessage(text: text)
                }
                self.receiveMessage()
            }
            
            
        }
    }
    
    private func handleMessage(text: String) {
        guard let data = text.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            print("Failed to parse message as JSON: \(text)")
            return
        }

        // Handle different types of messages
        if let type = json["type"] as? String {
            switch type {
            case "data":
                // Handle data messages
                if let idValue = json["id"] {
//                    print("Received subscription id \(idValue)")
                    if let id = idValue as? String {
                        if let callback = subscriptions[id]?.callback {
                            callback(json["payload"]) // Pass the 'data' to the callback
                        } else {
                            stopListening(uniqueID: id)
                            print("Data message does not match any subscription ID or no callback found: \(text)")
                        }
                    } else {
                        print("ID value is not a string: \(idValue)")
                    }
                } else {
                    print("No ID found in the message.")
                }
            case "ka":
                // Handle keep-alive messages; simply ignore or log as needed
//                print("Received keep-alive message.")
                break
            case "connection_ack":
                // Handle keep-alive messages; simply ignore or log as needed
                socketStatus = .ready;
//                print("Received connection_ack message. Activating registered subscriptions.")

                subscriptions.forEach { uniqueID, details in
                    if details.status == .registered {
                        startSubscription(uniqueID: uniqueID, subscriptionQuery: details.query)
                    }
                }
//                print("Received connection_ack message.")
            default:
                print("Received unhandled message type: \(type)")
            }
        } else {
            print("Received message without a type: \(text)")
        }
    }

     func pause() {
         print("pausing subscriptions")
         subscriptions.keys.forEach { id in
             subscriptions[id]?.status = .registered
         }
         socketStatus = .initialized
         closeConnection()
     }

    func closeConnection() {
        let reason = "Closing connection".data(using: .utf8)
        socketStatus = .initialized
        webSocketTask?.cancel(with: .goingAway, reason: reason)
        webSocketTask = nil
        session = nil
        currentID = 0 // Reset the ID when the connection is closed
    }
}

class HasuraUtil {
    static func dateToUTCString(date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // Set formatter timezone to UTC
        return formatter.string(from: date)
    }
    
    static func justDate(timestamp: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        // Attempt to parse the ISO 8601 date string into a Date object
        guard let date = isoFormatter.date(from: timestamp) else {
            return "Invalid Date"
        }
        
        // Create a DateFormatter to output just the date part
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current // Convert to the local time zone or specify if needed (e.g., PST)
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        // Return the formatted date string adjusted to the local time zone
        return dateFormatter.string(from: date)
    }
    
    static func formattedTime(timestamp: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds] // Ensure fractional seconds are parsed
        if let date = isoFormatter.date(from: timestamp) {
            let localFormatter = DateFormatter()
            localFormatter.timeZone = TimeZone.current // Convert to local time zone
            localFormatter.dateFormat = "hh:mm a" // Specify your desired format
            
            return localFormatter.string(from: date)
        }
        return "Invalid Time" // Return a default or error message if parsing fails
    }
    
}
