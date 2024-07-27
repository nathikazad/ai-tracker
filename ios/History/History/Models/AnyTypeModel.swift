////
////  AnyTypeModel.swift
////  History
////
////  Created by Nathik Azad on 7/25/24.
////
//
import Foundation
struct AnyCodable: Codable {
    let value: Any
    
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
}

//struct AnyCodable: Codable {
//    let value: Any
//    
//    init(_ value: Any) {
//        self.value = value
//    }
//    
//    init(from decoder: Decoder) throws {
//        let container = try decoder.singleValueContainer()
//        print("Attempting to decode AnyCodable")
//        
//        if let value = try? container.decode(String.self) {
//            print("Decoded as String: \(value)")
//            self.value = value
//        } else if let value = try? container.decode(Int.self) {
//            print("Decoded as Int: \(value)")
//            self.value = value
//        } else if let value = try? container.decode(Double.self) {
//            print("Decoded as Double: \(value)")
//            self.value = value
//        } else if let value = try? container.decode(Bool.self) {
//            print("Decoded as Bool: \(value)")
//            self.value = value
//        } else if let value = try? container.decode([String: AnyCodable].self) {
//            print("Decoded as Dictionary: \(value)")
//            self.value = value
//        } else if let value = try? container.decode([AnyCodable].self) {
//            print("Decoded as Array: \(value)")
//            self.value = value
//        } else {
//            print("Failed to decode as any known type")
//            // Here, you can add more detailed debugging
//            do {
//                let rawValue = try container.decode(Data.self)
//                print("Raw data: \(String(data: rawValue, encoding: .utf8) ?? "Unable to convert to string")")
//            } catch {
//                print("Unable to decode as raw data: \(error)")
//            }
//            throw DecodingError.dataCorruptedError(in: container, debugDescription: "AnyCodable value cannot be decoded")
//        }
//    }
//    
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.singleValueContainer()
//        switch value {
//        case let value as String:
//            try container.encode(value)
//        case let value as Int:
//            try container.encode(value)
//        case let value as Double:
//            try container.encode(value)
//        case let value as Bool:
//            try container.encode(value)
//        case let value as [String: Any]:
//            try container.encode(value.mapValues { AnyCodable($0) })
//        case let value as [Any]:
//            try container.encode(value.map { AnyCodable($0) })
//        default:
//            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "AnyCodable value cannot be encoded"))
//        }
//    }
//}
