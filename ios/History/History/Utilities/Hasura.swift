//
//  Hasura.swift
//  History
//
//  Created by Nathik Azad on 4/5/24.
//

import Foundation
import SwiftUI

protocol GraphQLData: Decodable {}

struct GraphQLResponse<T: GraphQLData>: Decodable {
    var data: T
}

func encodeToDictionary<T: Codable>(_ input: T) throws -> [String: Any] {
    let encoder = JSONEncoder()
    
    let jsonData = try encoder.encode(input)
    guard let jsonDictionary = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [String: Any] else {
        throw NSError(domain: "JSONErrorDomain", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Failed to cast JSON to Dictionary"])
    }
    return jsonDictionary
}

protocol JSONRepresentable: Codable {
    func toJson() throws -> [String: Any]
}

// Provide a default implementation of the protocol
extension JSONRepresentable {
    func toJson() throws -> [String: Any] {
        let encoder = JSONEncoder()
        let jsonData = try encoder.encode(self)
        
        guard let jsonDictionary = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [String: Any] else {
            throw NSError(domain: "JSONErrorDomain", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Failed to cast JSON to Dictionary"])
        }
        
        return jsonDictionary
    }
}

enum ParameterType: String {
    case int = "Int"
    case string = "String"
    case bool = "Boolean"
    case float = "Float"
    case double = "Float8"
    case timestamp = "timestamptz"
    case jsonb = "jsonb"
    case intArray = " [Int!]"
    
    var graphQLType: String {
        return self.rawValue
    }
}

enum HasuraComparisonOperator: String {
    case equals = "_eq"
    case notEquals = "_neq"
    case greaterThan = "_gt"
    case greaterThanOrEquals = "_gte"
    case lessThan = "_lt"
    case lessThanOrEquals = "_lte"
    case inArray = "_in"
    case notIn = "_nin"
    case like = "_like"
    case notLike = "_nlike"
    case ilike = "_ilike"
    case notIlike = "_nilike"
    // Add more operators as needed
}

struct HasuraQuery {
    enum QueryType: String {
        case query; case subscription
    }
    
    var queryFor:String
    var queryName:String
    var queryType:QueryType
    
    private var whereClauses: [String] = []
    private var variables: [String: Any] = [:]
    private var parameterClauses: [String] = []
    private var selections: String = ""
    
    public init(queryFor: String, queryName: String, queryType: QueryType) {
        self.queryType = queryType
        self.queryName = queryName
        self.queryFor = queryFor
    }
    
    mutating func addWhereClause(name: String, type: ParameterType, value: Any?, op: HasuraComparisonOperator) {
        if let value = value {
            parameterClauses.append("$\(name): \(type.graphQLType)!")
            whereClauses.append("\(name): {\(op.rawValue): $\(name)}")
            variables[name] = value
        }
    }

    mutating func addWhereClause(clause: String) {
        whereClauses.append(clause)
    }
    
    mutating func addParameter(name: String, type: ParameterType, value: Any?) {
        if let value = value {
            parameterClauses.append("$\(name): \(type.graphQLType)!")
            variables[name] = value
        }
    }
    
    mutating func setSelections(selections:String) {
        self.selections = selections
    }
    
    var getQueryAndVariables: (String, [String: Any]) {
        let whereClause = whereClauses.isEmpty ? "" : "(where: {\(whereClauses.joined(separator: ", "))})"
        let parameterClause = parameterClauses.isEmpty ? "" : "(\(parameterClauses.joined(separator: ", ")))"
        let query = """
        \(queryType.rawValue) \(queryName)\(parameterClause) {
          \(queryFor)\(whereClause) {
            \(selections)
            }
        }
        """
        return (query, variables)
    }
}

struct HasuraMutation {
    enum MutationType: String {
        case create; case update; case delete;
    }
    
    var mutationName: String
    var mutationType: MutationType
    var mutationFor: String
    
    private var parameterClauses: [String] = []
    private var setClauses: [String] = []
    private var appendClauses: [String] = []
    private var objectClauses: [String] = []
    private var variables: [String: Any] = [:]
    private var id: Int?
    
    public init(mutationFor: String, mutationName: String, mutationType: MutationType, id: Int? = nil) {
        self.mutationType = mutationType
        self.mutationName = mutationName
        self.mutationFor = mutationFor
        if mutationType == .update || mutationType == .delete {
            parameterClauses.append("$id: Int!")
            variables["id"] = id!
        }
        
    }
    
    mutating func addParameter(name: String, type: ParameterType, value: Any?, passNullValue: Bool = false) {
        if let value = value {
            parameterClauses.append("$\(name): \(type.graphQLType)!")
            if mutationType == .update {
                if type == .jsonb {
                    appendClauses.append("\(name): $\(name)")
                } else {
                    setClauses.append("\(name): $\(name)")
                }
            } else {
                objectClauses.append("\(name): $\(name)")
            }
            variables[name] = value
        } else if passNullValue {
            setClauses.append("\(name): null")
        }
    }
    
    var getMutationAndVariables: (String, [String: Any]) {
        let pkClause = mutationType == .update ? "pk_columns: {id: $id}" : ""
        let setClause = setClauses.isEmpty ? "" : "_set: {\(setClauses.joined(separator: ", "))}"
        let appendClause = appendClauses.isEmpty ? "" : "_append: {\(appendClauses.joined(separator: ", "))}"
        let objectClause = objectClauses.isEmpty ? "" : "object: {\(objectClauses.joined(separator: ", "))}"
        let parameterClause = parameterClauses.isEmpty ? "" : "(\(parameterClauses.joined(separator: ", ")))"
        var finalSetClause = mutationType == .update ? "\(pkClause), \(setClause), \(appendClause)" : objectClause
        finalSetClause = mutationType == .delete ? "id: $id" : finalSetClause
        let mutation = """
        mutation \(mutationName)\(parameterClause) {
          \(mutationFor)(\(finalSetClause)) {
            id
          }
        }
        """
        return (mutation, variables)
    }
    
}

var hasura: Hasura {
    return Hasura.shared
}

class Hasura {
    enum SubscriptionStatus {
        case registered
        case active
    }
    
    enum SocketStatus {
        case initialized
        case handshaking
        case ready
    }
    static let shared = Hasura()
    private var webSocketTask: URLSessionWebSocketTask?
    private var session: URLSession?
    private var currentID = 0
    private var socketStatus: SocketStatus = .initialized
    // Tracks callbacks for each subscription ID
    private var subscriptions = [String: (query: String, status: SubscriptionStatus, callback: (Any?) -> Void, variables: [String: Any]?)]()
    
    private func doesSubscriptionExist(key: String) -> Bool {
        return subscriptions[key] != nil
    }
    
    struct GraphQLRequest: Codable {
        let query: String
    }
    
    private func decodeData<T: Decodable>(_ responseType: T.Type, _ data: Data, debug: Bool = false) throws -> T {
        // Decode the data to the specified responseType and return it.
        do {
            let decodedResponse = try JSONDecoder().decode(responseType, from: data)
            if debug {
                guard let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                    throw URLError(.cannotParseResponse)
                }
                print(jsonResult)
            }
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
    
    func sendGraphQL(query: String, variables: [String: Any]? = nil) async throws -> [String: Any] {
        let data = try await sendGraphQLRequest(query: query, variables: variables)
        guard let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            throw URLError(.cannotParseResponse)
        }
        return jsonResult
    }
    
    func sendGraphQL<T: Decodable>(query: String, variables: [String: Any]? = nil, responseType: T.Type, debug: Bool = false) async throws -> T {
        let data = try await sendGraphQLRequest(query: query, variables: variables)
        if debug {
            guard let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                throw URLError(.cannotParseResponse)
            }
            print(jsonResult)
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    private func sendGraphQLRequest(query: String, variables: [String: Any]? = nil) async throws -> Data {
        var body: [String: Any] = ["query": query]
        if let vars = variables {
            body["variables"] = vars
        }
        let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
        let urlString = "https://\(HasuraAddress)/v1/graphql"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let jwt = auth.hasuraJwt {
            request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode != 200,
               let responseBody = String(data: data, encoding: .utf8) {
                print("Response body: \(responseBody)")
            }
            throw URLError(.badServerResponse)
        }
        
        return data
    }
    
    
    func setup() {
        print("setting up hasura socket")
        socketStatus = .handshaking
        Task {
            await auth.checkAndReloadHasuraJwt()
            let url = URL(string: "wss://\(HasuraAddress)/v1/graphql")!
            var request = URLRequest(url: url)
            if(auth.hasuraJwt == nil) { //sometimes socket tries to connect after logout, this is to catch that edge case, so don't remove
                return
            }
            let token = auth.hasuraJwt!
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
    
    
    func startListening<T: Decodable>(subscriptionId: String, subscriptionQuery: String, responseType: T.Type, variables: [String: Any]? = nil, callback: @escaping (Result<T, Error>) -> Void, debug: Bool = false) {
        if(socketStatus == .initialized) {
            print("calling setup because socket not initialized for listening")
            setup()
        }
        
        print("Hasura start listening id:\(subscriptionId) \(doesSubscriptionExist(key: subscriptionId))")
        
        if(subscriptions[subscriptionId] != nil) {
            print("Hasura subscription already listening")
            return
        }
        
        
        // Register the subscription with a callback that correctly handles decoding.
        // Ensure the callback matches the expected signature.
        subscriptions[subscriptionId] = (query: subscriptionQuery, status: .registered, variables: variables,  callback: { message in
            guard let data = try? JSONSerialization.data(withJSONObject: message, options: []) else {
                callback(.failure(URLError(.cannotParseResponse)))
                return
            }
            
            do {
                let decodedResponse = try self.decodeData(responseType, data, debug: debug)
                callback(.success(decodedResponse))
            } catch {
                callback(.failure(error))
            }
        })
        if socketStatus == .ready {
            startSubscription(subscriptionId: subscriptionId)
        } else {
            print("Socket not ready, subscription \(subscriptionId) registered and will be activated upon connection.")
        }
    }
    
    struct SubscriptionMessage {
        let type: String
        let id: String
        let payload: GraphQLRequestPayload
    }
    
    struct GraphQLRequestPayload {
        let query: String
        let variables: [String: Any]?
    }
    
    private func startSubscription(subscriptionId: String) {
        print("Hasura: startSubscription: for id \(subscriptionId) \(doesSubscriptionExist(key: subscriptionId))")
        guard let subscription = subscriptions[subscriptionId] else {
            return
        }
        let subscriptionQuery = subscription.query
        // Example setup for variables; adjust based on actual data and needs
        let variables: [String: Any]? = subscription.variables
        
        let queryPayload = GraphQLRequestPayload(query: subscriptionQuery.replacingOccurrences(of: "\n", with: " "), variables: variables)
        
        let subscriptionMessage = SubscriptionMessage(type: "start", id: subscriptionId, payload: queryPayload)
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: ["type": subscriptionMessage.type, "id": subscriptionMessage.id, "payload": ["query": queryPayload.query, "variables": queryPayload.variables]], options: [])
            guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                print("Failed to encode subscription message to JSON string.")
                return
            }
            sendMessage(text: jsonString)
            subscriptions[subscriptionId]?.status = .active
        } catch {
            print("Error encoding subscription message: \(error)")
        }
    }
    
    
    func stopListening(subscriptionId: String) {
        print("Hasura stop listening id:\(subscriptionId) \(doesSubscriptionExist(key: subscriptionId))")
        guard subscriptions[subscriptionId] != nil else {
            print("Subscription ID \(subscriptionId) not found.")
            return
        }
        
        let stopMessage = """
         {
           "type": "stop",
           "id": "\(subscriptionId)"
         }
         """
        sendMessage(text: stopMessage)
        subscriptions.removeValue(forKey: subscriptionId)
    }
    
    
    
    private func receiveMessage() {
        webSocketTask?.receive { result in
            switch result {
            case .failure(let error):
                print("Error in receiving message: \(error)")
                self.setup()
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
                if let subscriptionIdAsAny = json["id"] {
                    if let subscriptionId = subscriptionIdAsAny as? String {
                        print("Received subscription message id \(subscriptionIdAsAny) \(doesSubscriptionExist(key: subscriptionId))")
                        if let callback = subscriptions[subscriptionId]?.callback {
                            callback(json["payload"]) // Pass the 'data' to the callback
                        } else {
                            stopListening(subscriptionId: subscriptionId)
                            print("Data message does not match any subscription ID or no callback found for subscription: \(subscriptionId)")
                        }
                    } else {
                        print("ID value is not a string: \(subscriptionIdAsAny)")
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
                
                subscriptions.forEach { subscriptionId, details in
                    if details.status == .registered {
                        startSubscription(subscriptionId: subscriptionId)
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



