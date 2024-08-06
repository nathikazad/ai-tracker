//
//  ScatterChart.swift
//  History
//
//  Created by Nathik Azad on 4/27/24.
//

import SwiftUI
import Charts

func configureXAxis(count: Int) -> AxisMarks<BuilderConditional<BuilderConditional<some AxisMark, some AxisMark>, (some AxisMark)??>> {
    return AxisMarks(values: .stride(by: .day)) { value in
        if count <= 8 {
            AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                .offset(x: -10)
        } else if count < 12 {
            AxisValueLabel(format: .dateTime.day())
                .offset(x: -10)
        } else {
            let divider = count/12 + 2
            if let date = value.as(Date.self) {
                let day = Calendar.current.component(.day, from: date)
                if day % divider == 0 {
                    AxisValueLabel(format: .dateTime.day())
                        .offset(x: -10)
                }
            }
        }
    }
}

struct BarView: View {
    var title: String?
    var data: [(Date, Double)]
    var yAxisLabel: String?
    var yMark: Double?
    
    var numDays: Int {
        // get minimum date, maximum date, and then get the difference in days
        let minDate = data.min { $0.0 < $1.0 }?.0 ?? Date()
        let maxDate = data.max { $0.0 < $1.0 }?.0 ?? Date()
        return Calendar.current.dateComponents([.day], from: minDate, to: maxDate).day ?? 0
    }
    
    var body: some View {
        Section {
            Chart {
                ForEach(data, id: \.0) { item in
                    BarMark(
                        x: .value("Key", item.0),
                        y: .value("Value", item.1)
                    )
                    .foregroundStyle(Color.gray)
                }
                
                if let yMark = yMark {
                    RuleMark(
                        y: .value("Target", yMark)
                    )
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                    .foregroundStyle(Color.green)
                }
            }
            .chartXAxis {
                configureXAxis(count: numDays)
            }
            .chartYAxis {
                AxisMarks(values: .automatic(desiredCount: 6)) { value in
                    if let doubleValue = value.as(Double.self),
                       doubleValue.truncatingRemainder(dividingBy: 1) == 0 {
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel {
                            Text("\(Int(doubleValue))")
                        }
                    }
                }
            }
            .chartYAxisLabel(content: {
                if let yAxisLabel = yAxisLabel {
                    Text(yAxisLabel)
                }
            })
            .frame(height: 200)
            .padding()
            
        }
    }
}
struct Candle: Hashable {
    let date: String
    let start: Date
    let end: Date
}


extension [Candle] {
    var numDays: Int {
        let minDate = self.min { $0.start < $1.start }?.start ?? Date()
        let maxDate = self.max { $0.start < $1.start }?.start ?? Date()
        return Calendar.current.dateComponents([.day], from: minDate, to: maxDate).day ?? 0
    }
}

struct CandleView: View {
    var title: String
    var candles: [Candle]
    var offsetHours: Int = 0
    var automaticYAxis: Bool = false
    // let gradient = LinearGradient(
    //         gradient: Gradient(colors: [Color.blue, Color.purple]),
    //         startPoint: .top,
    //         endPoint: .bottom
    //     )
    
    
    var body: some View {
        return Section(header: Text(title)) {
            Chart(candles, id:\.date) {
                RectangleMark(
                    x: .value("date", Calendar.current.startOfDay(for:$0.start.addHours(offsetHours))),
                    yStart: .value("start", $0.start.addHours(offsetHours).dateWithHourAndMinute),
                    yEnd: .value("end", $0.end.addHours(offsetHours).dateWithHourAndMinute),
                    width: 4
                )
            }
            .chartXAxis {
                configureXAxis(count: candles.numDays)
            }
            .chartYAxis {
                if(automaticYAxis) {
                    AxisMarks(values: .automatic)
                } else {
                    AxisMarks(values: .stride(by: .hour, count: 1)) { value in
                        if let date = value.as(Date.self) {
                            let hour = Calendar.current.component(.hour, from: date)
                            if hour % 2 == 0 {
                                AxisValueLabel(date.addHours(-offsetHours).hourInAmPm)
                            }
                        }
                        AxisGridLine()
                        AxisTick()
                    }
                }
            }
            .frame(height: 200)
            .padding()
        }
    }
}

