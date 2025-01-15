//
//  websocket.swift
//  device-tester
//
//  Created by Nathik Azad on 1/14/25.
//

import Foundation
import SwiftUI

class WebSocketManager: ObservableObject {
    private var webSocket: URLSessionWebSocketTask?
    @Published var messages: [String] = []
    @Published var connectionStatus: ConnectionStatus = .disconnected
    let clientId = UUID().uuidString
    
    enum ConnectionStatus {
        case connected
        case disconnected
        case connecting
        
        var description: String {
            switch self {
            case .connected: return "Connected"
            case .disconnected: return "Disconnected"
            case .connecting: return "Connecting..."
            }
        }
    }
    func connect() {
        // Use wss:// for secure WebSocket connection
        guard let url = URL(string: "wss://ai-tracker-server-613e3dd103bb.herokuapp.com") else { return }
        
        connectionStatus = .connecting
        
        let session = URLSession(configuration: .default)
        webSocket = session.webSocketTask(with: url)
        
        // Set up automatic reconnection
        webSocket?.maximumMessageSize = 1024 * 1024 // 1MB limit
        
        webSocket?.resume()
        
        // Send connect message
        let connectMessage: [String: Any] = [
            "type": "connect",
            "connectionType": "client",
            "clientId": clientId
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: connectMessage),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            send(message: jsonString)
        }
        
        receiveMessage()
        
        DispatchQueue.main.async {
            self.connectionStatus = .connected
        }
    }
    
    func disconnect() {
        webSocket?.cancel(with: .normalClosure, reason: nil)
        connectionStatus = .disconnected
    }
    
    private func receiveMessage() {
        webSocket?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    DispatchQueue.main.async {
                        self?.messages.append(text)
                        print("Received message: \(text)")
                    }
                case .data(let data):
                    if let text = String(data: data, encoding: .utf8) {
                        DispatchQueue.main.async {
                            self?.messages.append(text)
                            print("Received message: \(text)")
                        }
                    }
                @unknown default:
                    break
                }
                // Continue receiving messages
                self?.receiveMessage()
                
            case .failure(let error):
                print("WebSocket receive error: \(error)")
                DispatchQueue.main.async {
                    self?.connectionStatus = .disconnected
                }
                // Attempt to reconnect after a delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self?.connect()
                }
            }
        }
    }
    
    func send(message: String) {
        webSocket?.send(.string(message)) { error in
            if let error = error {
                print("WebSocket send error: \(error)")
                DispatchQueue.main.async { [weak self] in
                    self?.connectionStatus = .disconnected
                }
            }
        }
    }
}

struct WebSocketView: View {
    @StateObject private var wsManager = WebSocketManager()
    @State private var messageText = ""
    
    var body: some View {
        VStack {
            // Connection status
            Text(wsManager.connectionStatus.description)
                .foregroundColor(wsManager.connectionStatus == .connected ? .green : .red)
                .padding()
            
            ScrollView {
                LazyVStack(alignment: .leading) {
                    ForEach(wsManager.messages, id: \.self) { message in
                        Text(message)
                            .padding(8)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                .padding()
            }
            
            HStack {
                TextField("Message", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(wsManager.connectionStatus != .connected)
                
                Button("Send") {
                    if !messageText.isEmpty {
                        let message: [String: Any] = [
                            "type": "message",
                            "content": messageText
                        ]
                        
                        if let jsonData = try? JSONSerialization.data(withJSONObject: message),
                           let jsonString = String(data: jsonData, encoding: .utf8) {
                            wsManager.send(message: jsonString)
                            messageText = ""
                        }
                    }
                }
                .disabled(wsManager.connectionStatus != .connected)
            }
            .padding()
        }
        .onAppear {
            wsManager.connect()
        }
        .onDisappear {
            wsManager.disconnect()
        }
    }
}
