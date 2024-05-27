//
//  Notes.swift
//  History
//
//  Created by Nathik Azad on 5/27/24.
//

import SwiftUI
struct NotesView: View {
    @Binding var event: EventModel?
    var editDateAction: (Date) -> Void
    var editTextAction: (Date, String) -> Void
    var createNoteAction: (Int) -> Void
    
    var body: some View {
        if(event != nil) {
            let notes: [Date: String] = event?.metadata?.notes ?? [:]
            Section(header: Text("Notes")) {
                List {
                    ForEach(Array(notes.keys).sorted(by: <), id: \.self) { date in
                        if let note = notes[date] {
                            HStack {
                                Text(date.formattedTime)
                                    .font(.headline)
                                    .frame(width: 100, alignment: .leading)
                                    .onTapGesture {
                                        editDateAction(date)
                                    }
                                Divider()
                                Text(note)
                                    .onTapGesture {
                                        editTextAction(date, note)
                                    }
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(action: {
                                    print("Deleting note \(event!.id) \(date)")
                                    if var notes = event?.metadata?.notesToJson {
                                        notes.removeValue(forKey: date.toUTCString)
                                        EventsController.editEvent(id: event!.id, notes: notes)
                                    }
                                }) {
                                    Image(systemName: "trash.fill")
                                }
                                .tint(.red)
                            }
                        }
                    }
                    Button(action: {
                        print("Clicked plus")
                        print("WorkView: body: \(state.navigationStackIds)")
                        createNoteAction(event!.id)
                    }) {
                        Image(systemName: "plus.circle")
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
    }
}
