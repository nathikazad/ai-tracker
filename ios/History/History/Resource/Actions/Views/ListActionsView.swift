//
//  CreateActionView.swift
//  History
//
//  Created by Nathik Azad on 7/22/24.
//

import SwiftUI

struct ListActionsView: View {
    var model: ActionTypeModel
    @State var actions: [ActionModel] = []
    var createAction: ((ActionTypeModel) -> Void)?
    var body: some View {
        List {
            ForEach(actions, id: \.id) { action in
                Section(header: Text("Action: \(action.actionTypeModel.name)")) {
                    if(!action.actionTypeModel.meta.hasDuration) {
                        Text("Time: \(getDateTime(action.startTime))")
                    } else {
                        let startTimeName =  action.actionTypeModel.staticFields.startTime?.name ?? "Start Time"
                        Text("\(startTimeName): \(getDateTime(action.startTime))")
                        if let endTime = action.endTime {
                            let endTimeName =  action.actionTypeModel.staticFields.endTime?.name ?? "End Time"
                            Text("\(endTimeName): \(getDateTime(endTime)) ")
                        }
                    }


////                    if let time = action.staticData.startTime {
////                        Text("Time: \(getDateTime(time))")
////                    }
//                    ForEach(Array(action.dynamicData.keys), id: \.self) { key in
//                        if let value = action.dynamicData[key] {
//                            Text("\(key.capitalized): \(String(describing: value))")
//                        }
//                    }
                }
            }
        }
        .navigationTitle( "\(model.name)")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: ActionTypeView(
                    model: model
                )) {
                    Image(systemName: "pencil")
                }
            }
        }
        .onAppear {
            Task {
                self.actions = await ActionController.fetchActions(userId: 1, actionId: 2)
                print(self.actions.count)
            }
        }
    }
}

func getDate(_ dateString: String) -> String {
    return formatDateString(dateString, toFormat: "MM-dd-yy")
}

func getTime(_ dateString: String) -> String {
    return formatDateString(dateString, toFormat: "h:mm a")
}

func getDateTime(_ dateString: String) -> String {
    return formatDateString(dateString, toFormat: "MM-dd-yy h:mm a")
}

func formatDateString(_ dateString: String, toFormat outputFormat: String) -> String {
        func getTimeZoneOffset(from dateString: String) -> TimeZone? {
        let regex = try! NSRegularExpression(pattern: "[+-]\\d{2}:\\d{2}", options: [])
        if let match = regex.firstMatch(in: dateString, options: [], range: NSRange(location: 0, length: dateString.count)) {
            let offsetString = (dateString as NSString).substring(with: match.range)
            return TimeZone(identifier: "GMT" + offsetString)
        }
        return nil
    }
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
    
    // Convert the string to a Date object
    if let date = dateFormatter.date(from: dateString) {
        // Create another DateFormatter instance for the desired output format
        let outputFormatter = DateFormatter()
        outputFormatter.timeZone = getTimeZoneOffset(from: dateString)!
        outputFormatter.dateFormat =  outputFormat// 12-hour format with AM/PM
        
        // Convert the Date object to the desired output format string
        let formattedDateString = outputFormatter.string(from: date)
        return formattedDateString // Output: 10:30 PM
    } else {
        return "Invalid time"
    }
}
