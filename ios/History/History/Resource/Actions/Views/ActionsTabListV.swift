//
//  File.swift
//  History
//
//  Created by Nathik Azad on 4/8/24.
//

import SwiftUI
import Combine


// Define your custom views for each tab
struct ActionsTabView: View {
    @State private var events: [ActionModel] = []
    @StateObject var datePickerModel: TwoDatePickerModel
    @State private var coreStateSubcription: AnyCancellable?
    @Binding var cameFromAnotherTab: Bool
    var eventId: Int?
    var eventType: EventType?
    
    @State private var scrollProxy: ScrollViewProxy?
    var body: some View {
        VStack {
            Group {
                if events.isEmpty {
                    VStack {
                        Spacer()
                        Text("No Events Yet")
                            .foregroundColor(.primary)
                            .font(.title2)
                        Text("Create an event by clicking the plus button on top")
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
                state.setTimePicker(.day)
                if(auth.areJwtSet) {
                    fetchEvents()
                    coreStateSubcription?.cancel()
                    coreStateSubcription = state.subscribeToCoreStateChanges {
                        print("Core state occurred")
                        fetchEvents()
                    }
                }
            }
            .onDisappear {
                coreStateSubcription?.cancel()
            }
        }
    }
    
    func fetchEvents() {
        Task {
            let events = await ActionController.fetchActions(userId: auth.userId!, forDate: state.currentDate, withObjectConnections: true)
            let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: state.currentDate)!
            let filteredEvents = events.filterEvents(startDate: state.currentDate, endDate: nextDay)
            await MainActor.run {
                self.events = filteredEvents
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
    
    private var eventsToShow: [ActionModel] {
        return events
    }
    
    private  func scroll() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            if state.isItToday && cameFromAnotherTab
            {
                
                let last: ActionModel? = events.sorted { $0.startTime > $1.startTime }.first
                if last != nil {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        scrollProxy?.scrollTo(last?.id, anchor: .top)
                    }
                }
            }
            cameFromAnotherTab = false
        }
    }
    
    var listView: some View {
        ScrollViewReader { proxy in
            VStack(spacing: 0) {
                ZStack(alignment: .top) {
                    List {
                        ForEach(eventsToShow.rootNodes.sortEvents, id: \.id) { event in
                            eventRow(event)
                                .alignmentGuide(.listRowSeparatorLeading) { _ in
                                    -20
                                }
                            let childEvents = eventsToShow.filter { child in
                                child.parentId == event.id
                            }
                            ForEach(childEvents, id: \.id) { child in
                                eventRow(child, level: 1)
                                    .alignmentGuide(.listRowSeparatorLeading) { _ in
                                        -20
                                    }
                            }
                        }
                    }
                    .onAppear {
                        scrollProxy = proxy
                        scroll()
                    }
                }
            }
        }
    }
    
    private func eventRow(_ event: ActionModel, level: Int = 0) -> ActionRow {
        return ActionRow(
            event: event,
            dateClickedAction: { event in
                datePickerModel.showPopupForAction(event: event)
            },
            fetchActions: fetchEvents,
            showTimeWithRespectToCurrentDate: true,
            includeActionName: true,
            level: level
        )
    }
}



//#Preview {
//    TimelineView()
//}
