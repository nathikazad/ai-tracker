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
    @State private var showInPopup: ShowInPopup = .none
    @State private var newDate: Date = Date()
    @State private var showPopupForDate: Date = Date()
    @State private var draftContent = ""
    
    
    @State var expandedEventIds: Set<Int> = []
    @State var reassignParentForId: Int? = nil
    
    
    var eventId: Int
    var parentId: Int?

    var subscriptionId: String {
        return "event/\(eventId)"
    }

    
    var body: some View {
//        NavigationView {
            Form {
                if let event = event {
                    Section(header: Text("Event Info")) {
                        Text(event.formattedTimeWithDate)//
                        
                        ZStack(alignment: .leading) {
                            Text("Event Type: \(event.eventType.capitalized)")
                            EventDestination(event: event, destination: AnyView(EventTypeView(eventType: event.eventType)))
                        }
                        
                        if let location = event.location ?? parent?.location {
                            ZStack(alignment: .leading) {
                                Text("Location: \(parent!.location!.name!)")
                                EventDestination(event: parent!)
                            }
                        }
                        // metadata
                    }
                }
                
                
                // Books
                // Persons
                // Recipes
                
                NotesView(event: $event,
                          editDateAction:
                            { date in
                                    showInPopup = .date
                                    newDate = date
                                    showPopupForDate = date
                            },
                          editTextAction:
                            { date, note in
                                showInPopup = .text
                                draftContent = note
                                showPopupForDate = date
                            },
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
                                    expandedEventIds: $expandedEventIds,
                                    dateClickedAction: { event in
                                        //                                    datePickerModel.showPopupForEvent(event: event)
                                    }
                                    
                                )
                            }
                        }
                    }
                }
            }
//        }
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
            if(showInPopup == .date) {
                popupViewForDate(selectedTime: $newDate,
                                 saveAction: {
                    DispatchQueue.main.async {
                        if var notes = event?.metadata?.notesToJson {
                            let content = notes[showPopupForDate.toUTCString]
                            notes.removeValue(forKey: showPopupForDate.toUTCString)
                            notes[newDate.toUTCString] = content
                            EventsController.editEvent(id: eventId, notes: notes)
                        }
                        closePopup()
                    }
                }, closeAction: closePopup)
            } else if showInPopup == .text {
                popupViewForText(draftContent: $draftContent,
                                 saveAction: {
                    DispatchQueue.main.async {
                        if var notes = event?.metadata?.notesToJson {
                            notes[showPopupForDate.toUTCString] = draftContent
                            EventsController.editEvent(id: eventId, notes: notes)
                        }
                        closePopup()
                    }
                }, closeAction: closePopup
                )
            }
        }
    }
    
    func closePopup() {
        showInPopup = .none
        draftContent = ""
    }
}

struct MinimizedNoteView: View {
    var notes: [Date: String]
    var level: Int
    var body: some View {
        ForEach(Array(notes.keys).sorted(by: <), id: \.self) { date in
            if let note = notes[date] {
                HStack {
                    if(level > 0) {
                        Rectangle()
                            .frame(width: 4)
                            .foregroundColor(Color.gray)
                            .padding(.leading, CGFloat(level * 4))
                    }
                    Text(date.formattedTime)
                        .font(.headline)
                        .frame(width: 100, alignment: .leading)
                    Divider()
                    Text(note)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.subheadline)
                }
            }
        }
    }
}

