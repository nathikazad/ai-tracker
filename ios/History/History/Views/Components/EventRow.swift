//
//  EventRow.swift
//  History
//
//  Created by Nathik Azad on 5/25/24.
//
import SwiftUI
struct EventRow: View {
    var event: EventModel
    @Binding var reassignParentForId: Int?
    @Binding var expandedEventIds: Set<Int>
    var dateClickedAction: (EventModel) -> Void
    var level: Int = 0
    
    var body: some View {
        HStack {
            if(level > 0) {
                Rectangle()
                    .frame(width: 4)
                    .foregroundColor(Color.gray)
                    .padding(.leading, CGFloat(level * 4))
            }
            Text(event.formattedTime)
                .font(.headline)
                .frame(width: 100, alignment: .leading)
                .onTapGesture {
                    print("tapped")
                    dateClickedAction(event)
                }
            Divider()
            
            ZStack(alignment: .leading) {
                HStack {
                    Text("\(event.toString) (\(String(event.id)))")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.subheadline)
                    if(reassignParentForId != nil) {
                        if(reassignParentForId == event.id) {
                            Button(action: {
                                reassignParentForId = nil
                            }) {
                                Image(systemName: "xmark")
                            }
                            .buttonStyle(HighPriorityButtonStyle())
                        } else {
                            Button(action: {
                                EventsController.editEvent(id: reassignParentForId!, parentId: event.id)
                                reassignParentForId = nil
                            }) {
                                Image(systemName: "arrow.left.circle.fill")
                            }
                            .buttonStyle(HighPriorityButtonStyle())
                        }
                    } else if(event.children.count > 0 || event.hasNotes) { //
                        Button(action: {
                            if expandedEventIds.contains(event.id) {
                                expandedEventIds.remove(event.id)
                                
                            } else {
                                expandedEventIds.insert(event.id)
                            }
                        }) {
                            if expandedEventIds.contains(event.id) {
                                Image(systemName: "minus.circle")
                            } else {
                                Image(systemName: "plus.circle")
                            }
                        }
                        .buttonStyle(HighPriorityButtonStyle())
                    }
                }
                destinationLink(event)
                
            }
            
        }
        .id(event.id)
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            Button(action: {
                print("Clicked mic on \(event.id)")
                state.setParentEventId(event.id)
                state.microphoneButtonClick()
            }) {
                Image(systemName: "mic.fill")
            }
            Button(action: {
                print("Clicked chat on \(event.id)")
                state.setParentEventId(event.id)
                state.showChat(newChatViewToShow: .normal)
            }) {
                Image(systemName: "message.fill")
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(action: {
                print("Deleting \(event.id)")
                EventsController.deleteEvent(id: event.id)
            }) {
                Image(systemName: "trash.fill")
            }
            .tint(.red)
            Button(action: {
                print("Clicked rearrange on \(event.id)")
                reassignParentForId = event.id
            }) {
                Image(systemName: "arrow.up.and.line.horizontal.and.arrow.down")
            }
        }
    }
    private func destinationLink(_ event: EventModel) -> some View {
        if let destination = eventDestination(for: event) {
            return AnyView(
                NavigationLink(destination: destination) {
                    EmptyView()
                }
                .padding(.horizontal, 10)
                .opacity(0)
            )
        } else {
            return AnyView(EmptyView())
        }
    }

    private func eventDestination(for event: EventModel) -> AnyView? {
        switch event.eventType {
        case .staying:
            if let location = event.location {
                return AnyView(LocationDetailView(location: location))
            }
    //        case .commuting:
    //            if let polyline = event.metadata?.polyline {
    //                return AnyView(PolylineView(encodedPolyline: polyline))
    //            }
        case .working:
            return AnyView(NotesView(eventId: event.id, title: "Working"))
        case .exercising:
            return AnyView(NotesView(eventId: event.id, title: "Exercising"))
        case .sleeping:
            return AnyView(SleepView())
        case .praying:
            return AnyView(PrayerView())
        case .learning:
            if let skill = event.metadata?.learningData?.skill {
                return AnyView(LearnView(skill: skill))
            }
        case .reading:
            if let book = event.book {
                return AnyView(BookView(bookId: book.id))
            }
        default:
            return nil
        }
        return nil
    }
}


