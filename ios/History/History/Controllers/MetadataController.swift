//
//  MetadataController.swift
//  History
//
//  Created by Nathik Azad on 5/29/24.
//

import Foundation

class MetadataController {
    static func removePerson(event: EventModel, personName: String) {
        var meetingData = event.metadata!.meetingData
        meetingData!.people = meetingData!.people!.filter { $0.name != personName }
        do {
            try EventsController.editEvent(id: event.id, metadata: ["meeting": meetingData!.toJson()])
        } catch {
            print("Error encoding or converting to dictionary: \(error)")
        }
    }
}
