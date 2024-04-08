//
//  InteractionModel.swift
//  History
//
//  Created by Nathik Azad on 3/18/24.
//

import Foundation
class InteractionModel: ObservableObject {
    
    @Published var interactions: [Interaction] = []
    var subscriptionId: String?
    func fetchInteractions() async {
        let graphqlQuery = 
        """
            query MyQuery {
                interactions(order_by: {timestamp: desc}, limit: 5) {
                    timestamp
                    id
                    content
                  }
            }
        """

        do {
            let data = try await fetchGraphQLData(graphqlQuery: graphqlQuery)
            let decoder = JSONDecoder()
            let responseData = try decoder.decode(ResponseData.self, from: data)
            DispatchQueue.main.async {
                self.interactions = responseData.data.interactions
            }
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    struct ResponseData: Decodable {
        var data: InteractionsWrapper
    }

    struct InteractionsWrapper: Decodable {
        var interactions: [Interaction]
    }
    
    func listenToInteractions() {
        let subscriptionQuery = """
            subscription { 
            interactions(order_by: {timestamp: desc}, limit: 5) {
                timestamp
                id
                content
              }
        }
        """
        subscriptionId = HasuraSocket.shared.startListening(subscriptionQuery: subscriptionQuery) { messageDictionary in
            
            do {
                // Convert the dictionary back to Data for decoding
                let data = try JSONSerialization.data(withJSONObject: messageDictionary, options: [])
                let decoder = JSONDecoder()
                // Assuming your JSON structure matches what your models expect
                let responseData = try decoder.decode(ResponseData.self, from: data)
                DispatchQueue.main.async {
                    self.interactions = responseData.data.interactions
                }
            } catch {
                print("Error processing message: \(error.localizedDescription)")
            }
        }
    }
    
    func cancelListener() {
        if(subscriptionId != nil) {
            HasuraSocket.shared.stopListening(uniqueID: subscriptionId!)
            subscriptionId = nil
        }
    }
    
    var interactionsGroupedByDate: [(date: String, interactions: [Interaction])] {
        // Group interactions by justDate
        let groups = Dictionary(grouping: interactions) { $0.justDate }
        
        // Convert Dictionary to sorted array of tuples
        let sortedGroups = groups.sorted { $0.key < $1.key }.map { (date: $0.key, interactions: $0.value) }
        return sortedGroups
    }

    func deleteInteraction(id: Int) {

            guard let url = URL(string: "http://serverUrl/interaction/\(id)") else { return }
            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    print("Failed to delete interaction: \(error)")
                } else {
                    DispatchQueue.main.async {
                        self.interactions.removeAll(where: { interaction in
                            interaction.id == id
                        })
                    }
                }
            }.resume()
        
    }
}

struct Interaction: Decodable, Equatable {
    var id: Int
    var content: String
    var timestamp: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case content
        case timestamp // if the key in your JSON is "timestamp" instead of "time"
    }
    var justDate: String {
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
    
    var formattedTime: String {
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
