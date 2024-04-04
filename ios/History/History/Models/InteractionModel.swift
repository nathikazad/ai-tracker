//
//  InteractionModel.swift
//  History
//
//  Created by Nathik Azad on 3/18/24.
//

import Foundation
class InteractionModel: ObservableObject {
    @Published var interactions: [Interaction] = []

    func fetchInteractions() {
        print("fetching")
        guard let url = URL(string: "https://ai-tracker-server-613e3dd103bb.herokuapp.com/getinteractions") else { return }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data {
                do {
                    let decodedData = try JSONDecoder().decode([Interaction].self, from: data)
                    DispatchQueue.main.async {
                        self.interactions = decodedData
                        print("fetched")
                    }
                } catch {
                    print("Failed to decode JSON")
                }
            } else if let error = error {
                print("HTTP request failed: \(error)")
            }
        }.resume()
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
    var time: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case content
        case time = "timestamp" // if the key in your JSON is "timestamp" instead of "time"
    }
    var justDate: String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        // Attempt to parse the ISO 8601 date string into a Date object
        guard let date = isoFormatter.date(from: time) else {
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
        if let date = isoFormatter.date(from: time) {
            let localFormatter = DateFormatter()
            localFormatter.timeZone = TimeZone.current // Convert to local time zone
            localFormatter.dateFormat = "hh:mm a" // Specify your desired format
            
            return localFormatter.string(from: date)
        }
        return "Invalid Time" // Return a default or error message if parsing fails
    }
}
