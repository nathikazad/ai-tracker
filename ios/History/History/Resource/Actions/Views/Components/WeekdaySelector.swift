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
    
    var body: some View {
        HStack(spacing: 0) {
            let days = Weekday.getDays(daysRange)
            ForEach(days, id: \.self) { day in
                Button(action: {
                    print(day)
                    selectedDay = day
                }) {
                    Text(day.name)
                        .font(.caption)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .frame(height: 32)
                        .background(day == selectedDay ? Color.gray.opacity(0.4) : Color.gray.opacity(0.1))
                        .foregroundColor(.primary)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
