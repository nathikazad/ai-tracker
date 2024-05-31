//
//  Notes.swift
//  History
//
//  Created by Nathik Azad on 5/27/24.
//

import SwiftUI

class NoteStruct: ObservableObject {
    @Published var showInPopup: ShowInPopup = .none
    @Published var newDate: Date = Date()
    @Published var showPopupForDate: Date = Date()
    @Published var draftContent = ""
}

struct NotesView: View {
    @Binding var event: EventModel?
    @Binding var showCamera: Bool
    @Binding var selectedImage: UIImage?
    @State private var editMode: Bool = false
    @StateObject var noteStruct: NoteStruct
    
    
    var createNoteAction: (Int) -> Void
    
    var body: some View {
        if(event != nil) {
            let notes: [Date: String] = event?.metadata?.notes ?? [:]
            Section(header: Text("Notes")) {
                List {                    
                    ForEach(event!.notes, id: \.1) { date, note in
                        HStack {
                            Text(date.formattedTime)
                                .font(.headline)
                                .frame(width: 100, alignment: .leading)
                                .onTapGesture {
                                    noteStruct.showInPopup = .modifyDate
                                    noteStruct.newDate = date
                                    noteStruct.showPopupForDate = date
                                }
                            Divider()
                            Text(note)
                                .onTapGesture {
                                    print("tapped")
                                    noteStruct.showInPopup = .modifyText
                                    noteStruct.draftContent = note
                                    noteStruct.showPopupForDate = date
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
                    if let images = event?.metadata?.images, images.count > 0 {
                        HorizontalImageView(images: images, editMode: $editMode, selectedImage: $selectedImage) {
                            imageLocation in
                            var newImages = images.filter({$0 != imageLocation})
                            deleteImage(location: imageLocation)
                            EventsController.editEvent(id: event!.id, images: newImages)
                            
                        }
                    }
                    HStack(spacing: 10) {
                        Spacer()
                        Button(action: {
                            print("Clicked plus")
                            createNoteAction(event!.id)
                        }) {
                            Image(systemName: "plus.circle")
                        }
                        .buttonStyle(HighPriorityButtonStyle())
                        
                        Button(action: {
                            print("Clicked camera")
                            self.showCamera.toggle()
                        }) {
                            Image(systemName: "camera")
                        }
                        .buttonStyle(HighPriorityButtonStyle())
                        
                        if (event?.metadata?.images.count ?? 0) > 0 {
                            Button(action: {
                                print("Clicked camera")
                                editMode.toggle()
                            }) {
                                Image(systemName: editMode ? "xmark.circle" : "pencil.circle")
                            }
                            .buttonStyle(HighPriorityButtonStyle())
                        }
                        
                        Spacer()
                        
                    }
                }
            }
        }
    }
}

struct NotesPopup: View {
    @StateObject var noteStruct: NoteStruct
    @Binding var event: EventModel?
    var eventId: Int
    var body: some View {
        if(noteStruct.showInPopup == .modifyDate) {
            PopupViewForDate(selectedTime: $noteStruct.newDate,
                             saveAction: {
                DispatchQueue.main.async {
                    if var notes = event?.metadata?.notesToJson {
                        let content = notes[noteStruct.showPopupForDate.toUTCString]
                        notes.removeValue(forKey: noteStruct.showPopupForDate.toUTCString)
                        notes[noteStruct.newDate.toUTCString] = content
                        EventsController.editEvent(id: eventId, notes: notes)
                    }
                    closePopup()
                }
            }, closeAction: closePopup)
        } else if noteStruct.showInPopup == .modifyText {
            PopupViewForText(draftContent: $noteStruct.draftContent,
                             saveAction: {
                DispatchQueue.main.async {
                    if var notes = event?.metadata?.notesToJson {
                        notes[noteStruct.showPopupForDate.toUTCString] = noteStruct.draftContent
                        EventsController.editEvent(id: eventId, notes: notes)
                    }
                    closePopup()
                }
            }, closeAction: closePopup
            )
        }
    }
    
    func closePopup() {
        noteStruct.showInPopup = .none
        noteStruct.draftContent = ""
    }
}

struct MinimizedNoteView: View {
    var notes: [Date: String]
    var level: Int
    var body: some View {
        ForEach(Array(notes.keys).sorted(by: <), id: \.self) { date in
            if let note = notes[date] {
                HStack {
                    if(level > 0) {
                        Rectangle()
                            .frame(width: 4)
                            .foregroundColor(Color.gray)
                            .padding(.leading, CGFloat(level * 4))
                    }
                    Text(date.formattedTime)
                        .font(.headline)
                        .frame(width: 100, alignment: .leading)
                    Divider()
                    Text(note)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.subheadline)
                }
            }
        }
    }
}
