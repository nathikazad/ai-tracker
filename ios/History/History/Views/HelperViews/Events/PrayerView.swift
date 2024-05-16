import SwiftUI
import Charts

struct Prayer {
    let fajr: Bool
    let dhuhr: Bool
    let asr: Bool
    let maghrib: Bool
    let isha: Bool
    
    var total: Int {
        return (fajr ? 1 : 0) + (dhuhr ? 1 : 0) + (asr ? 1 : 0) + (maghrib ? 1 : 0) + (isha ? 1 : 0)
    }
}


struct PrayerView: View {
    @State var events: [EventModel] = []
    @State private var selectedDays: Double = 7
    @State private var maxDays: Double = 7
    @State private var selectedTab: SelectedTab = .graphs

    private func fetchPrayerDetails() {
        Task {
            let userId: Int? = Authentication.shared.userId
            let resp = await EventsController.fetchEvents(userId: userId!, eventType: "praying", order: "desc")
            DispatchQueue.main.async {
                print("fetchPrayerDetails \(resp.count)")
                maxDays = max(events.maxDays, 30)
                selectedDays = min(maxDays, 7)
                events = resp
            }
        }
    }

    var body: some View {
        List {
            if selectedTab == .events {
                TabBar(selectedTab: $selectedTab)
                EventsListView(events: $events)
            } else {
                VStack {
                    if(events.count > 2) {
                        TabBar(selectedTab: $selectedTab)
                    }
                    SliderView(selectedDays: $selectedDays, maxDays: $maxDays)
                    PrayerScatterTotalView(title: "Total", events: events.prayersByDate(days: Int(selectedDays)))
                    PrayerScatterView(title: "Individual",  events: events.prayersByDate(days: Int(selectedDays)))
                }
            }
        }
        .onAppear(perform: fetchPrayerDetails)
    }
}

extension [EventModel] {
    func prayersByDate(days: Int) -> [(Date, Prayer)] {
        let filteredEvents = self.filter { event in
            let eventDate = event.date
            let localEventDate = eventDate.toLocal
            return localEventDate >= Calendar.currentInLocal.date(byAdding: .day, value: -days, to: Date())!
        }
        
        let groupedEvents = Dictionary(grouping: filteredEvents) { $0.date }
        var prayers: [(Date, Prayer)] = []
        for (date, events) in groupedEvents {
            let fajr = events.contains { $0.metadata?.prayerData?.name?.contains("fajr") ?? false }
            let dhuhr = events.contains { $0.metadata?.prayerData?.name?.contains("dhuhr") ?? false }
            let asr = events.contains { $0.metadata?.prayerData?.name?.contains("asr") ?? false }
            let maghrib = events.contains { $0.metadata?.prayerData?.name?.contains("magrib") ?? false }
            let isha = events.contains { $0.metadata?.prayerData?.name?.contains("isha") ?? false }
            prayers.append((date, Prayer(fajr: fajr, dhuhr: dhuhr, asr: asr, maghrib: maghrib, isha: isha)))
        }
        return prayers.sorted(by: { $0.0 < $1.0 })
    }
}

struct PrayerScatterTotalView: View {
    var title: String
    var events: [(Date, Prayer)]
    var showLine: Bool = false
    var body: some View {
        
        return Section(header: Text(title)) {
            Chart(events, id: \.0) {
                    PointMark(
                        x: .value("x data", $0),
                        y: .value("y data",  $1.total)
                    ).foregroundStyle(Color.gray)

            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    configureAxisLabel(for: value, dataCount: events.count)
                }
            }
            .frame(height: 200)
            .padding()
        }
    }
}

struct PrayerScatterView: View {
    var title: String
    var events: [(Date, Prayer)]
    var showLine: Bool = false
    var body: some View {
        
        return Section(header: Text(title)) {
            Chart(events, id: \.0) {
                    PointMark(
                        x: .value("x data", Calendar.current.startOfDay(for:$0)),
                        y: .value("y data",  5)
                    ).foregroundStyle($1.fajr ? Color.black : Color.white)
                    PointMark(
                        x: .value("x data", Calendar.current.startOfDay(for:$0)),
                        y: .value("y data",  4)
                    ).foregroundStyle($1.dhuhr ? Color.black : Color.white)
                    PointMark(
                        x: .value("x data", Calendar.current.startOfDay(for:$0)),
                        y: .value("y data",  3)
                    ).foregroundStyle($1.asr ? Color.black : Color.white)
                    PointMark(
                        x: .value("x data", Calendar.current.startOfDay(for:$0)),
                        y: .value("y data",  2)
                    ).foregroundStyle($1.maghrib ? Color.black : Color.white)
                    PointMark(
                        x: .value("x data", Calendar.current.startOfDay(for:$0)),
                        y: .value("y data",  1)
                    ).foregroundStyle($1.isha ? Color.black : Color.white)
            }
            .chartYAxis {
                AxisMarks(values: ["fajr", "dhuhr", "asr", "maghrib", "isha"])
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    configureAxisLabel(for: value, dataCount: events.count)
                }
            }
            .frame(height: 200)
            .padding()
        }
    }
}

