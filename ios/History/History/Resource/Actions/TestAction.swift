//
//  TestAction.swift
//  History
//
//  Created by Nathik Azad on 7/27/24.
//

import Foundation

// Define structs to match the JSON structure
struct RootStruct: Codable {
    let schemas: [String: SchemaStruct]
    let values: [String: ValueStruct]
    let print: [String: String]
}

struct SchemaStruct: Codable {
    let name: String?
    let schema: [String: String]?

    enum CodingKeys: String, CodingKey {
        case name, schema
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Try to decode name as a string
        if let nameString = try? container.decode(String.self, forKey: .name) {
            self.name = nameString
        } else if let nameDict = try? container.decode([String: String].self, forKey: .name),
                  let nameValue = nameDict["name"] {
            self.name = nameValue
        } else {
            self.name = nil
        }
        
        self.schema = try? container.decode([String: String].self, forKey: .schema)
        print("Schema name: \(self.name ?? "")")
        if let schema = self.schema {
            print("Schema contents:")
            for (key, value) in schema {
                print("  \(key): \(value)")
            }
        } else {
            print("Schema is nil")
        }
    }
}

struct ValueStruct: Codable {
    let schema: String
    let value: [String: AnyCodable]
}

// Function to get nested value from a dictionary
func getNestedValue(_ dict: [String: Any], forKeyPath keyPath: String) -> Any? {
    let keys = keyPath.components(separatedBy: ".")
    print("keys \(keys) \(keyPath)")
    var result: Any? = dict
    
    print("result: \(result)")
    
    for key in keys {
        if let dictResult = result as? [String: Any] {
            result = dictResult[key]
        } else if let arrayResult = result as? [Any], let index = Int(key) {
            guard index < arrayResult.count else { return nil }
            result = arrayResult[index]
        } else {
            return nil
        }
    }
    
    return result
}

// Function to perform aggregate operations
func performAggregate(operation: String, on array: [Any], forKey key: String) -> Any? {
    let values = array.compactMap { item -> Double? in
        guard let dict = item as? [String: Any] else { return nil }
        return (dict[key] as? NSNumber)?.doubleValue
    }
    
    switch operation.lowercased() {
    case "sum":
        return values.reduce(0, +)
    case "avg":
        return values.isEmpty ? nil : values.reduce(0, +) / Double(values.count)
    case "min":
        return values.min()
    case "max":
        return values.max()
    case "count":
        return values.count
    default:
        return nil
    }
}

func printer() {
    let jsonData = jsonString.data(using: .utf8)!
    let decoder = JSONDecoder()
    let root = try! decoder.decode(RootStruct.self, from: jsonData)

    // Process print instructions
    var result: [String: AnyCodable] = [:]

    for (key, valuePath) in root.print {
        print("key: \(key)")
        if valuePath.contains(" ") {
            // Handle aggregate queries
            let components = valuePath.components(separatedBy: " ")
            if components.count == 3 {
                let operation = components[0]
                let objectKey = components[1].components(separatedBy: ".")[0]
                let propertyPath = components[1].components(separatedBy: ".")[1...].joined(separator: ".")
                let aggregateKey = components[2]
                
                if let objectValue = root.values[objectKey]?.value as? [String: Any],
                   let array = getNestedValue(objectValue, forKeyPath: propertyPath) as? [Any] {
                    result[key] = AnyCodable(performAggregate(operation: operation, on: array, forKey: aggregateKey) ?? NSNull())
                }
            }
        } else {
            // Handle simple queries
            let pathComponents = valuePath.components(separatedBy: ".")
            if pathComponents.count == 2 {
                let objectKey = pathComponents[0]
                let propertyKey = pathComponents[1]
                print("objectKey: \(objectKey)")
                print("propertyKey: \(propertyKey)")
                print("value: \(root.values[objectKey]?.value)")
                if let objectValue = root.values[objectKey]?.value{
                    if let propertyValue = getNestedValue(objectValue as! [String: Any], forKeyPath: propertyKey) {
                        print("propertyValue: \(getNestedValue(objectValue as [String: Any], forKeyPath: propertyKey))")
                        result[key] = AnyCodable(propertyValue)
                    }
                }
            }
        }
    }
    print(result)
    // Convert result to JSON
//    let jsonEncoder = JSONEncoder()
//    jsonEncoder.outputFormatting = .prettyPrinted
//    let resultData = try! jsonEncoder.encode(result)
//    let resultString = String(data: resultData, encoding: .utf8)!
//    print(resultString)
}

// Parse JSON
let jsonString = """
{
    "schemas": {
        "item": {
            "name": "Item",
            "schema": {
                "name": "string",
                "description": "string"
            }
        },
        "itemRow": {
            "name": "Item Row",
            "schema": {
                "item": "Item",
                "quantity": "number",
                "price": "number"
            }
        },
        "shopping": {
            "name": "Shopping",
            "schema": {
                "items": "Item Row[]",
                "date": "DateTime",
                "organization": "Organization",
                "total": "number"
            }
        },
        "organization": {
            "name": "Organization",
            "schema": {
                "name": "string",
                "location": "Location"
            }
        },
        "location": {
            "name": "Location",
            "schema": {
                "name": "string",
                "latitude": "number",
                "longitude": "number"
            }
        }
    },
    "values": {
        "shopping1": {
            "schema": "Shopping",
            "value": {
                "items": [
                    {
                        "item": "item1",
                        "quantity": 1,
                        "price": 10
                    },
                    {
                        "item": "item2",
                        "quantity": 2,
                        "price": 20
                    }
                ],
                "date": "2019-01-01T00:00:00Z",
                "organization": "organization1",
                "total": 50
            }
        },
        "item1": {
            "schema": "Item",
            "value": {
                "name": "item1",
                "description": "item1 description"
            }
        },
        "item2": {
            "schema": "Item",
            "value": {
                "name": "item2",
                "description": "item2 description"
            }
        },
        "organization1": {
            "schema": "Organization",
            "value": {
                "name": "organization1",
                "location": "location1"
            }
        },
        "location1": {
            "schema": "Location",
            "value": {
                "name": "Pismo",
                "latitude": 1,
                "longitude": 1
            }
        }
    },
    "print": {
        "print1": "shopping1.total",
        "print2": "location1.name",
        "print3": "sum shopping1.items.price"
    }
}
"""