extension Date {
    var toComponents: DateComponents {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.hour, .minute, .second], from: self)
        return components
    }
    
    func adjustHoursWithinDay(by hours: Int) -> Date {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: self)
        let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: self)!
        let adjustedDate = calendar.date(byAdding: .hour, value: hours, to: self)!
        if adjustedDate < startOfDay {
            return startOfDay
        } else if adjustedDate > endOfDay {
            return endOfDay
        } else {
            return adjustedDate
        }
    }
}



struct ScatterView: View {
    var title: String
    var data: [Date]
    var showLine: Bool = false
    var mark: Date?
    var range: Int?
    
    var numDays: Int {
        let minDate = data.min() ?? Date()
        let maxDate = data.max() ?? Date()
        return Calendar.current.dateComponents([.day], from: minDate, to: maxDate).day ?? 0
    }
    private func hourComponent(_ date: Date) -> Int {
        Calendar.current.component(.hour, from: date)
    }
    
    var filteredData: [Date] {
        guard let mark = mark, let range = range else { return data }
        
        let markHour = hourComponent(mark)
        let lowerBound = (markHour - range + 24) % 24
        let upperBound = (markHour + range) % 24
        
        return data.filter { date in
            let dateHour = hourComponent(date)
            if lowerBound <= upperBound {
                return dateHour >= lowerBound && dateHour <= upperBound
            } else {
                return dateHour >= lowerBound || dateHour <= upperBound
            }
        }
    }
    
    var body: some View {
        Section(header: Text(title)) {
            Chart(filteredData, id: \.self) { date in
                PointMark(
                    x: .value("Date", Calendar.current.startOfDay(for: date)),
                    y: .value("Time", timeToDouble(date))
                )
                .foregroundStyle(Color.gray)
                if let mark = mark {
                    RuleMark(
                        y: .value("Mark", timeToDouble(mark))
                    )
                    .foregroundStyle(.red)
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                }
            }
            .chartXAxis {
                configureXAxis(count: numDays)
            }
            //            .if(mark != nil && range != nil) { view in
            //                   view.chartYScale(domain: yAxisDomain())
            //               }
            .chartYScale(
                domain: .automatic(includesZero: false, reversed: true)
            )
            .chartYAxis {
                AxisMarks(values: .stride(by: 3600)) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel {
                        if let doubleValue = value.as(Double.self) {
                            Text(formatTimeLabel(doubleValue))
                        }
                    }
                }
            }
            .frame(height: 200)
            .padding()
        }
    }
    private func timeToDouble(_ date: Date) -> Double {
        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: date)
        return Double(components.hour ?? 0) * 3600 +
        Double(components.minute ?? 0) * 60 +
        Double(components.second ?? 0)
    }
    
    private func yAxisDomain() -> ClosedRange<Double> {
        let minY = mark!.adjustHoursWithinDay(by: -range!).toComponents
        let maxY = mark!.adjustHoursWithinDay(by: range!).toComponents
        let minSeconds = timeToDouble(createDate(from: minY))
        let maxSeconds = timeToDouble(createDate(from: maxY))
        return minSeconds...maxSeconds
    }
    
    private func createDate(from components: DateComponents) -> Date {
        Calendar.current.date(from: components) ?? Date()
    }
    
    private func formatTimeLabel(_ seconds: Double) -> String {
        let hour = Int(seconds) / 3600
        let isPM = hour >= 12
        let hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour)
        return "\(hour12)\(isPM ? "PM" : "AM")"
    }
}

extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

func linearRegression(data: [(Double, Double)]) -> [Double]? {
    guard data.count > 1 else {
        print("not enough")
        return nil // Not enough data to calculate regression
    }
    
    let n = Double(data.count)
    let sumX = data.map { $0.0 }.reduce(0, +)
    let sumY = data.map { $0.1 }.reduce(0, +)
    let sumXY = data.map { $0.0 * $0.1 }.reduce(0, +)
    let sumX2 = data.map { $0.0 * $0.0 }.reduce(0, +)
    
    let denominator = (n * sumX2 - (sumX * sumX))
    guard denominator != 0 else {
        print("zero")
        return nil // Avoid division by zero
    }
    
    let m = (n * sumXY - sumX * sumY) / denominator
    let b = (sumY - m * sumX) / n
    print(data.map { m * $0.0 + b })
    return data.map { m * $0.0 + b }
}


func getDomain(data:[Double]) -> ClosedRange<Double>{
    return { ((data.min() ?? 0) - 2)...((data.max() ?? 24) + 2) }()
}
