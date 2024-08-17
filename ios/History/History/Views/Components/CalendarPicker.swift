//
//  CalendarPicker.swift
//  History
//
//  Created by Nathik Azad on 4/23/24.
//

import SwiftUI

extension AppState {
    
    func goToNextDay() {
        
        currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
        notifyCoreStateChanged()
    }
    
    func goToPreviousDay() {
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
    func goToNextWeek() {
        currentWeek = currentWeek.nextWeek()
        notifyCoreStateChanged()
    }
    
    func goToPreviousWeek() {
        currentWeek = currentWeek.previousWeek()
        notifyCoreStateChanged()
    }
    
    var isItToday: Bool {
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


struct WeekNavigator: View {
    @ObservedObject var appState = state
    var body: some View {
        HStack {
            Spacer()
            Button(action: {
                appState.goToPreviousWeek()
            }) {
                Image(systemName: "chevron.left.circle.fill")
                    .resizable()
                    .frame(width: 20, height: 20)
            }
            .buttonStyle(PlainButtonStyle())
            
            HStack {
                Text(appState.currentWeek.formatString)
                    .font(.headline)
            }.frame(minWidth: 130)
            
            Button(action: {
                appState.goToNextWeek()
            }) {
                Image(systemName: "chevron.right.circle.fill")
                    .resizable()
                    .frame(width: 20, height: 20)
            }
            .buttonStyle(PlainButtonStyle())
            Spacer()
        }
        .padding()
    }
}


struct DateNavigator: View {
    @ObservedObject var appState = state
    
    var body: some View {
        HStack {
            Spacer()
            Button(action: {
                appState.goToPreviousDay()
            }) {
                Image(systemName: "chevron.left.circle.fill")
                    .resizable()
                    .frame(width: 20, height: 20)
            }
            .buttonStyle(PlainButtonStyle())
            
            HStack {
                Button(action: {
                    state.showSheet(newSheetToShow: .calendar)
                }) {
                    if (state.isItToday) {
                        Text("Today")
                            .font(.title3)
                    } else {
                        Text(dateString)
                            .font(.headline)
                    }
                }
                if !appState.isItToday {
                    Button(action: {
                        state.goToDay()
                    }) {
                        Image(systemName: "arrow.clockwise.circle")
                    }
                }
            }
            .frame(minWidth: 130)
            Button(action: {
                appState.goToNextDay()
            }) {
                Image(systemName: "chevron.right.circle.fill")
                    .resizable()
                    .frame(width: 20, height: 20)
            }
            .buttonStyle(PlainButtonStyle())
            Spacer()
        }
        .padding()
    }
    
    private var dateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E MMM d"
        return dateFormatter.string(from: appState.currentDate)
    }
}
