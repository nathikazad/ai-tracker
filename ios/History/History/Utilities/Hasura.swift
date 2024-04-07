//
//  Hasura.swift
//  History
//
//  Created by Nathik Azad on 4/5/24.
//

import Foundation
import SwiftUI

// Define a function that asynchronously sends a GraphQL query and returns the data.
func fetchGraphQLData(graphqlQuery: String) async throws -> Data {
    // Define the request body using the provided graphqlQuery parameter.
    let requestBody = """
    {
      "query": "\(graphqlQuery.replacingOccurrences(of: "\n", with: ""))"
    }
    """
    guard let jsonData = requestBody.data(using: .utf8) else {
        throw URLError(.badURL)
    }
    
    // Specify the URL of your GraphQL server.
    let urlString = "https://ai-tracker-hasura-a1071aad7764.herokuapp.com/v1/graphql"
    guard let url = URL(string: urlString) else {
        throw URLError(.badURL)
    }
    
    // Create a URLRequest and specify it's a POST request.
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    if(Authentication.shared.hasuraJwt != nil) {
        request.setValue("Bearer \(Authentication.shared.hasuraJwt!)", forHTTPHeaderField: "Authorization")
    }
    request.httpBody = jsonData
    
    // Perform the network request asynchronously.
    let (data, response) = try await URLSession.shared.data(for: request)
    
    // Check the response status code.
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
        throw URLError(.badServerResponse)
    }
    
    // Return the data for further processing or usage.
    return data
}


enum SubscriptionStatus {
    case registered
    case active
}

enum SocketStatus {
    case initialized
    case handshaking
    case ready
}


class HasuraSocket {
    static let shared = HasuraSocket()
    private var webSocketTask: URLSessionWebSocketTask?
    private var session: URLSession?
    private var currentID = 0
    private var socketStatus: SocketStatus = .initialized
    // Tracks callbacks for each subscription ID
    private var subscriptions = [String: (query: String, status: SubscriptionStatus, callback: (Any?) -> Void)]()
     
    func setBackgroundNotifiers(didEnterBackgroundNotification: NSNotification.Name, willEnterForegroundNotification: NSNotification.Name) {
        NotificationCenter.default.addObserver(forName: didEnterBackgroundNotification, object: nil, queue: .main) { _ in
                print("App entered background. Pausing socket.")
                self.pause()
            }
            
        NotificationCenter.default.addObserver(forName: willEnterForegroundNotification, object: nil, queue: .main) { _ in
            print("App will enter foreground. Resuming socket.")
            if(Authentication.shared.isSignedIn()) {
                self.setup()
            }
        }
    }
     func setup() {
         socketStatus = .handshaking
         Task {
             await Authentication.shared.checkAndReloadHasuraJwt()
             let url = URL(string: "wss://ai-tracker-hasura-a1071aad7764.herokuapp.com/v1/graphql")!
             var request = URLRequest(url: url)
             
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
    
     func startListening(subscriptionQuery: String, callback: @escaping (Any?) -> Void) -> String {
         if(socketStatus == .initialized) {
             setup()
         }
         currentID += 1
         let uniqueID = String(currentID)
         subscriptions[uniqueID] = (query: subscriptionQuery, status: .registered, callback: callback)

         if socketStatus == .ready {
             startSubscription(uniqueID: uniqueID, subscriptionQuery: subscriptionQuery)
         } else {
             print("Socket not ready, subscription \(uniqueID) registered and will be activated upon connection.")
         }
         return uniqueID
     }

     
     private func startSubscription(uniqueID: String, subscriptionQuery: String) {
         let subscriptionMessage = """
         {
           "type": "start",
           "id": "\(uniqueID)",
           "payload": {
             "query": "\(subscriptionQuery.replacingOccurrences(of: "\n", with: ""))"
           }
         }
         """
         sendMessage(text: subscriptionMessage)
         subscriptions[uniqueID]?.status = .active
         print("Subscription message sent for \(uniqueID), status updated to active.")
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
            }
            
            self.receiveMessage()
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
                    print("Received subscription id \(idValue)")
                    if let id = idValue as? String {
                        if let callback = subscriptions[id]?.callback {
                            callback(json["payload"]) // Pass the 'data' to the callback
                        } else {
                            // No callback found for the unwrapped and correctly typed id
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
                print("Received connection_ack message. Activating registered subscriptions.")

                subscriptions.forEach { uniqueID, details in
                    if details.status == .registered {
                        startSubscription(uniqueID: uniqueID, subscriptionQuery: details.query)
                    }
                }
                print("Received connection_ack message.")
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
        webSocketTask?.cancel(with: .goingAway, reason: reason)
        webSocketTask = nil
        session = nil
        currentID = 0 // Reset the ID when the connection is closed
    }
}



//func hasura(jwtToken: String) {
//
//    // Define your GraphQL query as a string.
//    let graphqlQuery = """
//    {
//      "query": "query MyQuery { interactions(where: {user_id: {_eq: 1}}, limit: 10) { id timestamp } }"
//    }
//    """
//    guard let jsonData = graphqlQuery.data(using: .utf8) else { return }
//    // Specify the URL of your GraphQL server.
//    let urlString = "https://ai-tracker-hasura-a1071aad7764.herokuapp.com/v1/graphql"
//    guard let url = URL(string: urlString) else { return }
//
//    // Create a URLRequest for the URL and specify it's a POST request.
//    var request = URLRequest(url: url)
//    request.httpMethod = "POST"
//
//    // Add necessary headers.
//    // Content-Type header specifies the media type of the resource.
//    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//    // Authorization header with Bearer token.
//    // Replace YOUR_TOKEN with your actual token.
//    request.setValue("Bearer \(jwtToken)", forHTTPHeaderField: "Authorization")
//
//    // Convert your GraphQL query to Data and set it as the HTTP body.
//    request.httpBody = jsonData
//
//    // Create a URLSessionDataTask to send the request.
//    let task = URLSession.shared.dataTask(with: request) { data, response, error in
//        if let error = error {
//            print("Error: \(error.localizedDescription)")
//            return
//        }
//
//        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data else {
//            print("Error: Invalid response or data")
//            return
//        }
//        
//        print(data)
//
//        do {
//            let jsonResult = try JSONSerialization.jsonObject(with: data, options: [])
//            print("Response: \(jsonResult)")
//        } catch {
//            print("Error: Parsing JSON data failed")
//        }
//    }
//
//    // Start the network task.
//    task.resume()
//
//}
