//
//  DynamicFieldsView.swift
//  History
//
//  Created by Nathik Azad on 7/31/24.
//

import SwiftUI
struct DynamicFieldsView: View {
    @Binding var dynamicFields: [String: Schema]
    @Binding var dynamicData: [String: AnyCodable]
    var updateView: (() -> Void)
    var body: some View {
        Section(header: Text("Dynamic Fields")) {
            ForEach(Array(dynamicFields.keys), id: \.self) { key in
                if let field = dynamicFields[key] {
                    if let dataType = getDataType(from: field.dataType) {
                        Group {
                            switch dataType {
                            case .longString:
                                LongStringComponent(fieldName: field.name,
                                                    value: bindingFor(key, "") as Binding<String>)
                            case .shortString:
                                ShortStringComponent(fieldName: field.name,
                                                        value: bindingFor(key, "") as Binding<String>)
                            case .enumerator:
                                EnumComponent(fieldName: field.name,
                                                value: bindingFor(key, field.getEnums.first!),
                                                enumValues: field.getEnums)
                            case .unit:
                                UnitComponent(
                                    fieldName: field.name,
                                    unit: bindingFor(key, Unit.defaultUnit) as Binding<Unit>
                                )
                            case .currency:
                                CurrencyComponent(
                                    fieldName: field.name,
                                    currency: bindingFor(key, Currency.defaultCurrency) as Binding<Currency>
                                )
                            case .duration:
                                DurationComponent(
                                    fieldName: field.name,
                                    duration: bindingFor(key, Duration.defaultDuration) as Binding<Duration>
                                )
                            case .dateTime:
                                TimeComponent(
                                    fieldName: field.name,
                                    time: bindingFor(key, Date()) as Binding<Date>
                                )
                            case .time:
                                TimeComponent(
                                    fieldName: field.name,
                                    time: bindingFor(key, Date()) as Binding<Date>
                                )
                            default:
                                EmptyView()
                            }
                        }
                    }
                }
            }
        }

    }
    
    private func bindingFor<T>(_ key: String, _ defaultValue: T) -> Binding<T> {
        return Binding(
            get: {
                (dynamicData[key]?.toType(T.self) as? T) ?? defaultValue
            },
            set: { newValue in
                dynamicData[key] = AnyCodable(newValue)
                updateView()
            }
        )
    }
}
