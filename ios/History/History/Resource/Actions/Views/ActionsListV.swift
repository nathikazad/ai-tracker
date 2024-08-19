//
//  CreateActionView.swift
//  History
//
//  Created by Nathik Azad on 7/22/24.
//

import SwiftUI

struct ListActionsView: View {
    var actionType: ActionTypeModel
    var actionTypeName: String
    @State var actions: [ActionModel] = []
    var createAction: ((ActionTypeModel) -> Void)?
    var withDate: Bool = true
    var body: some View {
        let groupedEvents = Dictionary(grouping: actions) { $0.formattedDate }
        
        let sortedDates = groupedEvents.keys.sorted(by: { (date1, date2) -> Bool in
            let date1Components = date1.split(separator: " ")
            let date2Components = date2.split(separator: " ")
            
            guard !date1Components.isEmpty, !date2Components.isEmpty, date1Components.count == 2, date2Components.count == 2 else {
                return false
            }
            
            return date1Components[1] > date2Components[1]
        })
        
        List {
            ForEach(sortedDates, id: \.self) { date in
                Section(header: Text(date)) {
                    let events = groupedEvents[date]?.sorted(by: { $0.startTime < $1.startTime }) ?? []
                    ForEach(events, id: \.id) { action in
                        ActionRow(event: action, fetchActions: {
                            // Implement your fetch logic here
                        }, includeActionName: false)
                    }
                }
            }
        }
        .navigationTitle( "\(actionTypeName)")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: ShowActionView(actionTypeId: actionType.id!)) {
                    Image(systemName: "plus")
                        .foregroundColor(.primary)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: ActionTypeView(
                    model: actionType
                )) {
                    Image(systemName: "gear")
                }
            }
        }
        .onAppear {
            Task {
                self.actions = await ActionController.fetchActions(userId: Authentication.shared.userId!, actionTypeId: actionType.id, withObjectConnections: true)
                print(self.actions.count)
            }
        }
    }
}



//var body: some View {
    // Group events by their formatted date
    
    
//    ForEach(sortedDates, id: \.self) { date in
//        Section(header:
//            HStack
//            {
//            if withDate {
//                Text(date)
//                Spacer()
//                let dateIds = Set(groupedEvents[date]!.withChildrenOrNotes.map { $0.id })
//                if(dateIds.count > 1) {
//                    Button(action: {
//                        if expandedEventIds.intersection(dateIds).isEmpty {
//                            expandedEventIds.formUnion(dateIds)
//                        } else {
//                            expandedEventIds.subtract(dateIds)
//                        }
//                        print(expandedEventIds)
//                    }) {
//                        if expandedEventIds.intersection(dateIds).isEmpty {
//                            Image(systemName: "plus.circle")
//                        } else {
//                            Image(systemName: "minus.circle")
//                        }
//                    }
//                }
//            }
//        }
//        ) {
//            ForEach(groupedEvents[date]!) { event in
//                eventRow(event)
//                if expandedEventIds.contains(event.id) {
//                    MinimizedNoteView(notes: event.metadata!.notes, level: 1)
//                    ForEach(event.children.sortEvents, id: \.id) { child in
//                        eventRow(child, level: 1)
//                        if expandedEventIds.contains(child.id) {
//                            MinimizedNoteView(notes: child.metadata!.notes, level:2)
//                            ForEach(child.children.sortEvents, id: \.id) { grandChild in
//                                eventRow(grandChild, level: 2)
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
//}
//private func eventRow(_ event: EventModel, level: Int = 0) -> EventRow {
//    return EventRow(
//        event: event,
//        reassignParentForId: $reassignParentForId,
//        expandedEventIds: $expandedEventIds,
//        dateClickedAction: { event in
//            
//        },
//        level: level)
//}
//}



