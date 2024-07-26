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
                Section(header: Text("Action ID: \(action.id)")) {
                    Text("Details for action \(action.id)")
                    if let startTime = action.staticData.startTime {
                        Text("\(model.staticFields.startTime?.name ?? "Start Time"): \(getDateTime(startTime))")
                    }
                    if let endTime = action.staticData.endTime {
                        Text("\(model.staticFields.endTime?.name ?? "End Time"): \(getDateTime(endTime)) ")
                    }
                    if let time = action.staticData.time {
                        Text("Time: \(getDateTime(time))")
                    }
                    ForEach(Array(action.dynamicData.keys), id: \.self) { key in
                        if let value = action.dynamicData[key] {
                            Text("\(key.capitalized): \(String(describing: value))")
                        }
                    }
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
//            self.actions = fetchActions(type: model.name)
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
