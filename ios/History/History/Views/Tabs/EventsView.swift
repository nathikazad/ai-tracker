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
    @State private var reassignParentForId: Int? = nil
    
    var chosenEventId: Int?
    
    var subscriptionId: String {
        let id = chosenEventId != nil ? "/\(chosenEventId!)" : ""
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
                print("Timelineview has disappeared")
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
        EventsController.listenToEvents(userId: Authentication.shared.userId!, subscriptionId: subscriptionId, nested: true, date: state.currentDate) {
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
                            if event.children.count > 0 && expandedEventIds.contains(event.id) {
                                ForEach(event.children.sortEvents, id: \.id) { child in
                                    eventRow(child, level: 1)
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
                                expandedEventIds = Set(events.withChildren.map { $0.id })
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
    
    private func eventRow(_ event: EventModel, level: Int = 0) -> some View {
        return HStack {
            if(level > 0) {
                Rectangle()
                .frame(width: CGFloat(4 * level))
                .foregroundColor(Color.gray)
            }
            Text(event.formattedTime)
                .font(.headline)
                .frame(width: 100, alignment: .leading)
                .onTapGesture {
                    print("tapped")
                    datePickerModel.showPopupForEvent(event: event)
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
                                print("Change parent of \(reassignParentForId) to \(event.id)")
                                EventsController.editEvent(id: reassignParentForId!, parentId: event.id)
                                reassignParentForId = nil
                            }) {
                                Image(systemName: "arrow.left.circle.fill")
                            }
                            .buttonStyle(HighPriorityButtonStyle())
                        }
                    } else if(event.children.count > 0) {
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
                // TODO: start microphone with parameters
            }) {
                Image(systemName: "mic.fill")
            }
            Button(action: {
                print("Clicked chat on \(event.id)")
                // TODO: start chat with parameters
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
        case .commuting:
            if let polyline = event.metadata?.polyline {
                return AnyView(PolylineView(encodedPolyline: polyline))
            }
        case .working:
            return AnyView(WorkView(event: event))
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


//#Preview {
//    TimelineView()
//}
