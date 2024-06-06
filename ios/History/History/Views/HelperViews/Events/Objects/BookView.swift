//
////
////  BookView.swift
////  History
////
////  Created by Nathik Azad on 5/17/24.
////
//
//
//import SwiftUI
//
//
//import SwiftUI
//
import SwiftUI
struct BookView: View {
    let bookId: Int
    @State private var book: ASObject?
    @State private var events: [EventModel] = []
    
    var body: some View {
        VStack {
            if book != nil {
                List {
                    Section(header: Text("Book Details")) {
                        Text("Date started: \(book!.firstEventDate?.formattedShortDateAndTime ?? "Unknown")")
                        Text("Date finished: \(book!.lastEventDate?.formattedShortDateAndTime ?? "Unknown")")
                        // round to 2 decimal places
                        let duration: String = String(format: "%.2f", book!.totalDurationInHours)
                        Text("Time Read: \(duration) hours")
                    }
                    EventsListView(events: $events)
                }
            } else {
                Text("No book")
                    .onAppear {
                        fetchBook()
                    }
            }
        }
        .navigationTitle(book?.name ?? "Book")
    }
    
    private func fetchBook() {
        Task {
            let resp = await ObjectController.fetchObject(type:ASObject.self, objectId: bookId)
            DispatchQueue.main.async {
                book = resp
                if let bookEvents = book?.events {
                    self.events = bookEvents
                }
            }
        }
    }
}
//
class BookStruct: ObservableObject {
    @Published var showInPopup: ShowInPopup = .none
    @Published var newDate: Date = Date()
    @Published var showPopupForDate: Date = Date()
    @Published var draftContent = ""
}

struct MinBooksView: View {
    @Binding var event: EventModel?
    @StateObject var bookStruct: BookStruct
//    var createBookAction: (Int) -> Void
    
    var body: some View {
        if event?.eventType == .reading {
                if let book: ASObject = event?.book {
                    NavigationLink(destination: BookView(bookId: book.id!)) {
                        Text("Book: \(book.name)")
                    }
                } else if let bookName = event?.metadata?.readingData?.name {
                    HStack {
                        Text("Book: \(bookName)")
                        Spacer()
                        Button(action: {
                            print("Clicked plus")
        //                    createBookAction(event!.id)
                        }) {
                            Text("Track")
                        }
                        .buttonStyle(.bordered)
                        .cornerRadius(10)
                    }
                } else {
                    Button(action: {
                        print("Clicked plus")
                        print("WorkView: body: \(state.navigationStackIds)")
    //                    createBookAction(event!.id)
                    }) {
                        Image(systemName: "plus.circle")
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                    //                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    //                                Button(action: {
                    //                                    print("Deleting note \(event!.id) \(date)")
                    //                                    if var notes = event?.metadata?.notesToJson {
                    //                                        notes.removeValue(forKey: date.toUTCString)
                    //                                        EventsController.editEvent(id: event!.id, notes: notes)
                    //                                    }
                    //                                }) {
                    //                                    Image(systemName: "trash.fill")
                    //                                }
                    //                                .tint(.red)
                    //                            }
//                }
            }
        }
}


struct BooksPopup: View {
    @StateObject var noteStruct: BookStruct
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
            PopupViewForText(
                title: "Edit Note",
                draftContent: $noteStruct.draftContent,
                closeAction: closePopup
                             
            ) {
                DispatchQueue.main.async {
                    if var notes = event?.metadata?.notesToJson {
                        notes[noteStruct.showPopupForDate.toUTCString] = noteStruct.draftContent
                        EventsController.editEvent(id: eventId, notes: notes)
                    }
                    closePopup()
                }
            }
        }
    }
    
    func closePopup() {
        noteStruct.showInPopup = .none
        noteStruct.draftContent = ""
    }
}

