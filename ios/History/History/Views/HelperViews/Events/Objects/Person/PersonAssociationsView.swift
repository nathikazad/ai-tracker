//
//  PersonAssociations.swift
//  History
//
//  Created by Nathik Azad on 5/31/24.
//

import SwiftUI

enum Category: String, CaseIterable, Identifiable {
    case events = "Events"
    case socialEvents = "Social Events"
    case location = "Location"
    case people = "People"
    
    var id: String { self.rawValue }
    
    // Each category now includes an appropriate image name
    var imageName: String {
        switch self {
        case .events:
            return "calendar"
        case .socialEvents:
            return "person.3.fill"
        case .location:
            return "map.fill"
        case .people:
            return "person.crop.circle"
        }
    }
}


struct PersonAssociationsView: View {
    @Binding var person: Person
    @State private var selectedCategory: Category = .events
    var categories: [Category] {
        var c:[Category] = []
        //         [.events, .socialEvents, .location]
        c.append(.events)
        if (person.rootEvents.flattenLocations.count > 0) {
            c.append(.location)
        }
        if (person.rootEvents.flattenObjects.socialEvents.count > 0) {
            c.append(.socialEvents)
        }
        
        return c
    }
    var body: some View {
        if categories.count > 0
        {
            Picker("Select Category", selection: $selectedCategory) {
                ForEach(categories, id: \.self) { category in
                    HStack {
                        Image(systemName: category.imageName) // Display the image next to the text
                            .foregroundColor(.blue)
                    }
                    .tag(category)
                }
            }
            .pickerStyle(SegmentedPickerStyle()) // You can choose the style you prefer
        }
        switch selectedCategory {
        case .events:
            EventsListView(events: $person.events)
        case .socialEvents:
            Section {
                List(person.rootEvents.flattenObjects.socialEvents, id: \.id) { socialEvent in
                    NavigationButton(destination: PersonView(personId: person.id!)) {
                        Text("\(socialEvent.name.capitalized)")
                    }
                }
            }
        case .location:
            Section {
                List(person.rootEvents.flattenLocations, id: \.id) { location in
                    NavigationLink(destination: LocationDetailView(location: location)) {
                        Text("\(location.name!.capitalized)")
                    }
                }
            }
        default:
            EmptyView()
        }
    }
}
