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
            let userId: Int? = auth.userId
            let resp = await EventsController.fetchEvents(userId: userId!, eventType: .praying, order: "desc")
            DispatchQueue.main.async {
                print("fetchPrayerDetails \(resp.count)")
                maxDays = max(events.maxDays, 30)
                selectedDays = min(maxDays, 7)
                events = resp.flatten
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
                    PrayerStatsView(selectedDays: $selectedDays, events: $events)
                    PrayerScatterTotalView(title: "Daily Count", events: events.prayersByDate(days: Int(selectedDays)))
                    Divider()
                        .padding(.vertical, 20)
                    PrayerScatterView(title: "Individual Count",  events: events.prayersByDate(days: Int(selectedDays)))
                }
            }
        }
        .onAppear(perform: fetchPrayerDetails)
    }
}

extension [EventModel] {
    func filterPrayers(days: Int) -> [EventModel] {
        return self.filter { event in
            let eventDate = event.date.startOfDay
            let localEventDate = eventDate.toLocal
            return localEventDate >= Calendar.currentInLocal.date(byAdding: .day, value: -days, to: Date())!
        }
    }
    
    // return tuple of number of prayers prayed vs total number of days
    func totalLastNdays(days: Int) -> (Int, Int, Double) {
        // total number of prayers in the last n days by summing the total number of prayers for each day
        let filteredPrayers = self.filterPrayers(days: days)
        let totalPrayed = filteredPrayers.reduce(0) { $0 + ($1.metadata?.prayerData?.count ?? 0) }
        let totalPossible = (filteredPrayers.numDays + 1) * 5 + (filteredPrayers.last?.metadata?.prayerData?.count ?? 0)
        return (totalPrayed, totalPossible, totalPrayed > 0 && totalPossible > 0 ? Double(totalPrayed) / Double(totalPossible) : 0)
    }
    
    func prayersByDate(days: Int) -> [(Date, Prayer)] {
        let filteredEvents = filterPrayers(days: days)
        
        let groupedEvents = Dictionary(grouping: filteredEvents) { $0.date.startOfDay }
        var prayers: [(Date, Prayer)] = []
        for (date, events) in groupedEvents {
            let fajr = events.contains { $0.metadata?.prayerData?.name?.contains("fajr") ?? false }
            let dhuhr = events.contains { $0.metadata?.prayerData?.name?.contains("dhuhr") ?? false }
            let asr = events.contains { $0.metadata?.prayerData?.name?.contains("asr") ?? false }
            let maghrib = events.contains { $0.metadata?.prayerData?.name?.contains("magrib") ?? false }
            let maghrib2 = events.contains {  $0.metadata?.prayerData?.name?.contains("maghrib")  ?? false }
            let isha = events.contains { $0.metadata?.prayerData?.name?.contains("isha") ?? false }
            prayers.append((date, Prayer(fajr: fajr, dhuhr: dhuhr, asr: asr, maghrib: maghrib || maghrib2, isha: isha)))
        }
        return prayers.sorted(by: { $0.0 < $1.0 })
    }
}

struct PrayerScatterTotalView: View {
    var title: String
    var events: [(Date, Prayer)]
    var showLine: Bool = false

    var numDays: Int {
        let minDate = events.min { $0.0 < $1.0 }?.0 ?? Date()
        let maxDate = events.max { $0.0 < $1.0 }?.0 ?? Date()
        return Calendar.current.dateComponents([.day], from: minDate, to: maxDate).day ?? 0
    }

    var body: some View {
        
        return Section {
            Chart(events, id: \.0) {
                    PointMark(
                        x: .value("x data", $0),
                        y: .value("y data",  $1.total)
                    ).foregroundStyle(Color.gray)

            }
            .chartXAxis {
                configureXAxis(count: numDays)
            }
            .frame(height: 200)
            .padding()
            HStack {
                Spacer()
                Text(title)
                    .font(.title3)
                    .foregroundColor(.primary)
                Spacer()
            }
        }
    }
}

struct PrayerStatsView: View {
    @Binding var selectedDays: Double
    @Binding var events: [EventModel]
    var body: some View {
        HStack {
            let (totalPrayed, totalPossible, percentage) = events.totalLastNdays(days: Int(selectedDays))
            let percentageString = String(format: "%.2f", percentage * 100)
            HStack {
                Text("Prayed: \(totalPrayed) / \(totalPossible) (\(percentageString)%)")
                    .foregroundColor(.gray)
                Text("-\(totalPossible-totalPrayed)")
                    .foregroundColor(.red)
            }

        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding()
    }
}

struct PrayerScatterView: View {
    var title: String
    var events: [(Date, Prayer)]
    var showLine: Bool = false
    let prayerNames = ["Isha", "Maghrib", "Asr", "Dhuhr", "Fajr"]
    var body: some View {
        
        return Section {
            Chart(events, id: \.0) {
                if $1.fajr {
                    PointMark(
                        x: .value("x data", Calendar.current.startOfDay(for:$0)),
                        y: .value("y data",  4)
                    ).foregroundStyle(Color.gray)
                }
                if $1.dhuhr {
                    PointMark(
                        x: .value("x data", Calendar.current.startOfDay(for:$0)),
                        y: .value("y data",  3)
                    ).foregroundStyle(Color.gray)
                }
                if $1.asr {
                    PointMark(
                        x: .value("x data", Calendar.current.startOfDay(for:$0)),
                        y: .value("y data",  2)
                    ).foregroundStyle(Color.gray)
                }
                if $1.maghrib {
                    PointMark(
                        x: .value("x data", Calendar.current.startOfDay(for:$0)),
                        y: .value("y data",  1)
                    ).foregroundStyle(Color.gray)
                }
                if $1.isha {
                    PointMark(
                        x: .value("x data", Calendar.current.startOfDay(for:$0)),
                        y: .value("y data",  0)
                    ).foregroundStyle(Color.gray)
                }
            }
            .chartYAxis {
                AxisMarks(values: [0, 1, 2, 3, 4]) { value in
                    AxisValueLabel {
                        Text(prayerNames[value.index])
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .offset(x: 5)
                    AxisGridLine()
                }
            }
            .chartXAxis {
                configureXAxis(count: events.count)
            }
            .frame(height: 200)
            .padding()
            // display the title centered below the chart
            HStack {
                Spacer()
                Text(title)
                    .font(.title3)
                    .foregroundColor(.primary)
                Spacer()
            }
        }
    }
}

