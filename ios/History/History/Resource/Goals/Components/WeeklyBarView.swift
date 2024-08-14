//
//  WeeklyBarView.swift
//  History
//
//  Created by Nathik Azad on 8/12/24.
//

import SwiftUI
struct WeeklyBarView: View {
    let weeklyDurations: [[(Date, Int, Int)]]
    let aggregate: AggregateModel
    let showWeekNavigator: Bool
    let mark: Double?
    let units: String
    @State var cumSwitchOn: Bool = true
    @State private var currentWeekIndex = 0

    var showCum: Bool {
        return aggregate.metadata.window == .weekly && cumSwitchOn
    }
    
    var body: some View {
        if !weeklyDurations.isEmpty {
            VStack {
                if showWeekNavigator {
                    WeekNavigatorForBarGraph(currentWeekIndex: $currentWeekIndex, weeklyDurations: weeklyDurations)
                }
                let xyVals = flatYValues(dateCounts: weeklyDurations[currentWeekIndex], cumulative: showCum)
                let (array, label) = getDataAndUnit(xyVals: xyVals)
                
                ZStack(alignment: .topLeading) {
                    if !showCum {
                        BarView(data: array, yAxisLabel: "Daily \(label)", yMark: mark == nil ? 0 : mark!/(aggregate.metadata.window == .weekly ? 7 : 1 ))
                            .id("week_\(aggregate.id ?? 0)")
                        .transition(.opacity)
                        .animation(.default, value: currentWeekIndex)
                    } else {
                        BarView(data: array, yAxisLabel: "Cumulative \(label)", yMark: mark,
                                x1Mark: weeklyDurations[currentWeekIndex].first!.0,
                                x2Mark: weeklyDurations[currentWeekIndex].last!.0)
                        .id("week_\(aggregate.id ?? 0)")
                        .transition(.opacity)
                        .animation(.default, value: currentWeekIndex)
                    }
                        
                    if aggregate.metadata.window == .weekly {
                        Button(action: {
                            cumSwitchOn.toggle()
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
                
            }
        } else {
            Text("No data available")
        }
    }
    
    func getDataAndUnit(xyVals: [(Date, Int)]) -> ([(Date, Double)], String) {
        let array = xyVals.map { ($0, Double($1)) }
        if aggregate.metadata.field == "Duration" {
            if let targetDuration: Duration = aggregate.metadata.goals.first?.value?.toType(Duration.self) {
                return convertDurationsToRightUnit(dateCounts: xyVals, targetDuration: targetDuration)
            } else {
                return (array, "Seconds")
            }
        } else {
            return (array, units)
        }
        
    }
}

func convertDurationsToRightUnit(dateCounts: [(Date, Int)], targetDuration: Duration) -> ([(Date, Double)], String) {
    let array = dateCounts.map { ($0, Double($1)) }
    if !array.isEmpty {
        if targetDuration.durationType == .hours {
            let hourArray = array.map { ($0.0, $0.1 / 3600) }
            return (hourArray, "Hours")
        } else if targetDuration.durationType == .minutes {
            let hourArray = array.map { ($0.0, $0.1 / 60) }
            return (hourArray, "Minutes")
        } else {
            let hourArray = array.map { ($0.0, $0.1) }
            return (hourArray, "Seconds")
        }
    }
    return (array, "Minutes")
}

func flatYValues(dateCounts: [(Date, Int, Int)], cumulative: Bool) -> [(Date, Int)] {
    let modifiedDateCounts = dateCounts.map { (date, cumValue, incValue) in
        (date, cumulative ? cumValue : incValue)
    }
    return modifiedDateCounts
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
