//
//  Time.swift
//  History
//
//  Created by Nathik Azad on 5/3/24.
//

import Foundation
extension String {
    var getDate: Date? {
        var timeToFormat = self
        if timeToFormat.contains(".") {
            timeToFormat = String(timeToFormat.prefix(upTo: timeToFormat.range(of: ".")!.lowerBound))
        }
        if timeToFormat.contains("+") {
            timeToFormat = String(timeToFormat.prefix(upTo: timeToFormat.range(of: "+")!.lowerBound))
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        return dateFormatter.date(from: timeToFormat)
    }
}

extension Calendar {
    static var currentInLocal: Calendar {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        return calendar
    }
}
extension Date {
    var formattedDateForCalendar: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE MMMM dd" // Custom format for day, month, and date
        formatter.timeZone = TimeZone.current // Local time zone
        return formatter.string(from: self)
    }
    
    var formattedTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a" // 12-hour format with AM/PM
        dateFormatter.timeZone = TimeZone.current // Local time zone
        return dateFormatter.string(from: self).replacingOccurrences(of: ".", with: "").lowercased() // a.m. -> am
    }
    
    var formattedTimeWithoutMeridian: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm" // 12-hour format with AM/PM
        dateFormatter.timeZone = TimeZone.current // Local time zone
        return dateFormatter.string(from: self).replacingOccurrences(of: ".", with: "").lowercased() // a.m. -> am
    }

    func formattedTimeWithReferenceDate(_ referenceDate: Date) -> String {
        let daysDifference = Calendar.currentInLocal.dateComponents([.day], from: referenceDate.startOfDay, to: self.startOfDay).day ?? 0
        if daysDifference != 0 {
            return "\(formattedTime)\(String(format: "%+d", daysDifference))"
        } else {
            return formattedTime
        }
    }
    
    var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE MM/dd" // Day of the week and date
        dateFormatter.timeZone = TimeZone.current // Local time zone
        return dateFormatter.string(from: self) // Format date to string
    }
    
    var formattedShortDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd" // Day of the week and date
        dateFormatter.timeZone = TimeZone.current // Local time zone
        return dateFormatter.string(from: self) // Format date to string
    }
    
    var formattedShortDateAndTime: String {
        return "\(formattedShortDate) \(formattedTime)"
    }
    
    var formattedSuperShortDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd" // Day of the week and date
        dateFormatter.timeZone = TimeZone.current // Local time zone
        return dateFormatter.string(from: self) // Format date to string
    }
    
    func durationInHHMM(to: Date) -> String {
        let duration = Int(to.timeIntervalSince(self)) // duration in seconds
        let hours = duration / 3600
        let minutes = (duration % 3600) / 60
        return String(format: "%02d:%02d", hours, minutes)
    }
    
    var durationSinceInHHMM: String {
        durationInHHMM(to: Date())
    }
    
    var toUTCString: String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.string(from: self)
    }
    
    var getInDecimal: Double {
        Double(Calendar.currentInLocal.component(.hour, from: self)) + Double(Calendar.currentInLocal.component(.minute, from: self)) / 60
    }
    // Helper function to convert time string to decimal
    var timeToDecimal: Double {
        let timeString = self.formattedTime
        let components = timeString.split(separator: ":")
        let hourComponent = components.first!
        let amPmComponent = components.last!.split(separator: " ")
        var hours = Double(hourComponent)!
        let minutes = Double(amPmComponent.first ?? "0") ?? 0
        let amPm = amPmComponent.last ?? ""

        if amPm == "PM" && hours != 12 { // Convert PM time to 24-hour format except for 12 PM
            hours += 12
        }
        if amPm == "AM" && hours == 12 { // Midnight edge case
            hours = 0
        }
        return hours + (minutes / 60.0)
    }
    
    func addHours(_ hoursToAdd: Int) -> Date {
        return Calendar.currentInLocal.date(byAdding: .hour, value: hoursToAdd, to: self)!
    }
    var hourInAmPm: String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "h a"
        return formatter.string(from: self)
    }
    
    var dateWithHourAndMinute: Date {
        let calendar = Calendar.currentInLocal
        let components = calendar.dateComponents([.hour, .minute], from: self)
        var newComponents = DateComponents()
        newComponents.hour = components.hour
        newComponents.minute = components.minute
        // Optionally set the year, month, and day to specific values
        newComponents.year = calendar.component(.year, from: Date())  // Using current year
        newComponents.month = 1  // January
        newComponents.day = 1    // First day of the month
        
        // Return the new date, assuming system's current timezone, change if needed
        return calendar.date(from: newComponents) ?? Date()  // Fallback to current date if nil
    }
    
    func setDate(_ anotherDate:Date) -> Date {
        let calendar = Calendar.currentInLocal
        let components = calendar.dateComponents([.hour, .minute], from: self)
        var newComponents = DateComponents()
        newComponents.hour = components.hour
        newComponents.minute = components.minute
        newComponents.year = calendar.component(.year, from: anotherDate)
        newComponents.month = calendar.component(.month, from: anotherDate)
        newComponents.day = calendar.component(.day, from: anotherDate)
        return calendar.date(from: newComponents) ?? Date()
    }
    
    var startOfDay: Date {
        return Calendar.currentInLocal.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        return Calendar.currentInLocal.date(byAdding: .day, value: 1, to: self.startOfDay)!
    }
    
    var toLocal: Date {
        let utcTimeZone = TimeZone(secondsFromGMT: 0)!
        let delta = TimeInterval(TimeZone.current.secondsFromGMT(for: self) - utcTimeZone.secondsFromGMT(for: self))
        return addingTimeInterval(delta)
    }
    
    func addMinute(_ minute: Int) -> Date {
        return Calendar.currentInLocal.date(byAdding: .minute, value: minute, to: self)!
    }
    
    var getWeekBoundary: WeekBoundary {
        let calendar = Calendar.current
        var modifiedCalendar = calendar
        modifiedCalendar.firstWeekday = 2
        let mondayOfCurrentWeek = modifiedCalendar.date(from: modifiedCalendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))!
        let startOfWeek = modifiedCalendar.startOfDay(for: mondayOfCurrentWeek)
        
        let endOfWeek = modifiedCalendar.date(byAdding: .day, value: 6, to: startOfWeek)!
        let endHour = modifiedCalendar.date(bySettingHour: 23, minute: 59, second: 59, of: endOfWeek)!
        return WeekBoundary(start: startOfWeek, end: endHour)
    }
    
    var getWeekday: Weekday {
        let calendar = Calendar.current
        let weekdayNumber = calendar.component(.weekday, from: self)
        let adjustedWeekdayNumber = weekdayNumber == 1 ? 7 : weekdayNumber - 1
        
        return Weekday(rawValue: adjustedWeekdayNumber)!
    }
}

