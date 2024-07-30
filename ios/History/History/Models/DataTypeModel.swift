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

class Duration {
    var durationInSeconds: Int
    enum DurationType: String, Codable, CaseIterable {
        case seconds
        case minutes
        case hours
    }
    
    var durationType: DurationType
    
    init(durationInSeconds: Int, durationType: DurationType) {
        self.durationInSeconds = durationInSeconds
        self.durationType = durationType
    }
    
    var formattedDuration: String {
        switch durationType {
        case .seconds:
            return "\(durationInSeconds) seconds"
        case .minutes:
            return "\(durationInSeconds / 60) minutes"
        case .hours:
            return "\(durationInSeconds / 3600) hours"
        }
    }
}

class Unit {
    var value: Int
    enum UnitType: String, Codable, CaseIterable {
        case count
        case weight
        case volume
    }

    enum UnitMeasure: String, Codable, CaseIterable {
        case none
        case grams
        case kilograms
        case pounds
        case liters
        case milliliters
        case fluidOunces
        case cups
        case tablespoons
        case teaspoons
    }

    init(value: Int, unitType: UnitType, unitMeasure: UnitMeasure) {
        self.value = value
        self.unitType = unitType
        self.unitMeasure = unitMeasure
    }
    var unitType: UnitType
    var unitMeasure: UnitMeasure

    var abbreviation: String {
        switch unitMeasure {
        case .none:
            return ""
        case .grams:
            return "g"
        case .kilograms:
            return "kg"
        case .pounds:
            return "lb"
        case .liters:
            return "l"
        case .milliliters:
            return "ml"
        case .fluidOunces:
            return "fl oz"
        case .cups:
            return "cups"
        case .tablespoons:
            return "tbsp"
        case .teaspoons:
            return "tsp"
        }
    }

    func getUnitMeasures(for unitType: UnitType) -> [UnitMeasure] {
        switch unitType {
        case .count:
            return []
        case .weight:
            return [.grams, .kilograms, .pounds]
        case .volume:
            return [.liters, .milliliters, .fluidOunces, .cups, .tablespoons, .teaspoons]
        }
    }

    var formattedValue: String {
        return "\(value) \(abbreviation)"
    }
}

class Currency {
    var value: Int
    var currencyType: String

    init(value: Int, currencyType: String) {
        self.value = value
        self.currencyType = currencyType
    }
}

class TimeStampedString {
    var value: String
    var timestamp: Date

    init(value: String, timestamp: Date) {
        self.value = value
        self.timestamp = timestamp
    }
}

class Location {
    var latitude: Double
    var longitude: Double
    var timestamp: Date
    var name: String

    init(latitude: Double, longitude: Double, timestamp: Date, name: String) {
        self.latitude = latitude
        self.longitude = longitude
        self.timestamp = timestamp
        self.name = name
    }
}

class ASImage {
//    var image: UIImage
//    var timestamp: Date
//
//    init(image: UIImage, timestamp: Date) {
//        self.image = image
//        self.timestamp = timestamp
//    }
}
