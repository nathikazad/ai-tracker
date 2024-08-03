////
////  AnyTypeModel.swift
////  History
////
////  Created by Nathik Azad on 7/25/24.
////
//
import Foundation
struct AnyCodable: Codable {
    var value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intValue = try? container.decode(Int.self) {
            value = intValue
        } else if let doubleValue = try? container.decode(Double.self) {
            value = doubleValue
        } else if let stringValue = try? container.decode(String.self) {
            value = stringValue
        } else if let boolValue = try? container.decode(Bool.self) {
            value = boolValue
        } else if let arrayValue = try? container.decode([AnyCodable].self) {
            value = arrayValue.map { $0.value }
        } else if let dictionaryValue = try? container.decode([String: AnyCodable].self) {
            value = dictionaryValue.mapValues { $0.value }
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "AnyCodable value cannot be decoded")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch value {
        case let number as NSNumber:
            try container.encode(number.doubleValue)
        case let string as String:
            try container.encode(string)
        case let bool as Bool:
            try container.encode(bool)
        case let array as [Any]:
            try container.encode(array.map(AnyCodable.init))
        case let dictionary as [String: Any]:
            try container.encode(dictionary.mapValues(AnyCodable.init))
        case Optional<Any>.none:
            try container.encodeNil()
        default:
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: container.codingPath, debugDescription: "AnyCodable value cannot be encoded"))
        }
    }
    
    var toString: String {
        switch value {
        case let number as NSNumber:
            return number.stringValue
        case let string as String:
            return string
        case let bool as Bool:
            return bool ? "true" : "false"
        case let array as [Any]:
            return "[" + array.map { String(describing: AnyCodable($0)) }.joined(separator: ", ") + "]"
        case let dictionary as [String: Any]:
            let elements = dictionary.map { key, value in
                "\"\(key)\": \(String(describing: AnyCodable(value)))"
            }.joined(separator: ", ")
            return "[" + elements + "]"
        case Optional<Any>.none:
            return "nil"
        default:
            return "AnyCodable(\(String(describing: value)))"
        }
    }

    var toInt: Int? {
        if let number = value as? NSNumber {
            return number.intValue
        } else {
            return nil
        }
    }
    
    func toType<T>(_ type: T.Type) -> T? {
        switch type {
        case let convertibleType as AnyCodableConvertible.Type:
            return convertibleType.init(data: value as? [String: Any]) as? T
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
        case let convertible as AnyCodableConvertible:
            return convertible.toAnyCodable()
        case let date as Date:
            return AnyCodable(date.toUTCString)
        case is String:
            return AnyCodable(value)
        default:
            return nil
        }
    }
}

protocol AnyCodableConvertible {
    init(data: [String: Any]?)
    func toAnyCodable() -> AnyCodable
}

extension Dictionary where Key == String, Value == AnyCodable {
    var toJson: [String: Any] {
        return self.compactMapValues { anyCodable in
            do {
                let data = try JSONEncoder().encode(anyCodable)
                return try JSONSerialization.jsonObject(with: data, options: [])
            } catch {
                return nil
            }
        }
    }
}