struct WeekBoundary: Equatable {
    let start: Date //(Monday at 00:00)
    let end: Date //(Sunday at 23:59:59)
    
    func nextWeek() -> WeekBoundary {
        return Calendar.current.date(byAdding: .day, value: 7, to: self.start)!.getWeekBoundary
    }
    
    func previousWeek() -> WeekBoundary {
        return Calendar.current.date(byAdding: .day, value: -7, to: self.start)!.getWeekBoundary
    }
    var formatString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        return "\(dateFormatter.string(from: self.start)) - \(dateFormatter.string(from: self.end))"
    }
    
    func getStartAndEnd(weekday: Weekday) -> WeekBoundary {
        let calendar = Calendar.current
        let weekdayOffset = weekday.rawValue
        let startDate = calendar.date(byAdding: .day, value: weekdayOffset - 1, to: start)!
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)!.addingTimeInterval(-1)
        return WeekBoundary(start: startDate, end: endDate)
    }
}

enum Weekday: Int, CaseIterable {
    case monday = 1, tuesday, wednesday, thursday, friday, saturday, sunday
    var name: String {
        switch self {
        case .sunday: return "Sun"
        case .monday: return "Mon"
        case .tuesday: return "Tue"
        case .wednesday: return "Wed"
        case .thursday: return "Thu"
        case .friday: return "Fri"
        case .saturday: return "Sat"
        }
    }
    
    static func getDays(_ range: ClosedRange<Int>) -> [Weekday] {
        let start = range.lowerBound
        let end = range.upperBound
        
        let adjustedEnd = end < start ? end + 7 : end
        return ((start+1)...adjustedEnd).map { day in
            Weekday(rawValue: ((day - 1) % 7) + 1)!
        }
    }
}

func numberToWeekday(_ number: Int) -> Weekday? {
    return Weekday(rawValue: number)
}



extension EventModel {
    private func _formattedTime(fillWithX: Bool = false) -> String {
        let filler = fillWithX ? "XX:XX" : ""
        let formattedStartTime = startTime?.formattedTime ?? filler
        let formattedEndTime = endTime?.formattedTime ?? filler
        if (startTime != nil && endTime != nil) {
            return "\(formattedStartTime) - \(formattedEndTime)"
        } else if (startTime != nil) {
            return "\(formattedStartTime)"
        } else if (endTime != nil) {
            return  "\(formattedEndTime)"
        }
        return ""
    }
    
    var formattedTime: String {
        return _formattedTime(fillWithX: false)
    }

    func formattedTimeWithReferenceDate(_ referenceDate: Date) -> String {
        var formattedStartTime = ""
        if let startTime = startTime {
            formattedStartTime = startTime.formattedTimeWithReferenceDate(referenceDate)
        }
        var formattedEndTime = ""
        if let endTime = endTime {
            formattedEndTime = endTime.formattedTimeWithReferenceDate(referenceDate)
        }
        if (startTime != nil && endTime != nil) {
            return "\(formattedStartTime) - \(formattedEndTime)"
        } else if (startTime != nil) {
            return "\(formattedStartTime)"
        } else if (endTime != nil) {
            return  "\(formattedEndTime)"
        }
        return ""
    }
    
    var formattedTimeWithX: String {
        return _formattedTime(fillWithX: true)
    }
    
    var formattedDate: String {
        return "\(startTime?.formattedDate ?? endTime?.formattedDate ?? "")"
    }
    
    var date: Date {
        return startTime ?? endTime!
    }
    
    var formattedTimeWithDate: String {
        return "\(formattedDate): \(formattedTime)"
    }
    
    var formattedTimeWithDateAndX: String {
        return "\(formattedDate): \(formattedTimeWithX)"
    }
    
    var totalHoursPerDay: TimeInterval? {
        if(startTime == nil || endTime == nil){
            return nil
        }
        return endTime!.timeIntervalSince(startTime!)
    }
    
    var timeTaken: String? {
        if endTime != nil && startTime != nil {
            return startTime!.durationInHHMM(to: endTime!)
        } else {
            return nil
        }
    }
}
