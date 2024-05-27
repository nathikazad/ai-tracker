//
//  EventRow.swift
//  History
//
//  Created by Nathik Azad on 5/25/24.
//
import SwiftUI
struct EventRow: View {
    var event: EventModel
    @State private var reassignParentForId: Int? = nil
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
                    EventButtonsView(event: event, reassignParentForId: $reassignParentForId, expandedEventIds: $expandedEventIds)
                }
                EventDestination(event: event)
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
}


