//
//  TwoDatePicker.swift
//  History
//
//  Created by Nathik Azad on 5/23/24.
//

import SwiftUI


class TwoDatePickerModel: ObservableObject {
    @Published private(set) var showPopupForId: Int?
    var model: ActionModel = ActionModel(actionTypeId: 0, startTime: Date(), actionTypeModel: ActionTypeModel(name: "None"))

    var getStartTime: Date {
        return model.startTime
    }

    var getEndTime: Date? {
        return model.endTime
    }
    
    func showPopupForEvent(event: EventModel) {
    }
    
    func showPopupForAction(event: ActionModel) {
        model = event
        showPopupForId = event.id
    }
    
    func dismissPopup() {
        showPopupForId = nil
        print("dismissing popup")
    }
}

struct TwoDatePickerView: View {
    @StateObject var datePickerModel: TwoDatePickerModel
    @State var changesToSave:Bool = false
    var body: some View {
        return Group {
            if datePickerModel.showPopupForId != nil {
                VStack {
                    TimeInformationView(
                        startTime: Binding(
                            get: { datePickerModel.model.startTime },
                            set: { datePickerModel.model.startTime = $0 }),
                        endTime: Binding(
                            get: { datePickerModel.model.endTime },
                            set: { datePickerModel.model.endTime = $0 }),
                        hasDuration: datePickerModel.model.actionTypeModel.meta.hasDuration,
                        startTimeLabel: /*datePickerModel.model.actionTypeModel.staticFields.startTime?.name ??*/ "Start:",
                        endTimeLabel: /*datePickerModel.model.actionTypeModel.staticFields.endTime?.name ??*/ "End:",
                        changesToSave: $changesToSave
                    )
                    
                    Button(action: {
                        //
                        DispatchQueue.main.async {
                            Task {
                                await ActionController.updateActionModel(model: datePickerModel.model)
                            }
                            self.datePickerModel.dismissPopup()
                        }
                    }) {
                        Text("Save")
                            .foregroundColor(.primary)
                    }
                    .padding(.top, 5)
                }
                .padding()
                .background(Color("OppositeColor"))
                .cornerRadius(10)
                .shadow(radius: 5)
                .frame(width: 320)
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
