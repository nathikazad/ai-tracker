//
//  WeekdaysComponent.swift
//  History
//
//  Created by Nathik Azad on 8/6/24.
//

import SwiftUI
struct WeekdaySelector: View {
    @Binding var selectedDays: [Int]
    
    let days = ["S", "M", "T", "W", "T", "F", "S"]
    
    var body: some View {
        HStack {
            Text("Days:")
            
            Spacer()
            Button("All") {
                selectedDays = Array(0..<7)
            }
            .padding(6)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(6)
            .buttonStyle(PlainButtonStyle())
            Button("None") {
                selectedDays = []
            }
            .padding(6)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(6)
            .buttonStyle(PlainButtonStyle())
        }
        HStack(spacing: 8) {
            ForEach(0..<7) { index in
                DayButton(day: days[index], isSelected: selectedDays.contains(index)) {
                    toggleDay(index)
                }
            }
        }
    }
    
    private func toggleDay(_ index: Int) {
        if let selectedIndex = selectedDays.firstIndex(of: index) {
            selectedDays.remove(at: selectedIndex)
        } else {
            selectedDays.append(index)
        }
    }
}

struct DayButton: View {
    let day: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(day)
                .font(.system(size: 14, weight: .medium))
                .frame(width: 30, height: 30)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .black)
                .clipShape(Circle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}
