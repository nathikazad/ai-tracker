//
//  WorkView.swift
//  History
//
//  Created by Nathik Azad on 5/23/24.
//


import SwiftUI
struct GenericEventView: View {
    @State var event: EventModel? = nil
    @State var parent: EventModel? = nil
    @State var chatViewPresented: Bool = false
    @StateObject private var noteStruct: NoteStruct = NoteStruct()
    @StateObject private var bookStruct: BookStruct = BookStruct()
    
    @State var expandedEventIds: Set<Int> = []
    @State var reassignParentForId: Int? = nil
    
    
    var eventId: Int
    var parentId: Int?
    
    var subscriptionId: String {
        return "event/\(eventId)"
    }
    
    
    var body: some View {
        Form {
            if let event = event {
                Section(header: Text("Event Info")) {
                    Text(event.formattedTimeWithDate)//

                    NavigationLink(destination: EventTypeView(eventType: event.eventType)) {
                        Text("Event Type: \(event.eventType.capitalized)")
                    }
                    
                    if let location = event.location ?? parent?.location {
                        NavigationLink(destination: LocationDetailView(location: location)) {
                            Text(location.name ?? "Unknown")
                        }
                    }
                    
                    if let interaction = event.interaction?.content {
                        Text(interaction)
                    }
                    
                    MinBooksView(event: $event, bookStruct: bookStruct)
                }
            }
            
            
            // Books
            // Persons
            // Recipes
            
            NotesView(event: $event,
                      noteStruct: noteStruct,
                      createNoteAction: {
                parentId in
                state.setParentEventId(parentId)
                chatViewPresented = true
            }
            )
            if(event?.hasChildren ?? false) {
                Section(header: Text("Events")) {
                    List {
                        ForEach(event!.children.sortEvents, id: \.id) { event in
                            EventRow(
                                event: event,
                                expandedEventIds: $expandedEventIds
                            )
                        }
                    }
                }
            }
        }
        .onAppear {
            EventsController.listenToEvent(id: eventId, subscriptionId: subscriptionId) {
                event in
                print("WorkView: listenToEvent: new event")
                DispatchQueue.main.async {
                    self.event = nil
                    self.event = event
                }
            }
            if let parentId = parentId {
                Task {
                    print("GenericEventView fetching parent \(parentId)")
                    let parent = await EventsController.fetchEvent(id: parentId)
                    DispatchQueue.main.async {
                        print("GenericEventView parent location \(parent?.location?.name ?? "Not tjere")")
                        self.parent = parent
                    }
                }
            }
        }
        .onDisappear {
            EventsController.cancelListener(subscriptionId: subscriptionId)
        }
        .navigationTitle("\(event?.eventType.capitalized ?? "Event")(\(String(eventId)))")
        .fullScreenCover(isPresented: $chatViewPresented) {
            ChatView {
                chatViewPresented = false
            }
        }
        .overlay {
            popupView
        }
    }
    
    private var popupView: some View {
        Group {
            NotesPopup(noteStruct: noteStruct, event: $event, eventId: eventId)
        }
    }
}

