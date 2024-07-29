//
//  TwoDatePicker.swift
//  History
//
//  Created by Nathik Azad on 5/23/24.
//

import SwiftUI


class TwoDatePickerModel: ObservableObject {
    @Published var startTime: Date = Date()
    @Published var startTimeIsNull: Bool = false
    @Published var endTime: Date =  Date()
    @Published var endTimeIsNull: Bool = false
    @Published private(set) var isShowingDatePicker = false
    @Published private(set) var popupScreenFirst: Bool = true
    @Published private(set) var showPopupForId: Int?

    var getStartTime: Date? {
        return startTimeIsNull ? nil : startTime
    }

    var getEndTime: Date? {
        return endTimeIsNull ? nil : endTime
    }
    
    func showPopupForEvent(event: EventModel) {
        startTime = event.startTime ?? Date()
        endTime = event.endTime ?? Date()
        startTimeIsNull = event.startTime == nil
        endTimeIsNull = event.endTime == nil
        showPopupForId = event.id
        popupScreenFirst = true
    }
    
    func showPopupForAction(event: ActionModel) {
        startTime = event.startTime
        endTime = event.endTime ?? Date()
        startTimeIsNull = false
        endTimeIsNull = event.endTime == nil
        showPopupForId = event.id
        popupScreenFirst = true
    }
    
    func showNextScreen() {
        popupScreenFirst = false
    }
    
    func dismissPopup() {
        showPopupForId = nil
        print("dismissing popup")
    }
}

struct TwoDatePickerView: View {
    @StateObject var datePickerModel: TwoDatePickerModel
    var body: some View {
        return Group {
            if datePickerModel.showPopupForId != nil {
                VStack {
                    if(datePickerModel.popupScreenFirst) {
                        Text("Start Time")
                        Toggle("Null", isOn: $datePickerModel.startTimeIsNull)
                            .padding()
                        if !datePickerModel.startTimeIsNull {
                            DatePicker("Start Time", selection: $datePickerModel.startTime, displayedComponents:  [.date, .hourAndMinute])
                                .datePickerStyle(WheelDatePickerStyle())
                                .frame(maxHeight: 150)
                                .padding()
                        }
                        
                        
                        
                    } else {
                        Text("End Time")
                        Toggle("Null", isOn: $datePickerModel.endTimeIsNull)
                            .padding()
                        if !datePickerModel.endTimeIsNull {
                            DatePicker("End Time", selection: $datePickerModel.endTime, displayedComponents:  [.date, .hourAndMinute])
                                .datePickerStyle(WheelDatePickerStyle())
                                .frame(maxHeight: 150)
                                .padding()
                        }
                        
                    }
                    
                    Button(action: {
                        if(datePickerModel.popupScreenFirst) {
                            datePickerModel.showNextScreen()
                        } else {
                            DispatchQueue.main.async {
                                let startTime = datePickerModel.getStartTime
                                let endTime = datePickerModel.getEndTime
                                EventsController.editEvent(id: datePickerModel.showPopupForId!, startTime: startTime, endTime: endTime, passNullTimeValues: true)
                                self.datePickerModel.dismissPopup()
                            }
                            
                        }
                    }) {
                        Text(datePickerModel.popupScreenFirst ? "Next" : "Save")
                            .foregroundColor(.primary)
                    }
                    .padding(.top, 5)
                }
                .padding()
                .background(Color("OppositeColor"))
                .cornerRadius(10)
                .shadow(radius: 5)
                .frame(width: 300)
                .overlay(
                    Button(action: {
                        datePickerModel.dismissPopup()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                    },
                    alignment: .topTrailing
                )
            }
        }
    }
}
