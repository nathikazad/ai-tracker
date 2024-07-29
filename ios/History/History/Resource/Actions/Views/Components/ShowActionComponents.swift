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
    
    var body: some View {
        HStack {
            Text("\(fieldName): ")
                .frame(alignment: .leading)
            Spacer()
            TextField(fieldName, text: Binding(
                get: { value?.toString ?? "" },
                set: { newValue in
                    value = AnyCodable(newValue)
                }
            ))
            .frame(width: 150, alignment: .trailing)
            .multilineTextAlignment(.trailing)
        }
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
