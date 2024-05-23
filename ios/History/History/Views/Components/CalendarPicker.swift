//
//  CalendarPicker.swift
//  History
//
//  Created by Nathik Azad on 4/23/24.
//

import SwiftUI

struct CalendarButton: View {
    @ObservedObject var state = AppState.shared
    
    var body: some View {
        Button(action: {
            AppState.shared.showSheet(newSheetToShow: .calendar)
        }) {
            Text(state.currentDate.formattedDateForCalendar)
                .foregroundColor(.primary)
                .padding(.top, 5)
                .frame(maxWidth: .infinity, alignment: .center)
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
