//
//  ShowActionComponents.swift
//  History
//
//  Created by Nathik Azad on 7/28/24.
//

import SwiftUI

struct EnumComponent: View {
    let fieldName: String
    @Binding var value: String
    let enumValues: [String]
    
    var body: some View {
        HStack {
            Text("\(fieldName): ")
                .frame(alignment: .leading)
            Spacer()
            Picker("", selection: $value) {
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
    @Binding var value: String
    var body: some View {
        HStack {
            Text("\(fieldName): ")
                .frame(alignment: .leading)
            Spacer()
            TextField(fieldName, text: Binding(
                get: { value },
                set: { newValue in
                    value = newValue
                }
            ))
            .frame(width: 150, alignment: .trailing)
            .multilineTextAlignment(.trailing)
            .keyboardType(.default)
            .submitLabel(.done)
        }
    }
}

struct LongStringComponent: View {
    let fieldName: String
    @Binding var value: String
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(fieldName): ")
            TextEditor(text: Binding(
                get: { value },
                set: { newValue in
                    value = newValue
                }
            ))
            .frame(height: 100)
            .padding(4)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(8)
            .focused($isFocused)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button(action: {
                        isFocused = false
                    }) {
                        HStack {
                            Text("Dismiss Keyboard")
                            Image(systemName: "chevron.down")
                        }
                    }
                }
            }
        }
    }
}

struct DurationComponent: View {
    let fieldName: String
    @Binding var duration: Duration
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(fieldName):")
            HStack {
                TextField("Duration", value: $duration.durationInSeconds, formatter: NumberFormatter())
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 100)
                
                Picker("Type", selection: $duration.durationType) {
                    ForEach(Duration.DurationType.allCases, id: \.self) { type in
                        Text(type.rawValue.capitalized).tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
        }
    }
}

struct UnitComponent: View {
    let fieldName: String
    @Binding var unit: Unit
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(fieldName):")
            HStack {
                TextField("Value", value: $unit.value, formatter: NumberFormatter())
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 100)
                
                Picker("Type", selection: $unit.unitType) {
                    ForEach(Unit.UnitType.allCases, id: \.self) { type in
                        Text(type.rawValue.capitalized).tag(type)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                
                Picker("Measure", selection: $unit.unitMeasure) {
                    ForEach(Unit.UnitMeasure.allCases, id: \.self) { measure in
                        Text(measure.rawValue.capitalized).tag(measure)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
        }
    }
}

struct CurrencyComponent: View {
    let fieldName: String
    @Binding var currency: Currency
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(fieldName):")
            HStack {
                TextField("Value", value: $currency.value, formatter: NumberFormatter())
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 100)
                
                TextField("Currency Type", text: $currency.currencyType)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
        }
    }
}

struct TodoComponent: View {
    let fieldName: String
    @Binding var todo: Todo
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(fieldName):")
            HStack {
                TextField("Name", text: $todo.name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Toggle("", isOn: $todo.value)
                    .labelsHidden()
            }
        }
    }
}

struct TimeStampedStringComponent: View {
    let fieldName: String
    @Binding var timeStampedString: TimeStampedString
    var body: some View {
        VStack(alignment: .leading) {
            Text(fieldName)
                .font(.headline)
            TextField("Value", text: $timeStampedString.value)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            DatePicker("Timestamp", selection: $timeStampedString.timestamp, displayedComponents: [.date, .hourAndMinute])
        }
    }
}

struct TimeComponent: View {
    let fieldName: String
    @Binding var time: Date
    var body: some View {
        VStack(alignment: .leading) {
            Text(fieldName)
                .font(.headline)
            DatePicker("Timestamp", selection: $time, displayedComponents: [.date, .hourAndMinute])
        }
    }
}





//    var body: some View {
//        VStack(alignment: .leading) {
//            Text(fieldName)
//                .font(.headline)
//
//            if isArray {
//                ForEach(Array(arrayValues.enumerated()), id: \.offset) { index, item in
//                    HStack {
//                        TextField("Item \(index + 1)", text: bindingForIndex(index))
//                            .textFieldStyle(RoundedBorderTextFieldStyle())
//
//                        Button(action: { removeItem(at: index) }) {
//                            Image(systemName: "minus.circle")
//                                .foregroundColor(.red)
//                        }
//                    }
//                }
//
//                Button(action: addNewItem) {
//                    Label("Add Item", systemImage: "plus.circle")
//                }
//            } else {
//                TextField(fieldName, text: Binding(
//                    get: { value?.toString ?? "" },
//                    set: { newValue in
//                        value = AnyCodable(newValue)
//                    }
//                ))
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//            }
//        }
//        .onAppear(perform: initializeArrayValues)
//    }
//
//    private func initializeArrayValues() {
//        if isArray, let arrayValue = value?.value as? [String] {
//            arrayValues = arrayValue
//        }
//    }
//
//    private func bindingForIndex(_ index: Int) -> Binding<String> {
//        return Binding(
//            get: { arrayValues[index] },
//            set: { newValue in
//                arrayValues[index] = newValue
//                updateValue()
//            }
//        )
//    }
//
//    private func addNewItem() {
//        arrayValues.append("")
//        updateValue()
//    }
//
//    private func removeItem(at index: Int) {
//        arrayValues.remove(at: index)
//        updateValue()
//    }
//
//    private func updateValue() {
//        value = AnyCodable(arrayValues)
//    }
