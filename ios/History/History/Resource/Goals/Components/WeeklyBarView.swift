//
//  WeeklyBarView.swift
//  History
//
//  Created by Nathik Azad on 8/12/24.
//

import SwiftUI
struct WeeklyBarView: View {
    let weeklyDurations: [[(Date, Int, Int)]]
    let mark: Double?
    let aggregate: AggregateModel
    let showWeekNavigator: Bool
    @State var showCumView: Bool = true
    @State private var currentWeekIndex = 0

    var body: some View {
        if !weeklyDurations.isEmpty {
            VStack {
                if showWeekNavigator {
                    WeekNavigatorForBarGraph(currentWeekIndex: $currentWeekIndex, weeklyDurations: weeklyDurations)
                }

                let (array, label) = convertCumDurationsToRightUnit(dateCounts: weeklyDurations[currentWeekIndex], aggregate: aggregate, cumulative: showCumView)
                
                ZStack(alignment: .topLeading) {
                    if showCumView {
                        BarView(data: array, yAxisLabel: "Cumulative \(label)", yMark: mark,
                                x1Mark: weeklyDurations[currentWeekIndex].first!.0,
                                x2Mark: weeklyDurations[currentWeekIndex].last!.0)
                        .id("week_\(currentWeekIndex)")
                        .transition(.opacity)
                        .animation(.default, value: currentWeekIndex)
                    } else {
                        BarView(data: array, yAxisLabel: "Daily \(label)", yMark: mark == 0 ? nil : mark!/7)
                        .id("week_\(currentWeekIndex)")
                        .transition(.opacity)
                        .animation(.default, value: currentWeekIndex)
                    }
                    
                    Button(action: {
                        showCumView.toggle()
                    }) {
                        Image(systemName: "arrow.left.arrow.right.square")
                            .foregroundColor(Color.primary)
                            .padding(8)
                            .background(Color.secondary.opacity(0.8))
                            .clipShape(Circle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(8)
                }
            }
        } else {
            Text("No data available")
        }
    }
}


struct WeekNavigatorForBarGraph: View {
    @Binding var currentWeekIndex: Int
    let weeklyDurations: [[(Date, Int, Int)]]

    var body: some View {
        HStack {
            Button(action: previousWeek) {
                Image(systemName: "chevron.left")
                    .foregroundColor(currentWeekIndex > 0 ? .blue : .gray)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(currentWeekIndex == 0)
            
            Spacer()
            
            Text(weekTitle)
                .font(.headline)
            
            Spacer()
            
            Button(action: nextWeek) {
                Image(systemName: "chevron.right")
                    .foregroundColor(currentWeekIndex < weeklyDurations.count - 1 ? .blue : .gray)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(currentWeekIndex == weeklyDurations.count - 1)
        }
        .padding()
    }
    
    private var weekTitle: String {
        guard !weeklyDurations.isEmpty && weeklyDurations.indices.contains(currentWeekIndex) else {
            return "No Data"
        }
        
        let currentWeek = weeklyDurations[currentWeekIndex]
        guard let firstDay = currentWeek.first?.0, let lastDay = currentWeek.last?.0 else {
            return "Invalid Week"
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        
        let firstDayString = dateFormatter.string(from: firstDay)
        let lastDayString = dateFormatter.string(from: lastDay)
        
        return "\(firstDayString) - \(lastDayString)"
    }
    
    
    private func previousWeek() {
        if currentWeekIndex > 0 {
            currentWeekIndex -= 1
        }
    }
    
    private func nextWeek() {
        if currentWeekIndex < weeklyDurations.count - 1 {
            currentWeekIndex += 1
        }
    }
}
