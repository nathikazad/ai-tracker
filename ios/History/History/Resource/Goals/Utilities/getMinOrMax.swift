//
//  getMinOrMax.swift
//  History
//
//  Created by Nathik Azad on 8/14/24.
//

import Foundation

extension AggregateChartView {
    
    func minTimeForEachDay(actions: [ActionModel], timeSelect: String = "Start Time") -> [Date] {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        for action in actions {
            let startTimeString = formatter.string(from: action.startTime)
            if let endTime = action.endTime {
                let endTimeString = formatter.string(from: endTime)
            }
        }
        
        let relevantDates = timeSelect == "Start Time" ? actions.map { $0.startTime } : actions.compactMap { $0.endTime }
        
        guard let (calendar, startDate, endDate) = getDateRange(from: relevantDates) else {
            return []
        }
        
        var currentDate = startDate
        var minTimes: [Date] = []
        
        while currentDate <= endDate {
            let actionsForDay = actions.filter { action in
                let actionDate = timeSelect == "Start Time" ? action.startTime : action.endTime
                return actionDate.map { calendar.isDate($0, inSameDayAs: currentDate) } ?? false
            }
            
            if let minTime = actionsForDay.compactMap({ action -> Date? in
                timeSelect == "Start Time" ? action.startTime : action.endTime
            }).min() {
                minTimes.append(minTime)
            }
            //            else {
            //                // If there are no actions for a day, we'll use noon of that day as a placeholder
            //                if let noonDate = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: currentDate) {
            //                    minTimes.append(noonDate)
            //                }
            //            }
            
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        if timeSelect == "Start Time" {
            minTimes = minTimes.filter { date in
                let components = Calendar.current.dateComponents([.hour], from: date)
                return components.hour! >= 20 // 20 is 8 PM in 24-hour format
            }
        }
        return minTimes
    }
}
