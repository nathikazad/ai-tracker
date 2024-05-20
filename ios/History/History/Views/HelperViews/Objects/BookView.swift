//
//  BookView.swift
//  History
//
//  Created by Nathik Azad on 5/17/24.
//


import SwiftUI


import SwiftUI

struct BookView: View {
    let bookId: Int
    @State private var book: ASObject?
    @State private var events: [EventModel] = []

    var body: some View {
        VStack {
            if book != nil {
                List {
                    Section(header: Text("Book Details")) {                 
                        Text("Date started: \(book!.dateStarted?.formattedShortDateAndTime ?? "Unknown")")
                        Text("Date finished: \(book!.dateEnded?.formattedShortDateAndTime ?? "Unknown")")
                        // round to 2 decimal places
                        let duration: String = String(format: "%.2f", book!.totalDurationInHours)
                        Text("Time Read: \(duration) hours")
                    }
                    EventsListView(events: $events)
                }
            } else {
                Text("No book")
                    .onAppear {
                        fetchBook()
                    }
            }
        }
        .navigationTitle(book?.name ?? "Book")
    }

    private func fetchBook() {
        Task {
            let resp = await ObjectController.fetchObject(objectId: bookId)
            DispatchQueue.main.async {
                book = resp
                if let bookEvents = book?.events {
                    self.events = bookEvents
                }
            }
        }
    }
}
