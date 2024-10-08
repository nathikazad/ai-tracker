//
//  ColorHelper.swift
//  History
//
//  Created by Nathik Azad on 8/8/24.
//

import SwiftUI

extension Color {
    static let maroon = Color(red: 128 / 255, green: 0 / 255, blue: 0 / 255)
    static let olive = Color(red: 128 / 255, green: 128 / 255, blue: 0 / 255)
    static let lavender = Color(red: 230 / 255, green: 230 / 255, blue: 250 / 255)
    static let silver = Color(red: 192 / 255, green: 192 / 255, blue: 192 / 255)
    static let magenta = Color(red: 255 / 255, green: 0 / 255, blue: 255 / 255)
    
    // New distinct colors
    static let teal = Color(red: 0 / 255, green: 128 / 255, blue: 128 / 255)
    static let coral = Color(red: 255 / 255, green: 127 / 255, blue: 80 / 255)
    static let indigo = Color(red: 75 / 255, green: 0 / 255, blue: 130 / 255)
    static let turquoise = Color(red: 64 / 255, green: 224 / 255, blue: 208 / 255)
    static let crimson = Color(red: 220 / 255, green: 20 / 255, blue: 60 / 255)
    static let gold = Color(red: 255 / 255, green: 215 / 255, blue: 0 / 255)
    static let emerald = Color(red: 80 / 255, green: 200 / 255, blue: 120 / 255)
    static let plum = Color(red: 221 / 255, green: 160 / 255, blue: 221 / 255)
}

class ASColor {
    static let colors: [(Color, String)] = [
        (.red, "Red"),
        (.blue, "Blue"),
        (.green, "Green"),
        (.orange, "Orange"),
        (.purple, "Purple"),
        (.yellow, "Yellow"),
        (.cyan, "Cyan"),
        (.brown, "Brown"),
        (.maroon, "Maroon"),
        (.olive, "Olive"),
        (.lavender, "Lavender"),
        (.silver, "Silver"),
        (.magenta, "Magenta"),
        (.black, "Black"),
        (.white, "White"),
        (.gray, "Gray"),
        // New distinct colors
        (.teal, "Teal"),
        (.coral, "Coral"),
        (.indigo, "Indigo"),
        (.turquoise, "Turquoise"),
        (.crimson, "Crimson"),
        (.gold, "Gold"),
        (.emerald, "Emerald"),
        (.plum, "Plum")
    ]
    
    static func colorToString(_ color: Color) -> String {
        return colors.first { $0.0 == color }?.1 ?? "Unknown"
    }

    static func stringToColor(_ string: String) -> Color {
        return colors.first { $0.1.lowercased() == string.lowercased() }?.0 ?? .red
    }
}

struct CompactColorPickerWithLabel: View {
    @Binding var selectedColor: Color
    @State private var isPickerVisible: Bool = false
    
    let columns = [
        GridItem(.adaptive(minimum: 30))
    ]
    
    var body: some View {
        HStack {
            if !isPickerVisible {
                Text("Color:")

            }
            Spacer()
            
            
            ZStack {
                Circle()
                    .fill(selectedColor)
                    .frame(width: 20, height: 20)
                    .onTapGesture {
                        withAnimation {
                            isPickerVisible.toggle()
                        }
                    }
                
                if isPickerVisible {
                    CompactColorPicker(selectedColor: $selectedColor, isPickerVisible: $isPickerVisible)
                        .transition(.slide)
                }
            }
        }
    }
}


struct CompactColorPicker: View {
    @Binding var selectedColor: Color
    @Binding var isPickerVisible: Bool
    
    let columns = [
        GridItem(.adaptive(minimum: 30))
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(ASColor.colors.indices, id: \.self) { index in
                ZStack {
                    Circle()
                        .fill(ASColor.colors[index].0)
                        .frame(width: 25, height: 25)
                    
                    if selectedColor == ASColor.colors[index].0 {
                        Image(systemName: "checkmark")
                            .foregroundColor(.white)
                            .font(.system(size: 12, weight: .bold))
                    }
                }
                .onTapGesture {
                    selectedColor = ASColor.colors[index].0
                    isPickerVisible = false
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 5)
    }
}
