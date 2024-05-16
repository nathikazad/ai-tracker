import SwiftUI

struct SleepView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var events: [EventModel] = []
    @State private var selectedDays: Double = 7
    @State private var maxDays: Double = 7
    @State private var selectedTab: SelectedTab = .graphs


    private func fetchSleepDetails() {
        Task {
            let userId: Int? = Authentication.shared.userId
            let resp = await EventsController.fetchEvents(userId: userId!, eventType: "sleeping", order: "desc")
            DispatchQueue.main.async {
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
                    CountView(selectedDays: $selectedDays, maxDays: $maxDays, events:$events)
                    GraphView(selectedDays: $selectedDays, events:$events, offsetHours: 5)
                }
            }
        }
        .onAppear(perform: fetchSleepDetails)
    }
}

