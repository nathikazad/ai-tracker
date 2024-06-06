//
//  EventDestination.swift
//  History
//
//  Created by Nathik Azad on 5/27/24.
//
import SwiftUI
struct EventDestination: View {
    var event: EventModel
    var destination: AnyView?
    var body: some View {
        if let destination = destination ?? eventDestination(for: event) {
            return AnyView(
                NavigationLink(destination: destination) {
                    EmptyView()
                }
                .padding(.horizontal, 10)
                .opacity(0)
            )
        } else {
            return AnyView(EmptyView())
        }
    }
}

private func eventDestination(for event: EventModel) -> AnyView? {
    switch event.eventType {
//    case .staying:
//        if let location = event.location {
//            return AnyView(LocationDetailView(location: location))
//        }
//        case .commuting:
//            if let polyline = event.metadata?.polyline {
//                return AnyView(PolylineView(encodedPolyline: polyline))
//            }

    case .sleeping:
        return AnyView(EventTypeView(eventType: .sleeping))
    case .praying:
        return AnyView(PrayerView())
    case .learning:
        if let skill = event.metadata?.learningData?.skill {
            return AnyView(LearnView(skill: skill))
        }
    default:
        return AnyView(GenericEventView(eventId: event.id))
    }
    return nil
}
