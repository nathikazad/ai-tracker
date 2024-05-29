//
//  EventModels.swift
//  History
//
//  Created by Nathik Azad on 5/28/24.
//

import Foundation

extension [EventModel] {
    
    
    func totalHours(days: Int) -> Int {
        let dailyTimes = self.dailyTimes(days: days)
        var total = 0.0
        for (_, startTime, endTime) in dailyTimes {
//            let day = Calendar.currentInLocal.startOfDay(for:startTime)
            let duration = endTime.timeIntervalSince(startTime) / 3600
            total = total + duration
        }
        return Int(total)
    }
    
    func totalDays(days: Int) -> Int {
        return dailyTotals(days: days).count
    }
    
    var maxDays: Double {
        guard let earliestDate = self.min(by: { $0.startTime ?? Date() < $1.startTime ?? Date() })?.startTime else {
            return 7 // or some default minimum
        }
        let daysDifference = Calendar.current.dateComponents([.day], from: earliestDate, to: Date()).day ?? 0
        return Double(daysDifference + 1)
    }
    
    var sortEvents: [EventModel] {
        return self.sorted { (event1, event2) -> Bool in
            let date1 = event1.startTime ?? event1.endTime
            let date2 = event2.startTime ?? event2.endTime
            return date1 ?? Date.distantFuture < date2 ?? Date.distantFuture
        }
    }

    var flatten: [EventModel] {
        var events: [EventModel] = []
        for event in self {
            events.append(event)
            events.append(contentsOf: event.children.flatten)
        }
        return events.sortEvents
    }

    // Get minimum and maximum depth of the event children tree
    var depthRange: (Int, Int) {
        var minDepth = Int.max
        var maxDepth = 0
        for event in self {
            let depth = event.depth
            minDepth = Swift.min(minDepth, depth)
            maxDepth = Swift.max(maxDepth, depth)
        }
        return (minDepth, maxDepth)
    }
    
    var numDays: Int {
        // get minimum date, maximum date, and then get the difference in days
        let minDate = self.min { $0.date < $1.date }?.date ?? Date()
        let maxDate = self.max { $0.date < $1.date }?.date ?? Date()
        return Calendar.current.dateComponents([.day], from: minDate, to: maxDate).day ?? 0
    }

    var withChildrenOrNotes: [EventModel] {
        return self.filter { $0.hasChildren || $0.hasNotes}
    }
    
    func filterEventsForTheLastNdays(days: Int) -> [EventModel] {
        let startDate = Calendar.currentInLocal.date(byAdding: .day, value: -Int(days), to: Date())!
        return self.filter { event in
            return (event.startTime != nil && event.startTime! >= startDate) || (event.endTime != nil && event.endTime! >= startDate)
        }.reversed()
    }

//    func datesChartData(days: Int) ->  [String] {
//        return self.filterEventsForTheLastNdays(days: Int(days)).map(\.endTime!.formattedSuperShortDate)
//    }

    func startTimes(days: Int, unique: Bool) -> [Date] {
        let events = self.filterEventsForTheLastNdays(days: days).filter { event in
            return event.startTime != nil
        }
        let startTimes = events.compactMap { $0.startTime } // Safely unwrap the start times

        if unique {
            // Group start times by day using the calendar to normalize dates to the start of each day
            let calendar = Calendar.current
            let groupedByDay = Dictionary(grouping: startTimes, by: { calendar.startOfDay(for: $0) })

            // For each group, find the minimum start time
            return groupedByDay.map { day, times in
                times.min() ?? day // Return the minimum time or the day itself if no times are available
            }
        } else {
            // If not unique, return all start times
            return startTimes
        }
    }


    func endTimes(days: Int, unique: Bool) -> [Date] {
        let events = self.filterEventsForTheLastNdays(days: days).filter { event in
            return event.endTime != nil
        }
        let endTimes = events.compactMap { $0.endTime }

        if unique {
            // Group end times by day
            let calendar = Calendar.current
            let groupedByDay = Dictionary(grouping: endTimes, by: { calendar.startOfDay(for: $0) })

            // For each group, find the maximum end time
            return groupedByDay.map { day, times in
                times.max() ?? day // Return the maximum time or the day itself if no times are available
            }
        } else {
            // If not unique, return all end times
            return endTimes
        }
    }
    
    func dailyTimes(days: Int) -> [(String, Date, Date)] {
            var dailyTimes = [(String, Date, Date)]()
            let now = Date()
            let calendar = Calendar.currentInLocal
            
            let filteredEvents = self.filter { event in
                guard let eventDate = event.startTime else { return false }
                let localEventDate = eventDate.toLocal
                return localEventDate >= calendar.date(byAdding: .day, value: -days, to: now)!
            }
            
            for event in filteredEvents {
                guard let utcStartTime = event.startTime, let utcEndTime = event.endTime else {
                    if let utcStartTime = event.startTime {
                        if(calendar.isDateInToday(utcStartTime) && event.endTime == nil){
                            dailyTimes.append((utcStartTime.formattedSuperShortDate, utcStartTime, now))
                        }
                    }
                    continue
                }
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                dateFormatter.timeZone = TimeZone.current

                let startDateString = dateFormatter.string(from: utcStartTime)
                let endDateString = dateFormatter.string(from: utcEndTime)
                
//                print("Local start date \(utcStartTime) end date \(utcEndTime)")

                // Split events spanning multiple days
                if startDateString != endDateString {
//                    print("Event spans multiple days")
                    let midnight = utcStartTime.endOfDay
//                    print("\(utcStartTime.formattedSuperShortDate) start date \(utcStartTime.toLocal) end date \(midnight.addMinute(-1).toLocal)")
//                    print("\(utcEndTime.formattedSuperShortDate) start date \(midnight.toLocal) end date \(utcEndTime.toLocal)")
                    dailyTimes.append((utcStartTime.formattedSuperShortDate, utcStartTime, midnight.addMinute(-1)))
                    dailyTimes.append((utcEndTime.formattedSuperShortDate, midnight, utcEndTime))
                } else {
//                    print("Event within the same day")
                    dailyTimes.append((utcStartTime.formattedSuperShortDate, utcStartTime, utcEndTime))
                }
            }
            
            return dailyTimes.sorted { $0.1 < $1.1 }
        }
    
    func dailyTotals(days: Int) -> [(Date, Double)] {
        let dailyTimes = self.dailyTimes(days: days)
        var dailyTotals = [Date: Double]()
        
        for (_, startTime, endTime) in dailyTimes {
            let day = Calendar.currentInLocal.startOfDay(for:startTime)
            let duration = endTime.timeIntervalSince(startTime) / 3600
            if let total = dailyTotals[day] {
                dailyTotals[day] = total + duration
            } else {
                dailyTotals[day] = duration
            }
        }
        
        
        let sortedTotals = dailyTotals.sorted { $0.key < $1.key }
        return sortedTotals.map { ($0.key, $0.value) }
    }
}
