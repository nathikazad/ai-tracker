//
//  EventsComponents.swift
//  History
//
//  Created by Nathik Azad on 5/3/24.
//

import SwiftUI


enum SelectedTab {
    case graphs
    case events
}

struct TabButton: View {
    @Binding var selectedTab: SelectedTab
    var tab: SelectedTab
    var text: String
    var body: some View {
        Button(action: {
            selectedTab = tab
        }) {
            Text(text)
                .foregroundColor(selectedTab == tab ? .gray : .white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(selectedTab == tab ? .white : .gray)
                .cornerRadius(5)
        }
        .disabled(selectedTab == tab)
    }
}

struct TabBar: View {
    @Binding var selectedTab: SelectedTab
    
    var body: some View {
        HStack {
            TabButton(selectedTab: $selectedTab, tab: .events, text: "Graphs")
            TabButton(selectedTab: $selectedTab, tab: .graphs, text: "Events")
        }
    }
}


struct EventsListView: View {
    @Binding var events: [EventModel] // Assume Event is the type of the events array
    var body: some View {
        Section {
            ForEach(events, id: \.id) { event in
                Text(event.formattedTimeWithDate)
                    .font(.subheadline)
            }
        }
    }
}

struct GraphView: View {
    @Binding var selectedDays: Double
    @Binding var events: [EventModel]
    var offsetHours: Int = 0
    var body: some View {
        Section {
            CandleView(title: "Time", candles: events.dailyTimes(days: Int(selectedDays)).map { Candle(date: $0, start: $1, end: $2 ) }, offsetHours: offsetHours)
                .padding(.bottom)
            BarView(title: "Total Hours per day", data: events.dailyTotals( days: Int(selectedDays)))
                .padding(.bottom)
//            ScatterView(title: "Start time",  data: events.startTimes(days: Int(selectedDays), unique: true))
//            ScatterView(title: "End time", data: events.endTimes(days: Int(selectedDays), unique: true))
//                .padding(.bottom)
        }
    }
}

struct SliderView: View {
    @Binding var selectedDays: Double
    @Binding var maxDays: Double
    var body: some View {
        HStack {
            Slider(value: $selectedDays, in: 1...max(maxDays, 1), step: 1)
                .accentColor(.gray)
            Text("\(Int(selectedDays))")
                .foregroundColor(.gray)
        }
        .padding(.horizontal)
    }
}

struct CountView: View {
    @Binding var selectedDays: Double
    @Binding var maxDays: Double
    @Binding var events: [EventModel]
    var body: some View {
        HStack {
            Text("Total hours: \(events.totalHours(days: Int(selectedDays)))")
                .foregroundColor(.gray)
            Text("Total days: \(events.totalDays(days: Int(selectedDays)))")
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding()
    }
}

