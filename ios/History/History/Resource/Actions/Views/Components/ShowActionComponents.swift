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
                Text("None").tag("None")
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
    @State var valueCopy: String = ""
    @State private var isBeingEdited: Bool
    let isNumeric: Bool
    
    init(fieldName: String, value: Binding<String>, isNumeric: Bool = false) {
        self.fieldName = fieldName
        self._value = value
        self._valueCopy = State(wrappedValue: value.wrappedValue)
        self.isNumeric = isNumeric
        self._isBeingEdited = State(initialValue: value.wrappedValue.isEmpty)
    }
    
    private var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }
    
    var body: some View {
        HStack {
            Text("\(fieldName): ")
                .frame(alignment: .leading)
            Spacer()
            if isBeingEdited {
                if isNumeric {
                    TextField(fieldName, text: Binding(
                        get: { valueCopy },
                        set: { newValue in
                            if let _ = Double(newValue) {
                                valueCopy = newValue
                                value = newValue
                            }
                        }
                    ))
                    .keyboardType(.decimalPad)
                } else {
                    TextField(fieldName, text: Binding(
                        get: { valueCopy },
                        set: { newValue in
                            valueCopy = newValue
                            value = newValue
                        }
                    ))
                    .keyboardType(.default)
                }
            } else {
                if isNumeric, let number = numberFormatter.number(from: value) {
                    Text(numberFormatter.string(from: number) ?? value)
                } else if let url = URL(string: value), UIApplication.shared.canOpenURL(url) {
                    Link(destination: url) {
                        Text("Link")
                            .foregroundColor(.blue)
                            .underline()
                    }
                } else {
                    Text(value)
                }
                Button(action: {
                    if !isBeingEdited {
                        valueCopy = value
                    }
                    isBeingEdited = true
                }) {
                    Image(systemName: "pencil")
                        .foregroundColor(.gray)
                }
                .buttonStyle(PlainButtonStyle())
                .frame(width: 30, height: 30)
                .background(Color(UIColor.systemGray6))
                .clipShape(Circle())
            }
        }
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.trailing)
        .submitLabel(.done)
        .onSubmit {
            isBeingEdited = false
        }
    }
}

struct LongStringComponent: View {
    let fieldName: String
    @Binding var value: String
    @State var valueCopy: String = ""
    @State var isBeingEdited: Bool
    
    init(fieldName: String, value: Binding<String>) {
        self.fieldName = fieldName
        self._value = value
        self._valueCopy = State(wrappedValue: value.wrappedValue)
        self._isBeingEdited = State(initialValue: value.wrappedValue.isEmpty)
    }
    
    var height: CGFloat {
        return CGFloat(integerLiteral: max(100, value.filter { $0 == "\n" }.count * 28 + 50 + value.count/27 * 20))
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("\(fieldName): ")
                Spacer()
                if !isBeingEdited {
                    Button(action: {
                        value = value
                        isBeingEdited = true
//                        isFocused = true
                    }) {
                        Image(systemName: "pencil")
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .frame(width: 30, height: 30)
                    .background(Color(UIColor.systemGray6))
                    .clipShape(Circle())
                }
            }
            .padding(.leading, -10)
                
            if isBeingEdited {
                TextEditor(text: Binding(
                    get: { valueCopy },
                    set: { newValue in
                        valueCopy = newValue
                        value = newValue
                    }
                ))
                .frame(height: height)
                .padding(4)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(8)
                .navigationBarTitleDisplayMode(.inline)
            } else {
                let (textWithoutLinks, urls) = extractTextAndURLs(from: value)
                
                Text(textWithoutLinks)
                    .padding(.bottom, 8)
                    .padding(.leading, -10)
                if !urls.isEmpty {
                    Text("Links:")
                        .padding(.top, 4)
                    ForEach(urls, id: \.self) { url in
                        Link(destination: url) {
                            Text(url.absoluteString)
                                .foregroundColor(.blue)
                                .underline()
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
        .padding(.leading, 10)
        .padding(.bottom, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func extractTextAndURLs(from text: String) -> (String, [URL]) {
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector?.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count)) ?? []
        
        var textWithoutLinks = text
        let urls = matches.compactMap { match -> URL? in
            guard let range = Range(match.range, in: text),
                  let url = URL(string: String(text[range])) else {
                return nil
            }
            
            // Remove the URL from the text
            textWithoutLinks = textWithoutLinks.replacingOccurrences(of: String(text[range]), with: "")
            return url
        }
        
        // Trim any extra whitespace and newlines
        textWithoutLinks = textWithoutLinks.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return (textWithoutLinks, urls)
    }
}

struct DurationComponent: View {
    let fieldName: String
    @Binding var duration: Duration
    @State var valueCopy: Int = 0
    
    var body: some View {
        HStack {
            Text("\(fieldName):")
            Spacer()
            TextField("Duration", value: $duration.durationInSeconds, formatter: NumberFormatter())
                .multilineTextAlignment(.trailing)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 80)
            Picker("", selection: $duration.durationType) {
                ForEach(Duration.DurationType.allCases, id: \.self) { type in
                    Text(type.rawValue.capitalized).tag(type)
                }
            }
            .frame(width: Duration.DurationType.allCases.map { $0.rawValue.capitalized }.map { CGFloat($0.count * 15) }.max() ?? 100)
            .clipped()
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
    
    private let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    var body: some View {
        HStack (spacing: 0) {
            Text("\(fieldName):")
            Spacer()
            TextField("", value: $currency.value, formatter: formatter)
                .multilineTextAlignment(.trailing)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 80)
                .padding(.horizontal, 0)
            
            Picker("", selection: $currency.currencyType) {
                ForEach(Currency.CurrencyType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                        .padding(.horizontal, 0)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .frame(width: 75)
            .padding(.horizontal, 0)
            
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
    @Binding var time: Date?
    let onlyTime: Bool

    var body: some View {
        HStack {
            Text(fieldName)
            Spacer()
            if let boundTime = Binding($time) {
                DatePicker("",
                           selection: boundTime,
                           displayedComponents: onlyTime ? .hourAndMinute : [.date, .hourAndMinute])
            } else {
                Button("Set") {
                    time = Date()
                }
                .padding(6)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(6)
            }
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
