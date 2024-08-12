//
//  RadioButton.swift
//  History
//
//  Created by Nathik Azad on 8/10/24.
//

import SwiftUI
struct RadioButton: View {
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .stroke(Color.gray, lineWidth: 2)
                    .frame(width: 20, height: 20)
                if isSelected {
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 12, height: 12)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
