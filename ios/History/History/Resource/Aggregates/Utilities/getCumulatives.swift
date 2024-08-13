//
//  getCumulatives.swift
//  History
//
//  Created by Nathik Azad on 8/12/24.
//

import Foundation

extension AggregateChartView {
    func getCumulativeDurationsPerWeek(actions: [ActionModel], timezone: String) -> [[(Date, Int, Int)]] {
        guard let (calendar, startDate, endDate) = getDateRange(from: actions.map { $0.startTime }, timezone: timezone) else {
            return []
        }
        
        var currentDate = startDate
        var weeklyDurations: [[(Date, Int, Int)]] = []
        
        while currentDate <= endDate {
            let weekBoundary = currentDate.getWeekBoundary
            let weekStartDate = weekBoundary.start
            print(weekStartDate.formattedShortDateAndTime)
            let weekEndDate = weekBoundary.end
            
            var weekCumulative = 0
            var dailyDate = weekStartDate
            var weekDurations: [(Date, Int, Int)] = []
            
            while dailyDate <= weekEndDate {
                if dailyDate <= endDate {
                    let dailyDuration = actions
                        .filter { action in
                            calendar.isDate(action.startTime, inSameDayAs: dailyDate)
                        }
                        .reduce(0) { sum, action in
                            sum + Int(action.durationInSeconds)
                        }
                    
                    weekCumulative += dailyDuration
                    weekDurations.append((dailyDate, weekCumulative, dailyDuration))
                } else {
                    weekDurations.append((dailyDate, 0, 0))
                }
                dailyDate = calendar.date(byAdding: .day, value: 1, to: dailyDate)!
            }
            
            weeklyDurations.append(weekDurations)
            currentDate = calendar.date(byAdding: .day, value: 7, to: currentDate)!
        }
        
        return weeklyDurations
    }
    
    func getCumulativeDurationsPerMonth(actions: [ActionModel], timezone: String) -> [(Date, Int)] {
        guard let (calendar, startDate, endDate) = getDateRange(from: actions.map { $0.startTime }, timezone: timezone) else {
            return []
        }
        
        var currentDate = startDate
        var cumulativeDurations: [(Date, Int)] = []
        
        while currentDate <= endDate {
            let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate))!
            let nextMonth = calendar.date(byAdding: .month, value: 1, to: monthStart)!
            let monthEnd = calendar.date(byAdding: .day, value: -1, to: nextMonth)!
            
            var monthCumulative = 0
            var dailyDate = monthStart
            
            while dailyDate <= monthEnd && dailyDate <= endDate {
                let dailyDuration = actions
                    .filter { action in
                        calendar.isDate(action.startTime, inSameDayAs: dailyDate)
                    }
                    .reduce(0) { sum, action in
                        sum + Int(action.durationInSeconds)
                    }
                
                monthCumulative += dailyDuration
                cumulativeDurations.append((dailyDate, monthCumulative))
                
                dailyDate = calendar.date(byAdding: .day, value: 1, to: dailyDate)!
            }
            
            currentDate = nextMonth
        }
        
        return cumulativeDurations
    }
}
