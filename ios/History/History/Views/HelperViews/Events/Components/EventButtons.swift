//
//  EventButtons.swift
//  History
//
//  Created by Nathik Azad on 5/27/24.
//

import SwiftUI

struct EventButtonsView: View {
    var event: EventModel
    @Binding var reassignParentForId: Int?
    @Binding var expandedEventIds: Set<Int>

    var body: some View {
        if reassignParentForId != nil {
            reassignThisParentButton
        } else if event.children.count > 0 || event.hasNotes {
            expandOrCollapseButton
        }
    }
    
    private var reassignThisParentButton: some View {
        if reassignParentForId == event.id {
            return Button(action: {
                reassignParentForId = nil
            }) {
                Image(systemName: "xmark")
            }
            .buttonStyle(HighPriorityButtonStyle())
        } else {
            return Button(action: {
                EventsController.editEvent(id: reassignParentForId!, parentId: event.id)
                reassignParentForId = nil
            }) {
                Image(systemName: "arrow.left.circle.fill")
            }
            .buttonStyle(HighPriorityButtonStyle())
        }
    }
    
    private var expandOrCollapseButton: some View {
        Button(action: {
            if expandedEventIds.contains(event.id) {
                expandedEventIds.remove(event.id)
            } else {
                expandedEventIds.insert(event.id)
            }
        }) {
            if expandedEventIds.contains(event.id) {
                        Image(systemName: "minus.circle")
                    } else {
                        Image(systemName: "plus.circle")
                    }
                }
                .buttonStyle(HighPriorityButtonStyle())
            }
}

