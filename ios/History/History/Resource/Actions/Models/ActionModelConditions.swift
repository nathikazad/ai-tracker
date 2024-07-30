//
//  ActionModelConditions.swift
//  History
//
//  Created by Nathik Azad on 7/29/24.
//
import Foundation
extension ActionModel {
    func isTrue(for key: String, valuetype: String) -> Bool {
        return dynamicData[key]?.toString == valuetype
    }
    
    enum OperationType: String {
        case greaterThan = ">"
        case lessThan = "<"
        case equalTo = "="
    }

    enum TimeType: String {
        case startTime = "startTime"
        case endTime = "endTime"
        case duration = "duration"
    }

    func timeCompare(timeType: TimeType, operationType: OperationType, value: String) -> Bool {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        switch timeType {
        case .startTime:
            guard let comparisonTime = dateFormatter.date(from: value) else { return false }
            let startTimeComponents = calendar.dateComponents([.hour, .minute], from: startTime)
            let comparisonTimeComponents = calendar.dateComponents([.hour, .minute], from: comparisonTime)
            
            return compare(startTimeComponents, operationType, comparisonTimeComponents)
            
        case .endTime:
            guard let endTime = endTime, let comparisonTime = dateFormatter.date(from: value) else { return false }
            let endTimeComponents = calendar.dateComponents([.hour, .minute], from: endTime)
            let comparisonTimeComponents = calendar.dateComponents([.hour, .minute], from: comparisonTime)
            
            return compare(endTimeComponents, operationType, comparisonTimeComponents)
            
        case .duration:
            guard let comparisonDuration = parseTimeDuration(value) else { return false }
            return compare(parseTimeDuration(duration)!, operationType, comparisonDuration)
        }
    }

    private func compare(_ timeComponents: DateComponents, _ operationType: OperationType, _ comparisonComponents: DateComponents) -> Bool {
        let timeMinutes = (timeComponents.hour ?? 0) * 60 + (timeComponents.minute ?? 0)
        let comparisonMinutes = (comparisonComponents.hour ?? 0) * 60 + (comparisonComponents.minute ?? 0)
        
        switch operationType {
        case .greaterThan:
            return timeMinutes > comparisonMinutes
        case .lessThan:
            return timeMinutes < comparisonMinutes
        case .equalTo:
            return timeMinutes == comparisonMinutes
        }
    }

    private func compare(_ duration: Int, _ operationType: OperationType, _ comparisonDuration: Int) -> Bool {
        switch operationType {
        case .greaterThan:
            return duration > comparisonDuration
        case .lessThan:
            return duration < comparisonDuration
        case .equalTo:
            return duration == comparisonDuration
        }
    }

    private func parseTimeDuration(_ value: String) -> Int? {
        let components = value.split(separator: ":")
        guard components.count == 2,
              let hours = Int(components[0]),
              let minutes = Int(components[1]) else {
            return nil
        }
        return hours * 3600 + minutes * 60
    }
}
