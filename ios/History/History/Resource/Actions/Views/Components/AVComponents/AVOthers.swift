//
//  AVOthers.swift
//  History
//
//  Created by Nathik Azad on 8/19/24.
//

import SwiftUI
// Time Information Section
struct TimeInformationSection: View {
    @ObservedObject var action: ActionModel
    @Binding var changesToSave: Bool
    
    var body: some View {
        Section(header: Text("Time Information")) {
            TimeInformationView(
                startTime: $action.startTime,
                endTime: $action.endTime,
                hasDuration: action.actionTypeModel.meta.hasDuration,
                startTimeLabel: action.actionTypeModel.staticFields.startTime?.name ?? "Start Time",
                endTimeLabel: action.actionTypeModel.staticFields.endTime?.name ?? "End Time",
                changesToSave: $changesToSave
            )
            if (action.actionTypeModel.meta.hasDuration && action.id != nil && action.endTime == nil) {
                TimerComponent(timerId: action.id!)
            }
        }
    }
}

// Save Button Section
struct SaveButtonSection: View {
    @ObservedObject var action: ActionModel
    @Binding var changesToSave: Bool
    var saveChanges: () -> Void
    
    var body: some View {
        Section {
            HStack {
                Spacer()
                Button(getActionState.rawValue.capitalized) {
                    saveChanges()
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    self.changesToSave = false
                }
                .disabled(!self.changesToSave)
                Spacer()
            }
        }
    }
    
    private var getActionState: ShowActionView.ActionState {
        if action.actionTypeModel.meta.hasDuration && action.endTime == nil && action.id == nil {
            if action.startTime.timeIntervalSince(Date()) > 300 {
                return .schedule
            } else {
                return .start
            }
        }
        return .save
    }
}

