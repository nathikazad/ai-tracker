//
//  LearnView.swift
//  History
//
//  Created by Nathik Azad on 5/16/24.
//

import Foundation

import SwiftUI

struct LearnView: View {
    @State var skill: String?
    @State var events: [EventModel] = []
    @State private var selectedDays: Double = 7
    @State private var maxDays: Double = 7
    @State private var selectedTab: SelectedTab = .graphs


    private func fetchSleepDetails() {
        Task {
            let userId: Int? = Authentication.shared.userId
            var metadatafilter: [String: Any]? = nil
            if(skill != nil) {
                metadatafilter = ["learning": ["skill": skill]]
            }
            let resp = await EventsController.fetchEvents(userId: userId!,
                                                          eventType: "learning",
                                                          order: "desc",
                                                          metadataFilter: metadatafilter)
            DispatchQueue.main.async {
                maxDays = max(events.maxDays, 30)
                selectedDays = min(maxDays, 7)
                events = resp
                print(events.count)
            }
        }
    }

    var body: some View {
        if(skill != nil) {
            Text("Learning \(skill!.capitalized)")
                .font(.title)
                .padding()
        }
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
                    GraphView(selectedDays: $selectedDays, events:$events, automaticYAxis: true)
                }
            }
        }
        .onAppear(perform: fetchSleepDetails)
    }
}

