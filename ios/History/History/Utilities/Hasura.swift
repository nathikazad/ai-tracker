//
//  Hasura.swift
//  History
//
//  Created by Nathik Azad on 4/5/24.
//

import Foundation
import SwiftUI

// Define a function that asynchronously sends a GraphQL query and returns the data.
func fetchGraphQLData(jwtToken: String?, graphqlQuery: String) async throws -> Data {
    // Define the request body using the provided graphqlQuery parameter.
    let requestBody = """
    {
      "query": "\(graphqlQuery)"
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
    if(jwtToken != nil) {
        request.setValue("Bearer \(jwtToken!)", forHTTPHeaderField: "Authorization")
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


class HasuraSocket {
    private var webSocketTask: URLSessionWebSocketTask?
    private var session: URLSession?
    private var currentID = 0
    private var socketReady: Bool = false
    // Tracks callbacks for each subscription ID
    private var subscriptions = [String: (query: String, status: SubscriptionStatus, callback: (String) -> Void)]()
     
    init(didEnterBackgroundNotification: NSNotification.Name, willEnterForegroundNotification: NSNotification.Name) {
        NotificationCenter.default.addObserver(forName: didEnterBackgroundNotification, object: nil, queue: .main) { _ in
                print("App entered background. Pausing socket.")
                self.pause()
            }
            
        NotificationCenter.default.addObserver(forName: willEnterForegroundNotification, object: nil, queue: .main) { _ in
            print("App will enter foreground. Resuming socket.")
            // Ensure the JWT token is still valid or fetch a new one if needed
            self.setup()
        }
    }
     func setup() {
         var token = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpYXQiOjE3MTIzNTM2OTcsImh0dHBzOi8vaGFzdXJhLmlvL2p3dC9jbGFpbXMiOnsieC1oYXN1cmEtZGVmYXVsdC1yb2xlIjoidXNlciIsIngtaGFzdXJhLWFsbG93ZWQtcm9sZXMiOlsidXNlciJdLCJ4LWhhc3VyYS11c2VyLWlkIjoiMSJ9LCJleHAiOjM0MjQ3OTM3OTR9.bPhZj6hLPmpxf_r0Sp43_dD5hTZ8ecYdqu_r_SKHF8Gokn1q8XOQ5VwNkvHBPyVGCpE69nTucz2nl_QlliFb3Bfq7QapYb7BqOHUcdoSH_PtkK5Ec0t78mitiIL6-F7N9Xg6vD8OA6mdvQoh8AHr-hRTLHw6CjlohU92UiiFJbyrJX1czieWnMEW_STkYGbQ98nsrpeajPBvnV4AgIEqMlfSvbRha3zJaVWDlijgUg7Yp1UhnVBELqMY2oIgICg0Swv2MmWsK7ZpYPol1xGSlRu3pokZ1mPshXwK-aKn_4zXar7Kt5inI9z6LIMd6q0-83YuezAPXq9FsmFjRg0wlw"
        let url = URL(string: "wss://ai-tracker-hasura-a1071aad7764.herokuapp.com/v1/graphql")!
        var request = URLRequest(url: url)
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("graphql-ws", forHTTPHeaderField: "Sec-WebSocket-Protocol")
        
        session = URLSession(configuration: .default)
        webSocketTask = session?.webSocketTask(with: request)
        webSocketTask?.resume()
        sendInitializationMessage()
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
    
     func startListening(subscriptionQuery: String, callback: @escaping (String) -> Void) -> String {
         if(!socketReady) {
             setup()
         }
         currentID += 1
         let uniqueID = String(currentID)
         subscriptions[uniqueID] = (query: subscriptionQuery, status: .registered, callback: callback)

         if socketReady {
             sendSubscriptionMessage(uniqueID: uniqueID, subscriptionQuery: subscriptionQuery)
         } else {
             print("Socket not ready, subscription \(uniqueID) registered and will be activated upon connection.")
         }
         return uniqueID
     }

     
     private func sendSubscriptionMessage(uniqueID: String, subscriptionQuery: String) {
         let subscriptionMessage = """
         {
           "type": "start",
           "id": "\(uniqueID)",
           "payload": {
             "query": "\(subscriptionQuery)"
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
                    // Now that idValue is unwrapped, cast it to String for dictionary lookup
                    if let id = idValue as? String {
                        // Check if there's a callback for the id
                        if let callback = subscriptions[id]?.callback {
                            // If a callback exists, proceed to use it
                            callback(text)
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
                socketReady = true;
                print("Received connection_ack message. Activating registered subscriptions.")

                subscriptions.forEach { uniqueID, details in
                    if details.status == .registered {
                        sendSubscriptionMessage(uniqueID: uniqueID, subscriptionQuery: details.query)
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
         socketReady = false;
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
