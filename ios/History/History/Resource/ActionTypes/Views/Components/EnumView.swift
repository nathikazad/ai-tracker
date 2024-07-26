//
//  EnumView.swift
//  History
//
//  Created by Nathik Azad on 7/24/24.
//

import WrappingHStack
import SwiftUI

struct EnumView: View {
    @State private var newItem = ""
    @Binding var items: [String]
    
    var body: some View {
        VStack {
            HStack {
                Text("Enums:")
                TextField("Add Enum", text: $newItem)
                Button(action: addItem) {
                    Image(systemName: "plus")
                }
            }
            .padding()
            WrappingHStack(items, id: \.self) { item in
                ZStack(alignment: .topTrailing) {
                    Button(action: { deleteItem(item) }) {
                        Text(item)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                        .font(.system(size: 16))
                        .offset(x: 6, y: -6)
                }
                .padding(3)
            }
            .frame(minWidth: 250)
            .padding()
            
            
            
        }
    }
    private func addItem() {
        DispatchQueue.main.async {
            if !newItem.isEmpty {
                items.append(newItem)
                newItem = ""
            }
        }
    }
    
    private func deleteItem(_ item: String) {
        DispatchQueue.main.async {
            items.removeAll { $0 == item }
        }
    }
}
