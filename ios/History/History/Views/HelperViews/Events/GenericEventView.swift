//
//  WorkView.swift
//  History
//
//  Created by Nathik Azad on 5/23/24.
//


import SwiftUI

struct GenericEventView: View {
    @State var event: EventModel? = nil
    @State var chatViewPresented: Bool = false
    @StateObject private var noteStruct: NoteStruct = NoteStruct()
    @StateObject private var bookStruct: BookStruct = BookStruct()
    
    @State private var showCamera = false
    @State private var selectedImage: UIImage?
    
    @State private var selectedCategory: String = "note"
    
    var eventId: Int
    
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
                    
                    if let location = event.location ?? event.parent?.location ?? event.parent?.parent?.location {
                        NavigationLink(destination: LocationDetailView(location: location)) {
                            Text(location.name ?? "Unknown")
                        }
                    }
                    if let parent = event.parent {
                        HStack(spacing: 5) {
                            Text("Parent Event: ")
                            NavigationLink(destination: GenericEventView(eventId: parent.id)) {
                                Text(parent.eventType.capitalized)
                            }
                        }
                    }
                    
                    if event.eventType == .reading {
                        MinBooksView(event: $event, bookStruct: bookStruct)
                    }
                }
                
                if event.allPeopleCount > 3 {
                    Picker("Select Category", selection: $selectedCategory) {
                        ForEach(["note", "person.3.fill", "clock"], id: \.self) { category in
                            HStack {
                                Image(systemName: category) // Display the image next to the text
                                    .foregroundColor(.blue)
                            }
                            .tag(category)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                } else if event.allPeopleCount > 0 ||  event.eventType == .meeting {
                    MinPeopleView(event:  Binding(get: {event}, set: { v in}))
                }
                
                
                if selectedCategory == "note" {
                    NotesView(event: Binding(get: {event}, set: { v in}),
                              showCamera: $showCamera,
                              selectedImage: $selectedImage,
                              noteStruct: noteStruct,
                              createNoteAction: {
                        parentId in
                        state.setParentEventId(parentId)
                        chatViewPresented = true
                    })
                } else if selectedCategory == "person.3.fill" {
                    MinPeopleView(event:  Binding(get: {event}, set: { v in}))
                }
                
                
                if(event.hasChildren) {
                    if event.allObjects.people.count <= 3 || selectedCategory == "clock" {
                        EventsListView(events: Binding(get: { event.children }, set: { events in }), withDate: false)
                    }
                }
            }
        }
        .onAppear {
            EventsController.listenToEvent(id: eventId, subscriptionId: subscriptionId, withParents: true) {
                event in
                print("WorkView: listenToEvent: new event")
                DispatchQueue.main.async {
                    self.event = nil
                    self.event = event
                }
            }
        }
        .onDisappear {
            EventsController.cancelListener(subscriptionId: subscriptionId)
        }
        .navigationTitle(event != nil ? "\(event!.eventType.capitalized)(\(String(eventId)))" : "")
        .fullScreenCover(
            isPresented: Binding(
                get: { chatViewPresented || showCamera }, 
                set: { value in
                    if !value {
                        chatViewPresented = false
                        showCamera = false
                    }
                }
            )) {
            if chatViewPresented {
                ChatView {
                    chatViewPresented = false
                }
            }
            if showCamera {
                accessCameraView { image in
                    
                    if let imageLocation = saveImage(image: image) {
                        var images = event?.metadata?.images ?? []
                        images.append(imageLocation)
                        EventsController.editEvent(id: event!.id, images: images)
                    }
                    showCamera = false
                }
                .background(BlackBackgroundView())
            }
        }
        .overlay {
            popupView
        }
        .sheet(isPresented: Binding(get: { selectedImage != nil }, set: { value in
            if !value {
                selectedImage = nil
            }
        })) {
            if let selectedImage = selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
            }
        }
        
    }

    private var popupView: some View {
        NotesPopup(noteStruct: noteStruct, event: $event, eventId: eventId)
    }
}
