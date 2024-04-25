import SwiftUI
import MapKit
import Charts

struct SleepView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var events: [EventModel] = []
    @State private var selectedDays: Double = 7
    @State private var maxDays: Double = 7
    
    
    
    var dailyTotals: [(String, Double)] {
        EventsController.dailyTotals(events: events, days: Int(selectedDays))
    }
    
    private func fetchSleepDetails() {
        Task {
            let userId: Int? = Authentication.shared.userId
            let resp = await EventsController.fetchEvents(userId: userId!, eventType: "sleep", order: "desc")
            DispatchQueue.main.async {
                maxDays = EventsController.maxDays(events: resp)
                selectedDays = min(maxDays, 7)
                events = resp
            }
        }
    }
    
    var body: some View {
        
        Section(header: Text("Sleep")) {
            List {
                Section(header: Text("Hours slept per day")) {
                    HStack {
                        Slider(value: $selectedDays, in: 1...max(maxDays, 1), step: 1)
                            .accentColor(.gray)
                        Text("\(Int(selectedDays))")
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                    Chart {
                        ForEach(dailyTotals, id: \.0) { day, hours in
                            BarMark(
                                x: .value("Day", day),
                                y: .value("Hours", hours)
                            )
                            .foregroundStyle(Color.gray)
                        }
                    }
                    .frame(height: 200)
                    .padding(.horizontal)
                }
                
                Section(header: Text("Events")) {
                    ForEach(events, id: \.id) { event in
//                        if(event.startTime != nil) {
                            Text(event.formattedTimeWithDateAndX)
                                .font(.subheadline)
//                        }
                    }
                }
            }
            .onAppear {
                fetchSleepDetails()
            }
        }
    }
}
