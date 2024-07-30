//
//  ShowActionComponents.swift
//  History
//
//  Created by Nathik Azad on 7/28/24.
//

import SwiftUI

struct EnumComponent: View {
    let fieldName: String
    @Binding var value: AnyCodable?
    let enumValues: [String]
    
    var body: some View {
        HStack {
            Text("\(fieldName): ")
                .frame(alignment: .leading)
            Spacer()
            Picker("", selection: Binding(
                get: { value?.toString ?? enumValues.first ?? "None" },
                set: { newValue in
                    value = AnyCodable(newValue)
                }
            )) {
                ForEach(enumValues, id: \.self) { type in
                    Text(type).tag(type)
                }
            }
            .pickerStyle(MenuPickerStyle())
        }
    }
}

struct ShortStringComponent: View {
    let fieldName: String
    @Binding var value: AnyCodable?
    let isArray: Bool
    
    @State private var arrayValues: [String] = []
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(fieldName)
                .font(.headline)
            
            if isArray {
                ForEach(Array(arrayValues.enumerated()), id: \.offset) { index, item in
                    HStack {
                        TextField("Item \(index + 1)", text: bindingForIndex(index))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button(action: { removeItem(at: index) }) {
                            Image(systemName: "minus.circle")
                                .foregroundColor(.red)
                        }
                    }
                }
                
                Button(action: addNewItem) {
                    Label("Add Item", systemImage: "plus.circle")
                }
            } else {
                TextField(fieldName, text: Binding(
                    get: { value?.toString ?? "" },
                    set: { newValue in
                        value = AnyCodable(newValue)
                    }
                ))
                .textFieldStyle(RoundedBorderTextFieldStyle())
            }
        }
        .onAppear(perform: initializeArrayValues)
    }
    
    private func initializeArrayValues() {
        if isArray, let arrayValue = value?.value as? [String] {
            arrayValues = arrayValue
        }
    }
    
    private func bindingForIndex(_ index: Int) -> Binding<String> {
        return Binding(
            get: { arrayValues[index] },
            set: { newValue in
                arrayValues[index] = newValue
                updateValue()
            }
        )
    }
    
    private func addNewItem() {
        arrayValues.append("")
        updateValue()
    }
    
    private func removeItem(at index: Int) {
        arrayValues.remove(at: index)
        updateValue()
    }
    
    private func updateValue() {
        value = AnyCodable(arrayValues)
    }
}

struct LongStringComponent: View {
    let fieldName: String
    @Binding var value: AnyCodable?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(fieldName): ")
            TextEditor(text: Binding(
                get: { value?.toString ?? "" },
                set: { newValue in
                    value = AnyCodable(newValue)
                }
            ))
            .frame(height: 100)
            .padding(4)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(8)
        }
    }
}

extension AnyCodable {
    var toDuration: Duration? {
        return value as? Duration
    }
}

struct DurationComponent: View {
    let fieldName: String
    @Binding var value: AnyCodable?

    var duration: Binding<Duration> {
        return Binding(
            get: { value?.toDuration ?? Duration(durationInSeconds: 0, durationType: .seconds) },
            set: { newValue in
                value = AnyCodable(newValue)
            }
        )
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(fieldName):")
            HStack {
                TextField("Duration", value: duration.durationInSeconds, formatter: NumberFormatter())
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 100)
                
                Picker("Type", selection: duration.durationType) {
                    ForEach(Duration.DurationType.allCases, id: \.self) { type in
                        Text(type.rawValue.capitalized).tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
        }
    }
}

extension AnyCodable {
    var toUnit: Unit? {
        return value as? Unit
    }
}

struct UnitComponent: View {
    let fieldName: String
    @Binding var value: AnyCodable?

    var unit: Binding<Unit> {
        return Binding(
            get: { value?.toUnit ?? Unit(value: 0, unitType: .count, unitMeasure: .none) },
            set: { newValue in
                value = AnyCodable(newValue)
            }
        )
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(fieldName):")
            HStack {
                TextField("Value", value: unit.value, formatter: NumberFormatter())
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 100)
                
                Picker("Type", selection: unit.unitType) {
                    ForEach(Unit.UnitType.allCases, id: \.self) { type in
                        Text(type.rawValue.capitalized).tag(type)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                
                Picker("Measure", selection: unit.unitMeasure) {
                    ForEach(Unit.UnitMeasure.allCases, id: \.self) { measure in
                        Text(measure.rawValue.capitalized).tag(measure)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
        }
    }
}

extension AnyCodable {
    var toCurrency: Currency? {
        return value as? Currency
    }
}

struct CurrencyComponent: View {
    let fieldName: String
    @Binding var value: AnyCodable?

    var currency: Binding<Currency> {
        return Binding(
            get: { value?.toCurrency ?? Currency(value: 0, currencyType: "USD") },
            set: { newValue in
                value = AnyCodable(newValue)
            }
        )
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(fieldName):")
            HStack {
                TextField("Value", value: currency.value, formatter: NumberFormatter())
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 100)
                
                TextField("Currency Type", text: currency.currencyType)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
        }
    }
}

extension AnyCodable {
    var toTimeStampedString: TimeStampedString? {
        return value as? TimeStampedString
    }
}

struct TimeStampedStringComponent: View {
    let fieldName: String
    @Binding var value: AnyCodable?
    let isArray: Bool
    
    @State private var arrayValues: [TimeStampedString] = []
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(fieldName)
                .font(.headline)
            
            if isArray {
                ForEach(Array(arrayValues.enumerated()), id: \.offset) { index, _ in
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Item \(index + 1)")
                            Spacer()
                            Button(action: { removeItem(at: index) }) {
                                Image(systemName: "minus.circle")
                                    .foregroundColor(.red)
                            }
                        }
                        TextField("Value", text: bindingForIndex(index).value)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        DatePicker("Timestamp", selection: bindingForIndex(index).timestamp, displayedComponents: [.date, .hourAndMinute])
                    }
                    .padding(.bottom, 10)
                }
                
                Button(action: addNewItem) {
                    Label("Add Item", systemImage: "plus.circle")
                }
            } else {
                TextField("Value", text: timeStampedString.value)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                DatePicker("Timestamp", selection: timeStampedString.timestamp, displayedComponents: [.date, .hourAndMinute])
            }
        }
        .onAppear(perform: initializeArrayValues)
    }
    
    private var timeStampedString: Binding<TimeStampedString> {
        Binding(
            get: { value?.toTimeStampedString ?? TimeStampedString(value: "", timestamp: Date()) },
            set: { newValue in
                value = AnyCodable(newValue)
            }
        )
    }
    
    private func initializeArrayValues() {
        if isArray, let arrayValue = value?.value as? [TimeStampedString] {
            arrayValues = arrayValue
        }
    }
    
    private func bindingForIndex(_ index: Int) -> Binding<TimeStampedString> {
        return Binding(
            get: { arrayValues[index] },
            set: { newValue in
                arrayValues[index] = newValue
                updateValue()
            }
        )
    }
    
    private func addNewItem() {
        arrayValues.append(TimeStampedString(value: "", timestamp: Date()))
        updateValue()
    }
    
    private func removeItem(at index: Int) {
        arrayValues.remove(at: index)
        updateValue()
    }
    
    private func updateValue() {
        value = AnyCodable(arrayValues)
    }
}
