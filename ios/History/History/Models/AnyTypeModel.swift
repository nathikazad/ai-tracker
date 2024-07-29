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
    
    func toJSONCompatible() -> Any {
        switch value {
        case let number as NSNumber:
            return number
        case let string as String:
            return string
        case let bool as Bool:
            return bool
        case let array as [Any]:
            return array.map { AnyCodable($0).toJSONCompatible() }
        case let dictionary as [String: Any]:
            return dictionary.mapValues { AnyCodable($0).toJSONCompatible() }
        case is AnyCodable:
            return (value as! AnyCodable).toJSONCompatible()
        case Optional<Any>.none:
            return NSNull()
        default:
            return String(describing: value)
        }
    }
}

extension Dictionary where Key == String, Value == AnyCodable {
    func toJson() -> [String: Any] {
        return self.mapValues { $0.toJSONCompatible() }
    }
}
