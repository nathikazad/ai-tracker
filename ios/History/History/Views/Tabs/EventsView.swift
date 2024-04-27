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
    
    
    var body: some View {
        VStack {
            Text(eventController.formattedDate)
                .foregroundColor(.primary)
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
                            .foregroundColor(.primary)
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
    }
    
    private var emptyStateView: some View {
        VStack {
            Spacer()
            Text("No Events Yet")
                .foregroundColor(.primary)
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
                    destinationView(for: event, isCurrent: index == eventController.events.count - 1)
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
    
    
    
    func destinationView(for event: EventModel, isCurrent: Bool) -> some View {
        let text = Text(formatEventText(for: event, isCurrent: isCurrent))
                    .padding(.leading, 10)
                    .font(.subheadline)

        switch event.eventType {
        case "stay":
            if let location = event.metadata?.location {
                return AnyView(NavigationLink(destination: LocationDetailView(location: location)) {
                    text
                })
            }

        case "commute":
            if let polyline = event.metadata?.polyline {
                return AnyView(NavigationLink(destination: PolylineView(encodedPolyline: polyline)) {
                    text
                })
            }

        case "sleep":
            return AnyView(NavigationLink(destination: SleepView()) {
                text
            })

        default:
            break
        }

        // If none of the cases apply, return just the text without a NavigationLink
        return AnyView(text)
    }

    
    func formatEventText(for event: EventModel, isCurrent: Bool) -> String {
        var result: String = ""
        let timeTaken = calcTimeTaken(event: event, isCurrent: isCurrent)
        switch event.eventType {
        case "stay":
            let locationName = event.metadata?.location?.name ?? "Unnamed location"
            result = "\(locationName)(\(event.id)) \(timeTaken)"
        case "commute":
            let distance = event.metadata?.distance != nil ? "\(event.metadata!.distance!)km" : ""
            result = "Commute(\(event.id)) \(timeTaken) \(distance)"
        case "sleep":
            result = "Sleep(\(event.id)) \(timeTaken)"
        default:
            result = "\(event.eventType.capitalized) (\(event.id))"
        }

        return result
    }
    
    func calcTimeTaken(event: EventModel, isCurrent:Bool) -> String {
        var timeTaken: String? = event.metadata?.timeTaken
        if isCurrent && event.endTime == nil && event.startTime != nil {
            timeTaken = event.startTime!.durationSinceInHHMM
        } else if event.endTime != nil && event.startTime != nil {
            timeTaken = event.startTime!.durationInHHMM(to: event.endTime!)
        }
        return timeTaken != nil ? "Time:\(timeTaken!)"  : ""
    }
}


//#Preview {
//    TimelineView()
//}
