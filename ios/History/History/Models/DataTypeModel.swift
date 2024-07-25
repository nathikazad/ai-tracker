//
//  DataTypeModel.swift
//  History
//
//  Created by Nathik Azad on 7/24/24.
//

import Foundation

enum DataType: String, CaseIterable, Codable {
    case duration = "Duration"
    case time = "Time"
    case date = "Date"
    case dateTime = "DateTime"
    case number = "Number"
    case unit = "Unit"
    case currency = "Currency"
    case enumerator = "Enum"
    case shortString = "ShortString"
    case longString = "LongString"
    case timeStampedString = "TimeStampedString"
    case location = "Location"
    case image = "Image"
}

let allDataTypeStrings = DataType.allCases.map { $0.rawValue }

class TimeDuration {
    
}

class Unit {
    
}

class Currency {
    
}

class TimeStampedString {
    
}

class Location {
    
}

class ASImage {
    // size to show
    // with label
}
