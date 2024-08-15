//
//  SchemaView.swift
//  History
//
//  Created by Nathik Azad on 7/24/24.
//

import Foundation
import SwiftUI
struct SchemaView: View {
    @Binding var schema: Schema
    var dataType: DataType?
    var validDataTypes: [String] = []
    
    init(schema: Binding<Schema>, dataType: DataType? = nil, validDataTypes: [String]? = nil) {
        self._schema = schema
        self.dataType = dataType
        self.validDataTypes = validDataTypes ?? []
        
        if let dataType = dataType {
            self._schema.wrappedValue.dataType = dataType
        }
    }
    
    var body: some View {
        HStack {
            Text("Name:")
                .frame(alignment: .leading)
            Spacer()
            TextField("Name", text: $schema.name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .multilineTextAlignment(.trailing)
                    .frame(width: 100)
        }
        
        HStack {
            Text("Type:")
            if dataType == nil {
                Picker("", selection: $schema.dataType) {
                    ForEach(validDataTypes, id: \.self) { type in
                        Text(type).tag(type)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            } else {
                Text(schema.dataType.rawValue)
            }
        }
        
        VStack(alignment: .leading) {
            Text("Description:")
            TextEditor(text: $schema.description)
                .frame(height: 100)  // Adjust this value to approximate 4 lines
                .padding(4)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(8)
        }
        
        if schema.dataType == .enumerator {
            EnumView(items: $schema.enumValues)
        }
    }
}
