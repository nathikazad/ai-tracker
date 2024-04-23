//
//  CalendarPicker.swift
//  History
//
//  Created by Nathik Azad on 4/23/24.
//

import SwiftUI

struct CalendarPickerView: View {
    @State private var selectedDate = Date()
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

// TODO: Come back to this
//struct TimePickerView: View {
//    @State private var selectedTime: Date
//    let onTimeSelected: (Date) -> Void
//    
//    var body: some View {
//        VStack {
//            DatePicker("Select a time", selection: $selectedTime, displayedComponents: .hourAndMinute)
//                .datePickerStyle(WheelDatePickerStyle())
//                .padding()
//                .onChange(of: selectedTime, perform: { value in
//                    onTimeSelected(value)
//                })
//        }
//    }
//}
