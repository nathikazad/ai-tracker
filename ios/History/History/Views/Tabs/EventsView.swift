//
//  File.swift
//  History
//
//  Created by Nathik Azad on 4/8/24.
//

import SwiftUI
import Combine


// Define your custom views for each tab
struct EventsView: View {
    @State private var expandedEventIds: Set<Int> = []
    @StateObject private var datePickerModel: TwoDatePickerModel = TwoDatePickerModel()
    @State private var events: [EventModel] = []
    @State private var coreStateSubcription: AnyCancellable?
    
    var eventId: Int?
    var eventType: EventType?
    
    var subscriptionId: String {
        var id = eventId != nil ? "/\(eventId!)" : ""
        id += eventType != nil ? "/\(eventType!)" : ""
        return "events\(id)"
    }
    
    @State private var scrollProxy: ScrollViewProxy?
    var body: some View {
        VStack {
            CalendarButton()
            Group {
                if events.isEmpty {
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
                print("EventsView: onAppear")
                if(Authentication.shared.areJwtSet) {
                    listenToEvents()
                    coreStateSubcription?.cancel()
                    coreStateSubcription = AppState.shared.subscribeToCoreStateChanges {
                        print("Core state occurred")
                        listenToEvents()
                    }

                }
            }
            .onDisappear {
                print("EventsView: onDisappear")
                EventsController.cancelListener(subscriptionId: subscriptionId)
                coreStateSubcription?.cancel()
                coreStateSubcription = nil
            }
        }
        .overlay(
            popupView
        )
    }
    
    private var popupView: some View {
        Group {
            if datePickerModel.showPopupForId != nil {
                TwoDatePickerView(datePickerModel: datePickerModel)
            }
        }
    }
    
    private func listenToEvents() {
        EventsController.listenToEvents(userId: Authentication.shared.userId!, subscriptionId: subscriptionId, onlyRootNodes: true, date: state.currentDate, parentId: eventId) {
            events in
            
            print("EventsView: listenToEvents: new event")
            DispatchQueue.main.async {
                self.events = []
                self.events = events
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
        ScrollViewReader { proxy in
            VStack(spacing: 0) {
                ZStack(alignment: .top) {
                    List {
                        ForEach(events.sortEvents, id: \.id) { event in
                            eventRow(event)
                            if expandedEventIds.contains(event.id) && event.children.count > 0 {
                                MinimizedNoteView(notes: event.metadata!.notes, level:1)
                                ForEach(event.children.sortEvents, id: \.id) { child in
                                    eventRow(child, level: 1)
                                    if expandedEventIds.contains(child.id) {
                                        MinimizedNoteView(notes: child.metadata!.notes, level:2)
                                        ForEach(child.children.sortEvents, id: \.id) { grandChild in
                                            eventRow(grandChild, level: 2)
                                        }
                                     }
                                }
                            }
                        }
                    }
                    .onAppear {
                        scrollProxy = proxy
                    }
                    .onChange(of: events) {
                        if state.currentDate == Calendar.current.startOfDay(for: Date())
                        {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                                if let lastId = events.last?.id {
                                    withAnimation(.easeInOut(duration: 0.5)) { // Customize the animation style and duration here
                                        //                                    print("changed \(lastId) \(scrollProxy == nil)")
                                        scrollProxy?.scrollTo(lastId, anchor: .top)
                                    }
                                }
                            }
                        }
                        
                    }
                    .padding(.top, 15)
                    
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            if expandedEventIds.count > 0 {
                                expandedEventIds = []
                            } else {
                                expandedEventIds = Set(events.withChildrenOrNotes.map { $0.id })
                            }
                        }) {
                            if expandedEventIds.count > 0 {
                                Image(systemName: "minus.circle")
                                    .padding()
                                    .padding(.trailing, 15)
                            } else {
                                Image(systemName: "plus.circle")
                                    .padding()
                                    .padding(.trailing, 15)
                            }
                        }
                    }
                    .background(Color(uiColor: .secondarySystemBackground))
                }
            }
        }
    }
    
    private func eventRow(_ event: EventModel, level: Int = 0) -> EventRow {
        return EventRow(
            event: event,
            expandedEventIds: $expandedEventIds,
            dateClickedAction: { event in
                datePickerModel.showPopupForEvent(event: event)
            },
            level: level)
    }
    
}


//#Preview {
//    TimelineView()
//}
