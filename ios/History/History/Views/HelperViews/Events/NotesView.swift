//
//  WorkView.swift
//  History
//
//  Created by Nathik Azad on 5/23/24.
//


import SwiftUI
struct NotesView: View {
    @State var event: EventModel? = nil
    @State var chatViewPresented: Bool = false
    @State private var showInPopup: ShowInPopup = .none
    @State private var newDate: Date = Date()
    @State private var showPopupForDate: Date = Date()
    @State private var draftContent = ""
    var eventId: Int
    var title: String
    
    
    var subscriptionId: String {
        return "work\(eventId)"
    }

    var body: some View {
        List {
            let notes: [Date: String] = event?.metadata?.notes ?? [:]
            ForEach(Array(notes.keys).sorted(by: <), id: \.self) { date in
                if let note = notes[date] {
                    HStack {
                        Text(date.formattedTime)
                            .font(.headline)
                            .frame(width: 100, alignment: .leading)
                            .onTapGesture {
                                showInPopup = .date
                                newDate = date
                                showPopupForDate = date
                            }
                        Divider()
                        Text(note)
                        .onTapGesture {
                            showInPopup = .text
                            draftContent = note
                            showPopupForDate = date
                        }
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(action: {
                            print("Deleting note \(eventId) \(date)")
                            if var notes = event?.metadata?.notesToJson {
                                notes.removeValue(forKey: date.toUTCString)
                                EventsController.editEvent(id: eventId, notes: notes)
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
                state.setParentEventId(eventId)
                chatViewPresented = true
            }) {
                Image(systemName: "plus.circle")
            }
            .frame(maxWidth: .infinity, alignment: .center)
            
        }
        
        .onAppear {
            EventsController.listenToEvent(id: eventId, subscriptionId: subscriptionId) {
                event in
                print("WorkView: listenToEvent: new event")
                DispatchQueue.main.async {
                    self.event = nil
                    self.event = event
                }
            }
        }
        .onDisappear {
            EventsController.cancelListener(subscriptionId: subscriptionId)
        }
        .navigationTitle("\(title)(\(String(eventId)))")
        .fullScreenCover(isPresented: $chatViewPresented) {
            ChatView {
                chatViewPresented = false
            }
        }
        .overlay {
            popupView
        }
    }
    
    private var popupView: some View {
        Group {
            if(showInPopup == .date) {
                popupViewForDate(selectedTime: $newDate,
                                 saveAction: {
                    DispatchQueue.main.async {
                        if var notes = event?.metadata?.notesToJson {
                            let content = notes[showPopupForDate.toUTCString]
                            notes.removeValue(forKey: showPopupForDate.toUTCString)
                            notes[newDate.toUTCString] = content
                            EventsController.editEvent(id: eventId, notes: notes)
                        }
                        closePopup()
                    }
                }, closeAction: closePopup)
            } else if showInPopup == .text {
                popupViewForText(draftContent: $draftContent,
                                 saveAction: {
                    DispatchQueue.main.async {
                        if var notes = event?.metadata?.notesToJson {
                            notes[showPopupForDate.toUTCString] = draftContent
                            EventsController.editEvent(id: eventId, notes: notes)
                        }
                        closePopup()
                    }
                }, closeAction: closePopup
                )
            }
        }
    }
    
    func closePopup() {
        showInPopup = .none
        draftContent = ""
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
