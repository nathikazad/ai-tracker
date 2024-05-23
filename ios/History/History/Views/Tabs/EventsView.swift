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
    @StateObject private var datePickerModel: DatePickerModel = DatePickerModel()
    @State private var events: [EventModel] = []
    @State private var chosenEvent: EventModel?
    @State private var coreStateSubcription: AnyCancellable?
    
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
    
    private func listenToEvents() {
        var date: Date? = state.currentDate;
        var parentId: Int? = nil
        if let chosenEventId = chosenEventId {
            date = nil;
            parentId = chosenEventId
            Task {
                let event = await EventsController.fetchEvent(userId: Authentication.shared.userId!, id: chosenEventId)
                DispatchQueue.main.async {
                    self.chosenEvent = event
                }
            }
            
        }
        EventsController.listenToEvents(userId: Authentication.shared.userId!, subscriptionId: subscriptionId, date: date, parentId: parentId) { events in
            DispatchQueue.main.async {
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
            VStack {
                List {
                    ForEach(Array(events.sortEvents.enumerated()), id: \.element.id) { index, event in
                        HStack {
                            Text(event.formattedTime)
                                .font(.headline)
                                .frame(width: 100, alignment: .leading)
                                .onTapGesture {
                                    datePickerModel.showPopupForEvent(event: event)
                                }
                            Divider()
                            destinationView(for: event) {
                                VStack {
                                Text("\(event.toString) (\(String(event.id)))")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.subheadline)
                                }
                            }
                            
                        }
                        .id(event.id)
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
                            let eventId = events[index].id
                            EventsController.deleteEvent(id: eventId)
                        }
                    }
                }
                .padding(.vertical, 0)
                .onAppear {
                    scrollProxy = proxy
                }
                .onChange(of: events) { _ in
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
            }
        }
    }
    
    private func destinationView<Content: View>(for event: EventModel, @ViewBuilder content: () -> Content) -> some View {
        if let destination = eventDestination(for: event) {
            return AnyView(
                NavigationLink(destination: destination) {
                    content()
                }
            )
        } else {
            return AnyView(content())
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

    

    
    class DatePickerModel: ObservableObject {
        @Published var startTime: Date = Date()
        @Published var startTimeIsNull: Bool = false
        @Published var endTime: Date =  Date()
        @Published var endTimeIsNull: Bool = false
        @Published private(set) var isShowingDatePicker = false
        @Published private(set) var popupScreenFirst: Bool = true
        @Published private(set) var showPopupForId: Int?

        var getStartTime: Date? {
            return startTimeIsNull ? nil : startTime
        }

        var getEndTime: Date? {
            return endTimeIsNull ? nil : endTime
        }
        
        func showPopupForEvent(event: EventModel) {
            startTime = event.startTime ?? Date()
            endTime = event.endTime ?? Date()
            startTimeIsNull = event.startTime == nil
            endTimeIsNull = event.endTime == nil
            showPopupForId = event.id
            popupScreenFirst = true
        }
        
        func showNextScreen() {
            popupScreenFirst = false
        }
        
        func dismissPopup() {
            showPopupForId = nil
            print("dismissing popup")
        }
    }
    
    
    private var popupView: some View {
        Group {
            if datePickerModel.showPopupForId != nil {
                VStack {
                    if(datePickerModel.popupScreenFirst) {
                        Text("Start Time")
                        Toggle("Null", isOn: $datePickerModel.startTimeIsNull)
                            .padding()
                        if !datePickerModel.startTimeIsNull {
                            DatePicker("Start Time", selection: $datePickerModel.startTime, displayedComponents:  [.date, .hourAndMinute])
                                .datePickerStyle(WheelDatePickerStyle())
                                .frame(maxHeight: 150)
                                .padding()
                        }
                        

                        
                    } else {
                        Text("End Time")
                        Toggle("Null", isOn: $datePickerModel.endTimeIsNull)
                            .padding()
                        if !datePickerModel.endTimeIsNull {
                            DatePicker("End Time", selection: $datePickerModel.endTime, displayedComponents:  [.date, .hourAndMinute])
                                .datePickerStyle(WheelDatePickerStyle())
                                .frame(maxHeight: 150)
                                .padding()
                        }
                        
                    }
                    
                    Button(action: {
                        if(datePickerModel.popupScreenFirst) {
                            datePickerModel.showNextScreen()
                        } else {
                            DispatchQueue.main.async {
                                let startTime = datePickerModel.getStartTime
                                let endTime = datePickerModel.getEndTime
                                EventsController.editEvent(id: datePickerModel.showPopupForId!, startTime: startTime, endTime: endTime)
                                self.datePickerModel.dismissPopup()
                            }
                            
                        }
                    }) {
                        Text(datePickerModel.popupScreenFirst ? "Next" : "Save")
                            .foregroundColor(.primary)
                    }
                    .padding(.top, 5)
                }
                .padding()
                .background(Color("OppositeColor"))
                .cornerRadius(10)
                .shadow(radius: 5)
                .frame(width: 300)
                .overlay(
                    Button(action: {
                        datePickerModel.dismissPopup()
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
