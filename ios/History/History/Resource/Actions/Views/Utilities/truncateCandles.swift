//
//  TruncateCandlesByHourRange.swift
//  History
//
//  Created by Nathik Azad on 8/12/24.
//

import Foundation
func truncateCandles(_ candles: [Candle], startHour: Int, endHour: Int) -> [Candle] {
//    guard let timezone = TimeZone(identifier: timeZone) else {
//        fatalError("Invalid timezone identifier")
//    }
//
    let calendar = Calendar(identifier: .gregorian)
//    calendar.timeZone = timezone
    
    let adjustedEndHour = endHour == 24 ? 0 : endHour
    let dayOffset = endHour == 24 ? 1 : 0
    
    return candles.filter { candle in
        guard let startDate = calendar.date(bySettingHour: startHour, minute: 0, second: 0, of: candle.start),
              var endDate = calendar.date(bySettingHour: adjustedEndHour, minute: 0, second: 0, of: candle.end) else {
            return false
        }
        
        if dayOffset == 1 {
            endDate = calendar.date(byAdding: .day, value: 1, to: endDate) ?? endDate
        }
        
        return candle.end > startDate && candle.start < endDate
    }.map { candle in
        guard let startDate = calendar.date(bySettingHour: startHour, minute: 0, second: 0, of: candle.start),
              var endDate = calendar.date(bySettingHour: adjustedEndHour, minute: 0, second: 0, of: candle.end) else {
            return candle // This should never happen due to the filter, but we need to handle it
        }
        
        if dayOffset == 1 {
            endDate = calendar.date(byAdding: .day, value: 1, to: endDate) ?? endDate
        }
        
        let truncatedStart = max(candle.start, startDate)
        let truncatedEnd = min(candle.end, endDate)
        
        return Candle(
            date: candle.date,
            start: truncatedStart,
            end: truncatedEnd,
            actionTypeModel: candle.actionTypeModel
        )
    }
}
