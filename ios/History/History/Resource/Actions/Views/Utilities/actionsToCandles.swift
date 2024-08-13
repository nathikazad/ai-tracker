//
//  actionsToCandles.swift
//  History
//
//  Created by Nathik Azad on 8/12/24.
//

import SwiftUI
func convertActionsToCandles(_ actions: [ActionModel], daysRange: ClosedRange<Int>) -> [Candle] {
    
    let dateFormatter = DateFormatter()
    let calendar = Calendar.current
    dateFormatter.dateFormat = "yyyy-MM-dd"
    
//    guard let timezone = TimeZone(identifier: timeZone) else {
//        fatalError("Invalid timezone identifier")
//    }
//    dateFormatter.timeZone = timezone

    let startDateOfRange = calendar.date(
        byAdding: .day,
        value: daysRange.lowerBound,
        to: state.currentWeek.start
    )!
    
    let endDateOfRange = calendar.date(
        byAdding: .day,
        value: daysRange.upperBound,
        to: state.currentWeek.start
    )!
    
    var candles: [Candle] = []
    
    for action in actions {
        
        let startDate = action.startTime
        let endDate = action.endTime ?? action.startTime
        var calendar = Calendar(identifier: .gregorian)
//        calendar.timeZone = timezone
        
        if let midnight = calendar.date(bySettingHour: 23, minute: 59, second: 59, of:  startDate) {
            if (startDate < midnight && endDate > midnight) {
                if startDate > startDateOfRange && midnight < endDateOfRange {
                    let firstCandle = Candle(
                        date: dateFormatter.string(from: startDate),
                        start: startDate,
                        end: midnight,
                        actionTypeModel: action.actionTypeModel
                    )
                    candles.append(firstCandle)
                }
                let secondDay = calendar.date(byAdding: .day, value: 1, to: startDate)!
                if secondDay > startDateOfRange && secondDay < endDateOfRange {
                    let secondCandle = Candle(
                        date: dateFormatter.string(from: midnight.addMinute(2)),
                        start: midnight.addMinute(2),
                        end: endDate,
                        actionTypeModel: action.actionTypeModel
                    )
                    candles.append(secondCandle)
                }
            }
            else {
                if startDate > startDateOfRange && endDate < endDateOfRange {
                    let candle = Candle(
                        date: dateFormatter.string(from: startDate),
                        start: startDate,
                        end: endDate,
                        actionTypeModel: action.actionTypeModel
                    )
                    candles.append(candle)
                }
            }
        }
    }
    return candles
}
