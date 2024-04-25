//
//  File.swift
//  History
//
//  Created by Nathik Azad on 4/8/24.
//

import SwiftUI

// Define your custom views for each tab
struct EventsView: View {
    @StateObject var eventController = EventsController()
    @State private var showPopupForId: Int?
    @State private var draftContent = ""
    
    
    
    var body: some View {
        VStack {
            Text(eventController.formattedDate)
                .foregroundColor(.black)
                .padding(.top, 5)
                .frame(maxWidth: .infinity, alignment: .center)
                .gesture(
                    DragGesture().onEnded { gesture in
                        if gesture.translation.width < 0 { // swipe left
                            eventController.goToNextDay()
                        } else if gesture.translation.width > 0 { // swipe right
                            eventController.goToPreviousDay()
                        }
                    }
                )
            Group {
                if eventController.events.isEmpty {
                    VStack {
                        Spacer()
                        Text("No Events Yet")
                            .foregroundColor(.black)
                            .font(.title2)
                        Text("Create an event by clicking the microphone below")
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center) // This will center-align the text horizontally
                            .padding(.horizontal, 20)
                        Spacer()
                    }
                } else {
                    listView
                }
            }
            .onAppear {
                if(Authentication.shared.areJwtSet) {
                    eventController.fetchEvents(userId: Authentication.shared.userId!)
                    eventController.listenToEvents(userId: Authentication.shared.userId!)
                }
            }
            .onDisappear {
                print("Timelineview has disappeared")
                eventController.cancelListener()
            }
        }
        .overlay(
            popupView
        )
    }
    
    private var emptyStateView: some View {
        VStack {
            Spacer()
            Text("No Events Yet")
                .foregroundColor(.black)
                .font(.title2)
            Text("Record your first event by clicking the microphone below and saying what you did.")
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Spacer()
        }
    }
    
    private var listView: some View {
        List {
            ForEach(Array(eventController.events.enumerated()), id: \.element.id) { index, event in
                HStack {
                    Text(event.formattedTime)
                        .font(.headline)
                        .frame(width: 100, alignment: .leading)
                    Divider()
                    if let location = event.metadata?.location {
                        NavigationLink(destination: LocationDetailView(location: location)) {
                            formatEventText(for: event, isLast: index == eventController.events.count - 1)
                        }
                    } else if let polyline = event.metadata?.polyline {
                        NavigationLink(destination: PolylineView(encodedPolyline: polyline)) {
                            formatEventText(for: event, isLast: index == eventController.events.count - 1)
                        }
                    } else if event.eventType == "sleep" {
                        NavigationLink(destination: SleepView()) {
                            formatEventText(for: event, isLast: index == eventController.events.count - 1)
                        }
                    } else {
                        formatEventText(for: event, isLast: index == eventController.events.count - 1)
                    }
                }
                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                    Button(action: {
                        print("Tapped right on \(event.id)")
                        // TODO: start microphone with parameters
                    }) {
                        Image(systemName: "mic.fill")                                .foregroundColor(.green) // Setting the color of the icon
                    }
                }
            }
            .onDelete { indices in
                indices.forEach { index in
                    let eventId = eventController.events[index].id
                    eventController.deleteEvent(id: eventId)
                }
            }
        }
    }
    

    func formatEventText(for event: EventModel, isLast: Bool) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("\(event.eventType.capitalized) (\(event.id))")
                .font(.subheadline)
            
            // Use Group to handle multiple Text views within VStack
            Group {
                // Location Handling
                if let location = event.metadata?.location?.name ?? event.locationName {
                    Text("\(location)")
                        .padding(.leading, 10)
                        .font(.subheadline)
                }
                
                // Time and Distance Handling
                if let timeTaken = event.metadata?.timeTaken {
                    Text("Time: \(timeTaken)")
                        .padding(.leading, 10)
                        .font(.subheadline)
                }
                if let distance = event.metadata?.distance {
                    Text("Distance: \(distance)km")
                        .padding(.leading, 10)
                        .font(.subheadline)
                }

                // Special handling for "stay" event type
                if isLast && event.endTime == nil && event.startTime != nil {
                    Text("Time: \(event.startTime!.durationSinceInHHMM)")
                        .padding(.leading, 10)
                        .font(.subheadline)
                }
            }
        }
    }

    
    private var popupView: some View {
        Group {
            if showPopupForId != nil {
                VStack {
                    Text("Edit Content")
                        .font(.headline) // Optional: Sets the font for the title
                        .padding(.bottom, 5) // Reduces the space below the title
                    
                    TextEditor(text: $draftContent)
                        .frame(minHeight: 50, maxHeight: 200) // Reduces the minimum height and sets a max height
                        .padding(4) // Reduces padding around the TextEditor
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.gray, lineWidth: 1) // Border for TextEditor
                        )
                    
                    Button(action: {
                        DispatchQueue.main.async {
                            eventController.editEvent(id: showPopupForId!, content: draftContent)
                            self.showPopupForId = nil
                        }
                    }) {
                        Text("Save")
                            .foregroundColor(.black)
                    }
                    .padding(.top, 5)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 5)
                .frame(width: 300)
                .overlay(
                    Button(action: {
                        showPopupForId = nil
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                    },
                    alignment: .topTrailing
                )
            }
        }
    }
}


//#Preview {
//    TimelineView()
//}
