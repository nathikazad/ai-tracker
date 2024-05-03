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
                        CountView(selectedDays: $selectedDays, maxDays: $maxDays, events:$events)
                        GraphView(selectedDays: $selectedDays, events:$events)
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
