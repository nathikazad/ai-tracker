//
//  WeeklyBarView.swift
//  History
//
//  Created by Nathik Azad on 8/12/24.
//

import SwiftUI
struct WeeklyBarView: View {
    let weeklyDurations: [[(Date, Int, Int)]]
    let mark: Int
    let aggregate: AggregateModel
    let showWeekNavigator: Bool
    @State var showCumView: Bool = true
    @State private var currentWeekIndex = 0

    init(weeklyDurations: [[(Date, Int, Int)]], mark: Int?, aggregate: AggregateModel, showWeekNavigator: Bool) {
        self.weeklyDurations = weeklyDurations
        self.showWeekNavigator = showWeekNavigator
        // Check if mark is within bounds
        if let providedMark = mark,
           !weeklyDurations.isEmpty,
           let maxDuration = weeklyDurations.flatMap({ $0 }).map({ $0.1 }).max(),
           providedMark <= maxDuration {
            self.mark = providedMark
        } else {
            self.mark = 0
        }
        self.aggregate = aggregate
    }

    var body: some View {
        if !weeklyDurations.isEmpty {
            VStack {
                if showWeekNavigator {
                    WeekNavigator(currentWeekIndex: $currentWeekIndex, weeklyDurations: weeklyDurations)
                }

                let (array, label) = convertCumDurationsToRightUnit(dateCounts: weeklyDurations[currentWeekIndex], aggregate: aggregate, cumulative: showCumView)
                
                ZStack(alignment: .topLeading) {
                    if showCumView {
                        BarView(data: array, yAxisLabel: "Cumulative \(label)", yMark: mark == 0 ? nil : Double(mark),
                                x1Mark: weeklyDurations[currentWeekIndex].first!.0,
                                x2Mark: weeklyDurations[currentWeekIndex].last!.0)
                        .id("week_\(currentWeekIndex)")
                        .transition(.opacity)
                        .animation(.default, value: currentWeekIndex)
                    } else {
                        BarView(data: array, yAxisLabel: "Daily \(label)", yMark: mark == 0 ? nil : Double(mark)/7)
                        .id("week_\(currentWeekIndex)")
                        .transition(.opacity)
                        .animation(.default, value: currentWeekIndex)
                    }
                    
                    Button(action: {
                        showCumView.toggle()
                    }) {
                        Image(systemName: "arrow.left.arrow.right.square")
                            .foregroundColor(.gray)
                            .padding(8)
                            .background(Color.white.opacity(0.8))
                            .clipShape(Circle())
                    }
                    .padding(8)
                }
            }
        } else {
            Text("No data available")
        }
    }
    
    struct WeekNavigator: View {
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
    
    
}
