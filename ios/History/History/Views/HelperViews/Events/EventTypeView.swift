import SwiftUI

struct EventTypeView: View {
    @State var events: [EventModel] = []
    @State private var selectedDays: Double = 7
    @State private var maxDays: Double = 7
    @State private var selectedTab: SelectedTab = .graphs
    
    var eventType: EventType

    private func fetchEventDetails() {
        Task {
            let userId: Int? = auth.userId
            let resp = await EventsController.fetchEvents(userId: userId!, eventType: eventType, order: "desc")
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
        .onAppear(perform: fetchEventDetails)
    }
}

