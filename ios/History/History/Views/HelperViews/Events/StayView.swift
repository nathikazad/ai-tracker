//
//  StayView.swift
//  History
//
//  Created by Nathik Azad on 5/22/24.
//
import SwiftUI
struct StayView: View {
    @State var childEvents: [EventModel] = []
    @State var event: EventModel? = nil
    
    var eventId: Int

    private func fetchData() {
        Task {
            let childEvents = await EventsController.fetchEvents(order: "desc", parentId:eventId)
            let event = await EventsController.fetchEvent(id:eventId)
            DispatchQueue.main.async {
                self.childEvents = childEvents
                self.event = event
            }
        }
    }

    var body: some View {
        List {
            Text(event?.toString ?? "Not sure")
            EventsListView(events: $childEvents)
        }
        .onAppear(perform: fetchData)
    }
}
