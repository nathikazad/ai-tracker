//
//  WorkView.swift
//  History
//
//  Created by Nathik Azad on 5/23/24.
//


import SwiftUI
struct WorkView: View {
    @State var event: EventModel? = nil
    var eventId: Int? = nil

    private func fetchData() {
        if(event == nil && eventId != nil) {
            Task {
                let event = await EventsController.fetchEvent(id:eventId!)
                DispatchQueue.main.async {
                    self.event = event
                }
            }
        }
    }

    var body: some View {
        List {
            Text(String(event?.id ?? 0))
            Text(event?.toString ?? "Not sure")
            
        }
        .onAppear(perform: fetchData)
    }
}
