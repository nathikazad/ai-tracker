import SwiftUI

struct SleepView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var events: [EventModel] = []
    @State private var selectedDays: Double = 7
    @State private var maxDays: Double = 7

    // Helper function to convert time string to decimal
    private func timeToDecimal(time: Date) -> Double {
        let timeString = time.formattedTime
        let components = timeString.split(separator: ":")
        let hourComponent = components.first!
        let amPmComponent = components.last!.split(separator: " ")
        var hours = Double(hourComponent)!
        let minutes = Double(amPmComponent.first ?? "0") ?? 0
        let amPm = amPmComponent.last ?? ""

        if amPm == "PM" && hours != 12 { // Convert PM time to 24-hour format except for 12 PM
            hours += 12
        }
        if amPm == "AM" && hours == 12 { // Midnight edge case
            hours = 0
        }
        return hours + (minutes / 60.0)
    }

    var dailyTotals: [(String, Double)] {
        EventsController.dailyTotals(events: events, days: Int(selectedDays))
    }

    var filteredEvents: [EventModel] {
        let startDate = Calendar.current.date(byAdding: .day, value: -Int(selectedDays), to: Date())!
        return events.filter { event in
            event.startTime != nil && event.endTime != nil &&
            event.startTime! >= startDate // Filter to include only events from the last 'selectedDays' days
        }.reversed()
    }

    
    var datesChartData: [String] {
        return filteredEvents.map(\.endTime!.formattedSuperShortDate)
    }

    var sleepTimes: [Double] {
        return filteredEvents.compactMap { timeToDecimal(time: $0.startTime!) }
    }

    var wakeTimes: [Double] {
        return filteredEvents.compactMap { timeToDecimal(time: $0.endTime!) }
    }

    private func fetchSleepDetails() {
        Task {
            let userId: Int? = Authentication.shared.userId
            let resp = await EventsController.fetchEvents(userId: userId!, eventType: "sleep", order: "desc")
            DispatchQueue.main.async {
                maxDays = max(EventsController.maxDays(events: resp), 30)
                selectedDays = min(maxDays, 7)
                events = resp
            }
        }
    }

    var body: some View {
        TabView {
            if(events.count > 1) {
                SleepGraphsView(
                    wakeTimes: wakeTimes,
                    sleepTimes: sleepTimes,
                    dates: datesChartData,
                    dailyTotals: dailyTotals,
                    selectedDays: $selectedDays,
                    maxDays: $maxDays
                )
                .tabItem {
                    Label("Graphs", systemImage: "chart.bar.xaxis")
                }
            }
            SleepEventsListView(events: $events)
                .tabItem {
                    Label("Events", systemImage: "list.bullet")
                }
                .onAppear(perform: fetchSleepDetails)
        }
    }
}

struct SleepEventsListView: View {
    @Binding var events: [EventModel]

    var body: some View {
        List {
            Section(header: Text("Events")) {
                ForEach(events, id: \.id) { event in
                    Text(event.formattedTimeWithDateAndX)
                        .font(.subheadline)
                }
            }
        }
    }
}

struct SleepGraphsView: View {
    var wakeTimes: [Double]
    var sleepTimes: [Double]
    var dates: [String]
    var dailyTotals: [(String, Double)]
    @Binding var selectedDays: Double
    @Binding var maxDays: Double

    var body: some View {
        ScrollView {
            VStack {
                SliderView(selectedDays: $selectedDays, maxDays: $maxDays)
                BarView(title: "Hours slept per day", data: dailyTotals)
                    .padding(.bottom)
                ScatterViewString(title: "Wake up time", data: Array(zip(dates, wakeTimes)))
                    .padding(.bottom)
                ScatterViewString(title: "Sleep time",  data: Array(zip(dates, sleepTimes)))
                    .padding(.bottom)
                ScatterViewDoubles(title: "Correlation", data: Array(zip(sleepTimes, wakeTimes)))
                    .padding(.bottom)
            }
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
