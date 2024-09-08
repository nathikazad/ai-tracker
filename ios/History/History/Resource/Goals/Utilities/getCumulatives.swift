//
//  getCumulatives.swift
//  History
//
//  Created by Nathik Azad on 8/12/24.
//

import Foundation

extension AggregateChartView {
    func getCumulative(actions: [ActionModel], adder: (ActionModel) -> Int) -> [(Date, Int, Int)] {
        let calendar = Calendar.current
        let startDate = state.bounds.start
        let endDate = state.bounds.end
        var currentDate = startDate
        var values: [(Date, Int, Int)] = []
        while currentDate <= endDate {
            var cumulative = 0
            let dayValue = actions
                .filter { action in
                    calendar.isDate(action.startTime, inSameDayAs: currentDate)
                }
                .reduce(0) { sum, action in
                    sum + adder(action)
                }
            cumulative += dayValue
            values.append((currentDate, cumulative, dayValue))
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        return values
    }
    
    func getCumulativeDurationsPerMonth(actions: [ActionModel], timezone: String) -> [(Date, Int)] {
        guard let (calendar, startDate, endDate) = getDateRange(from: actions.map { $0.startTime }) else {
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
