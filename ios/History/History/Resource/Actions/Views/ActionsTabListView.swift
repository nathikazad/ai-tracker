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
    @StateObject private var datePickerModel: TwoDatePickerModel = TwoDatePickerModel()
    @State private var events: [ActionModel] = []
    
    var eventId: Int?
    var eventType: EventType?
    
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
                if(auth.areJwtSet) {
                    fetchEvents()
                }
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
    
    private func fetchEvents() {
        Task {
            let events = await ActionController.fetchActions(userId: auth.userId!, forDate: state.currentDate)
            self.events = events
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
        if state.isItToday
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                let last: ActionModel? = events.sorted { $0.startTime > $1.startTime }.first
                if last != nil {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        scrollProxy?.scrollTo(last?.id, anchor: .top)
                    }
                }
            }
        }
    }
    
    var listView: some View {
        ScrollViewReader { proxy in
            VStack(spacing: 0) {
                ZStack(alignment: .top) {
                    List {
                        ForEach(eventsToShow.sortEvents, id: \.id) { event in
                            eventRow(event)
                        }
                    }
                    .onAppear {
                        scrollProxy = proxy
                        scroll()
                    }
                    .padding(.top, 15)
                    
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
            showTimeWithRespectToCurrentDate: true)
    }
}



//#Preview {
//    TimelineView()
//}
