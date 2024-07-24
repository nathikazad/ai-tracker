//
//  CalendarPicker.swift
//  History
//
//  Created by Nathik Azad on 4/23/24.
//

import SwiftUI

extension AppState {
    func goToNextDay() {
        print("next day")
        currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
        notifyCoreStateChanged()
    }
    
    func goToPreviousDay() {
        print("previous day")
        currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate)!
        notifyCoreStateChanged()
    }
    
    func goToDay(newDay:Date? = nil) {
        if let newDay = newDay {
            currentDate = Calendar.current.startOfDay(for:newDay)
        } else {
            currentDate = Calendar.current.startOfDay(for: Date())
        }
        notifyCoreStateChanged()
    }
    
    var isItToday: Bool {
        print("isItToday \(state.currentDate.toUTCString) \(Calendar.current.startOfDay(for: Date()).toUTCString) \(state.currentDate == Calendar.current.startOfDay(for: Date()))")
        return state.currentDate == Calendar.current.startOfDay(for: Date())
    }
}

struct CalendarButton: View {
    @ObservedObject var appState = state
    
    var body: some View {
        HStack {
            Spacer()
            if !appState.isItToday {
                Button(action: {
                    state.goToDay()
                }) {
                    Image(systemName: "arrow.clockwise.circle.fill")
                }
            }
            Button(action: {
                state.showSheet(newSheetToShow: .calendar)
            }) {
                Text(appState.currentDate.formattedDateForCalendar)
                    .foregroundColor(.primary)
                    .gesture(
                        DragGesture().onEnded { gesture in
                            if gesture.translation.width < 0 { // swipe left
                                state.goToNextDay()
                            } else if gesture.translation.width > 0 { // swipe right
                                state.goToPreviousDay()
                            }
                        }
                    )
            }
            Spacer()

        }
        .padding(.top, 5)
    }
}

struct CalendarPickerView: View {
    @State private var selectedDate = state.currentDate
    let onDateSelected: (Date) -> Void
    
    init(onDateSelected: @escaping (Date) -> Void) {
        self.onDateSelected = onDateSelected
    }
    
    var body: some View {
        VStack {
            DatePicker("Select a date", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()
                .onChange(of: selectedDate, perform: { value in
                    onDateSelected(value)
                })
            
        }
    }
}
