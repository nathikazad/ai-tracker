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
            let gradient = LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 178/255, green: 72/255, blue: 49/255),
                    Color(red: 222/255, green: 152/255, blue: 64/255)
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
            Text(day)
                .font(.system(size: 14, weight: .medium))
                .frame(width: 30, height: 30)
                .background(
                    isSelected
                    ? AnyView(gradient)
                    : AnyView(Color.gray.opacity(0.2))
                )
                .foregroundColor(isSelected ? .white : .black)
                .clipShape(Circle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}
