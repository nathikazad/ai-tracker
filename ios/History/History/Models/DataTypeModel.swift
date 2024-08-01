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
    case todo = "Todo"
}

func getDataType(from string: String) -> DataType? {
    let lowercasedString = string.lowercased()
    return DataType.allCases.first { $0.rawValue.lowercased() == lowercasedString }
}

extension AnyCodable {
    func toType<T>(_ type: T.Type) -> T? {
        switch type {
        case is Duration.Type:
            return value as? T
        case is Unit.Type:
            return value as? T
        case is Currency.Type:
            return Currency(data: value as? [String: Any]) as? T
        case is TimeStampedString.Type:
            return value as? T
        case is Date.Type:
            return (value as? String)?.getDate as? T
        case is String.Type:
            return value as? T
        default:
            return nil
        }
    }
    
    static func fromType<T>(_ value: T) -> AnyCodable? {
        switch value {
        case is Duration:
            return AnyCodable(value)
        case is Unit:
            return AnyCodable(value)
        case let currency as Currency:
            return currency.toAnyCodable()
        case let timeStampedString as TimeStampedString:
            return AnyCodable(timeStampedString)
        case let date as Date:
            return AnyCodable(date.toUTCString)
        case is String:
            return AnyCodable(value)
        default:
            return nil
        }
    }
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
    
    static let defaultDuration = Duration()
    
    init(durationInSeconds: Int = 0, durationType: DurationType = .seconds) {
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
    
    static let defaultUnit = Unit()

    init(value: Int = 0, unitType: UnitType = .count, unitMeasure: UnitMeasure = .none) {
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
    var value: Double
    var currencyType: CurrencyType

    enum CurrencyType: String, CaseIterable {
        case usd = "USD"
        case mxn = "MXN"
        case tnd = "TND"
        case inr = "INR"
    }

    static func convertStringToCurrencyType(_ string: String) -> CurrencyType? {
        return CurrencyType.allCases.first { $0.rawValue.lowercased() == string.lowercased() }
    }

    init(value: Double = 0, currencyType: CurrencyType? = nil) {
        if currencyType == nil {
            switch Authentication.shared.user?.timezone {
            case "America/Mexico_City":
                self.currencyType = .mxn
            default:
                self.currencyType = .usd
            }
        } else {
            self.currencyType = currencyType!
        }
        self.value = value
    }
    
    convenience init(data: [String: Any]?) {
        let value = data?["value"] as? Double ?? 0
        let typeString = data?["currencyType"] as? String
        let type = CurrencyType.allCases.first { $0.rawValue.lowercased() == typeString?.lowercased() }
        self.init(value: value, currencyType: type ?? .usd)
    }


    static let defaultCurrency = Currency()
    
    var formattedValue: String {
        let currencySymbol: String
        switch currencyType {
        case .usd:
            currencySymbol = "$"
        case .mxn:
            currencySymbol = "$"
        case .tnd:
            currencySymbol = "TND"
        case .inr:
            currencySymbol = "₹"
        }
        return "\(currencySymbol)\(value)"
    }

    func toAnyCodable() -> AnyCodable {
        return AnyCodable([
            "value": value,
            "currencyType": currencyType.rawValue
        ])
    }
    
    func toJSONCompatible() -> Any {
        return ["value": value, "currencyType": currencyType.rawValue]
    }
}

class Todo {
    var name: String
    var value: Bool
    
    static let defaultTodo = Todo()

    init(name: String = "", value: Bool = false) {
        self.name = name
        self.value = value
    }
}




class TimeStampedString {
    var value: String
    var timestamp: Date
    
    static let defaultTimeStampedString = TimeStampedString()

    init(value: String = "", timestamp: Date = Date()) {
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
