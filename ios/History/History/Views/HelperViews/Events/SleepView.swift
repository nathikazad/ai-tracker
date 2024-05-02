import SwiftUI

struct SleepView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var events: [EventModel] = []
    @State private var selectedDays: Double = 7
    @State private var maxDays: Double = 7


    private func fetchSleepDetails() {
        Task {
            let userId: Int? = Authentication.shared.userId
            let resp = await EventsController.fetchEvents(userId: userId!, eventType: "sleep", order: "desc")
            DispatchQueue.main.async {
                maxDays = max(events.maxDays, 30)
                selectedDays = min(maxDays, 7)
                events = resp
            }
        }
    }

    var body: some View {
        TabView {
            if(events.count > 1) {
                ScrollView {
                    VStack {
                        SliderView(selectedDays: $selectedDays, maxDays: $maxDays)
                        CandleView(title: "Time", candles: events.dailyTimes(days: Int(selectedDays)).map { Candle(date: $0, start: $1, end: $2 ) })
                            .padding(.bottom)
                        BarView(title: "Total Hours per day", data: events.dailyTotals( days: Int(selectedDays)))
                            .padding(.bottom)
                        ScatterView(title: "Start time",  data: events.startTimes(days: Int(selectedDays), unique: true))
                        ScatterView(title: "End time", data: events.endTimes(days: Int(selectedDays), unique: true))
                            .padding(.bottom)
//                            .padding(.bottom)
//                        ScatterViewDoubles(title: "Correlation", data: Array(zip(sleepTimes, wakeTimes)))
//                            .padding(.bottom)
                    }
                }
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
