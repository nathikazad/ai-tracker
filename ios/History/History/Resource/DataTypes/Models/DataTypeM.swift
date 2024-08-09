//
//  DataTypeModel.swift
//  History
//
//  Created by Nathik Azad on 7/24/24.
//

import Foundation

enum DataType: String, CaseIterable, Codable {
    // case duration = "Duration"
    case time = "Time"
    // case date = "Date"
    case dateTime = "DateTime"
    case number = "Number"
    // case unit = "Unit"
    case currency = "Currency"
    case enumerator = "Enum"
    case shortString = "ShortString"
    case longString = "LongString"
    // case timeStampedString = "TimeStampedString"
    // case location = "Location"
    // case image = "Image"
    // case todo = "Todo"
}

func getDataType(from string: String) -> DataType? {
    let lowercasedString = string.lowercased()
    return DataType.allCases.first { $0.rawValue.lowercased() == lowercasedString }
}

let allDataTypeStrings = DataType.allCases.map { $0.rawValue }

class Duration: AnyCodableConvertible {
    var durationInSeconds: Int
    enum DurationType: String, Codable, CaseIterable {
        case seconds
        case minutes
        case hours
    }
    
    var durationType: DurationType
    
    required init(data: [String: Any]?) {
        self.durationInSeconds = data?["durationInSeconds"] as? Int ?? 0
        if let typeString = data?["durationType"] as? String,
           let type = DurationType(rawValue: typeString) {
            self.durationType = type
        } else {
            self.durationType = .seconds
        }
    }
    
    static let defaultDuration = Duration()
    
    init(durationInSeconds: Int = 0, durationType: DurationType = .seconds) {
        self.durationInSeconds = durationInSeconds
        self.durationType = durationType
    }
    
    func toAnyCodable() -> AnyCodable {
        return AnyCodable([
            "durationInSeconds": durationInSeconds,
            "durationType": durationType.rawValue
        ])
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

class Currency: AnyCodableConvertible {
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
    
    required init(data: [String: Any]?) {
        self.value = (data?["value"] as? NSNumber)?.doubleValue ?? 0
        let typeString = data?["currencyType"] as? String
        let type = CurrencyType.allCases.first { $0.rawValue.lowercased() == typeString?.lowercased() }
        self.currencyType = type ?? .usd
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
}

class Unit: AnyCodableConvertible {
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
    
    required init(data: [String: Any]?) {
        self.value = data?["value"] as? Int ?? 0
        self.unitType = UnitType(rawValue: data?["unitType"] as? String ?? "") ?? .count
        self.unitMeasure = UnitMeasure(rawValue: data?["unitMeasure"] as? String ?? "") ?? .none
    }
    
    func toAnyCodable() -> AnyCodable {
        return AnyCodable([
            "value": value,
            "unitType": unitType.rawValue,
            "unitMeasure": unitMeasure.rawValue
        ])
    }

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

class Todo: AnyCodableConvertible {
    var name: String
    var value: Bool
    var timeFinished: Date?
    
    static let defaultTodo = Todo()
    
    required init(data: [String: Any]?) {
        self.name = data?["name"] as? String ?? ""
        self.value = data?["value"] as? Bool ?? false
        self.timeFinished = data?["timeFinished"] as? Date ?? nil
    }
    
    func toAnyCodable() -> AnyCodable {
        var dict: [String: Any] = [
            "name": name,
            "value": value
        ]
        
        if let timeFinished = timeFinished {
            dict["timeFinished"] = timeFinished.toUTCString
        }
        
        return AnyCodable(dict)
    }

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
    
    required init(data: [String: Any]?) {
        self.value = data?["value"] as? String ?? ""
        self.timestamp = (data?["timestamp"] as? String)?.getDate ?? Date()
    }
    
    func toAnyCodable() -> AnyCodable {
        return AnyCodable([
            "value": value,
            "timestamp": timestamp.toUTCString
        ])
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
