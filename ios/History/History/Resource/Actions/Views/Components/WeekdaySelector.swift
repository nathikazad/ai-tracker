//
//  WeekdaySelector.swift
//  History
//
//  Created by Nathik Azad on 8/12/24.
//

import SwiftUI
struct WeekdaySelectorForCandles: View {
    @Binding var selectedDay: Weekday
    @Binding var daysRange: ClosedRange<Int>
    @Binding var selectedGrouping: SelectedGrouping
    @Binding var allSelected: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            if selectedGrouping == .byPercentage {
                Button(action: {
                    allSelected.toggle()
                }) {
                    Text("All")
                        .font(.caption)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .frame(height: 32)
                        .background(allSelected ? Color.gray.opacity(0.4) : Color.gray.opacity(0.1))
                        .foregroundColor(.primary)
                }
                .buttonStyle(PlainButtonStyle())
            }
            let days = Weekday.getDays(daysRange)
            ForEach(days, id: \.self) { day in
                Button(action: {
                    selectedDay = day
                    allSelected = false
                }) {
                    Text(day.name)
                        .font(.caption)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .frame(height: 32)
                        .background(!allSelected && day == selectedDay ? Color.gray.opacity(0.4) : Color.gray.opacity(0.1))
                        .foregroundColor(.primary)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
