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
    
    @State private var showCamera = false
    @State private var selectedImage: UIImage?
    
    
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
                    
                    //                    if let interaction = event.interaction?.content {
                    //                        Text(interaction)
                    //                    }
                    //
                    if event.eventType == .reading {
                        MinBooksView(event: $event, bookStruct: bookStruct)
                    }
                }
                
                if event.eventType == .meeting {
                    Section(header: Text("People")) {
                        MinPeopleView(event: $event)
                    }
                }
                
                
                // Books
                // Persons
                // Recipes
                
                NotesView(event: $event,
                          showCamera: $showCamera,
                          selectedImage: $selectedImage,
                          noteStruct: noteStruct,
                          createNoteAction: {
                    parentId in
                    state.setParentEventId(parentId)
                    chatViewPresented = true
                })
                
                // Child Events
                if(event.hasChildren) {
                    EventsListView(events: Binding(get: { event.children }, set: { events in }), withDate: false)
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
