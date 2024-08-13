//
//  ChartView.swift
//  History
//
//  Created by Nathik Azad on 8/5/24.
//

import Foundation
import SwiftUI
struct AggregateChartView: View {
    @ObservedObject var aggregate: AggregateModel
    let actionsParam: [ActionModel]
    let weekBoundary: WeekBoundary?
    let showWeekNavigator: Bool
    
    init(aggregate: AggregateModel, actionsParam: [ActionModel], weekBoundary: WeekBoundary? = nil, endDate: Date? = nil, showWeekNavigator:Bool = true) {
        self.aggregate = aggregate
        self.actionsParam = actionsParam
        self.weekBoundary = weekBoundary
        self.showWeekNavigator = showWeekNavigator
    }
 
    var actions: [ActionModel] {
        actionsParam.filter { $0.actionTypeId == aggregate.actionTypeId }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if aggregate.metadata.aggregatorType == .count {
                let dateCounts = getDateCounts(actions: actions, timezone: Authentication.shared.user!.timezone!)
                let mark: String? = aggregate.metadata.goals.first?.value?.toType(String.self)
                BarView(data: Array(dateCounts.suffix(7)), yAxisLabel: "Count", yMark: mark == nil ? nil : Double(mark!))
                    .id(aggregate.id)
            } else if aggregate.metadata.aggregatorType == .compare {
                let mark: Date? = aggregate.metadata.goals.first?.value?.toType(Date.self)
                if aggregate.metadata.field == "Start Time" {
                    let startTimes = minTimeForEachDay(actions: actions, timezone: Authentication.shared.user!.timezone!)
                    ScatterView(title: "",
                                data: startTimes,
                                mark: mark,
                                range: 2)
                    .id(aggregate.id)
                    .frame(height: 80)
                } else if aggregate.metadata.field == "End Time" {
                    let endTimes = minTimeForEachDay(actions: actions, timezone: Authentication.shared.user!.timezone!, timeSelect: "End Time")
                    ScatterView(title: "", data: endTimes,
                                mark: mark,
                                range: 2)
                    .id(aggregate.id)
                }
            } else {
                let mark = getMark
                if aggregate.metadata.window == .monthly {
                    let dateCounts = getCumulativeDurationsPerMonth(actions: actions, timezone: Authentication.shared.user!.timezone!)
                    let (array, label) = convertDurationsToRightUnit(dateCounts: dateCounts, aggregate: aggregate)
                    BarView(data: array, yAxisLabel: label, yMark: mark == nil ? nil : Double(mark!))
                        .id(aggregate.id)
                } else if aggregate.metadata.window == .weekly {
                    let dateCounts = getCumulativeDurationsPerWeek(actions: actions, timezone: Authentication.shared.user!.timezone!)
                    WeeklyBarView(weeklyDurations: dateCounts, mark: mark, aggregate: aggregate, showWeekNavigator: showWeekNavigator)
                } else {
                    let dateCounts = getDateTotalDurationsPerDay(actions: actions, timezone: Authentication.shared.user!.timezone!)
                    let (array, label) = convertDurationsToRightUnit(dateCounts: dateCounts, aggregate: aggregate)
                    BarView(data: array, yAxisLabel: label, yMark: mark == nil ? nil : Double(mark!))
                        .id(aggregate.id)
                }
            }
        }
    }
    
    private var getMark: Int? {
        if let targetDuration: Duration = aggregate.metadata.goals.first?.value?.toType(Duration.self) {
            return targetDuration.durationInSeconds
        }
        return nil
    }
    
    func getDateRange(from dates: [Date], timezone: String) -> (Calendar, Date, Date)? {
    var calendar = Calendar.current
    let timeZone = TimeZone(identifier: timezone) ?? Calendar.current.timeZone
    calendar.timeZone = timeZone
    
    if let startDate = weekBoundary?.start, let endDate = weekBoundary?.end {
        return (calendar, calendar.startOfDay(for: startDate), calendar.startOfDay(for: endDate))
    } else {
        guard let minDate = dates.min(),
                let maxDate = dates.max() else {
            return nil
        }
        
        return (calendar, calendar.startOfDay(for: minDate), calendar.startOfDay(for: maxDate))
    }
}

    func getDateCounts(actions: [ActionModel], timezone: String) -> [(Date, Double)] {
        guard let (calendar, startDate, endDate) = getDateRange(from: actions.map { $0.startTime }, timezone: timezone) else {
            return []
        }
        
        var currentDate = startDate
        var dateCounts: [(Date, Double)] = []
        
        while currentDate <= endDate {
            let count = actions.filter { calendar.isDate($0.startTime, inSameDayAs: currentDate) }.count
            dateCounts.append((currentDate, Double(count)))
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return dateCounts
    }
    
    func getDateTotalDurationsPerDay(actions: [ActionModel], timezone: String) -> [(Date, Int)] {
        guard let (calendar, startDate, endDate) = getDateRange(from: actions.map { $0.startTime }, timezone: timezone) else {
            return []
        }
        
        var currentDate = startDate
        var dateTotalDurations: [(Date, Int)] = []
        
        while currentDate <= endDate {
            let totalDuration = actions
                .filter { calendar.isDate($0.startTime, inSameDayAs: currentDate) }
                .reduce(0) { sum, action in
                    sum + Int(action.durationInSeconds)
                }
            
            dateTotalDurations.append((currentDate, totalDuration))
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return dateTotalDurations
    }

    
    func minTimeForEachDay(actions: [ActionModel], timezone: String, timeSelect: String = "Start Time") -> [Date] {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(identifier: timezone) ?? TimeZone.current

        for action in actions {
            let startTimeString = formatter.string(from: action.startTime)
            print("Start time: \(startTimeString)")
            if let endTime = action.endTime {
                let endTimeString = formatter.string(from: endTime)
                print("End time: \(endTimeString)")
            }
        }
        
        let relevantDates = timeSelect == "Start Time" ? actions.map { $0.startTime } : actions.compactMap { $0.endTime }
        
        guard let (calendar, startDate, endDate) = getDateRange(from: relevantDates, timezone: timezone) else {
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
            } else {
                // If there are no actions for a day, we'll use noon of that day as a placeholder
                if let noonDate = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: currentDate) {
                    minTimes.append(noonDate)
                }
            }
            
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        for minTime in minTimes {
            let startTimeString = formatter.string(from: minTime)        
        }
        
        return minTimes
    }
}


