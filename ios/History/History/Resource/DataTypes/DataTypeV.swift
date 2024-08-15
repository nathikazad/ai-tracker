//
//  ViewDataType.swift
//  History
//
//  Created by Nathik Azad on 8/2/24.
//

import Foundation
import SwiftUI

struct ViewDataType: View {
    let dataType: DataType
    let name: String
    let enums: [String]
    @Binding var value: AnyCodable?
    
    @ViewBuilder
    var body: some View {
        switch dataType {
        case .longString:
            LongStringComponent(fieldName: name,
                                value: bindingFor(""))
        case .shortString:
            ShortStringComponent(fieldName: name,
                                 value: bindingFor(""))
        case .number:
            ShortStringComponent(fieldName: name,
                                 value: bindingFor(""))
        case .enumerator:
            EnumComponent(fieldName: name,
                          value: bindingFor(enums.first!),
                          enumValues: enums)
            //            case .unit:
            //                UnitComponent(
            //                    fieldName: name,
            //                    unit: bindingFor(Unit.defaultUnit)
            //                )
        case .currency:
            CurrencyComponent(
                fieldName: name,
                currency: bindingFor(Currency.defaultCurrency)
            )
        case .duration:
            DurationComponent(
                fieldName: name,
                duration: bindingFor(Duration.defaultDuration)
            )
        case .dateTime, .time:
            TimeComponent(
                fieldName: name,
                time: bindingFor(Date.self),
                onlyTime: dataType == .time
            )
        default:
            EmptyView()
        }
    }
    
    private func bindingFor<T>(_ defaultValue: T) -> Binding<T> {
        if  value == nil && !(T.self is Date.Type) {
            value = AnyCodable.fromType(defaultValue)
        }
        return Binding(
            get: {
                return (value?.toType(T.self) as? T) ?? defaultValue
            },
            set: { newValue in
                value = AnyCodable.fromType(newValue)
            }
        )
    }
    
    private func bindingFor<T>(_ type: T.Type) -> Binding<T?> where T: Codable {
        return Binding(
            get: {
                return self.value?.toType(T.self) ?? nil
            },
            set: { newValue in
                if let newValue = newValue {
                    self.value = AnyCodable.fromType(newValue)
                } else {
                    self.value = nil
                }
            }
        )
    }
}
