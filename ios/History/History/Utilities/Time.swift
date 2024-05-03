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
    var formattedTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a" // 12-hour format with AM/PM
        dateFormatter.timeZone = TimeZone.current // Local time zone
        return dateFormatter.string(from: self) // Format date to string
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
}
