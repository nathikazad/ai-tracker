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
    var x1Mark: Date?
    var x2Mark: Date?
    
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
                    if let x1Mark = x1Mark, let x2Mark = x2Mark {
                        let startDate = Calendar.current.date(byAdding: .day, value: -5, to: Date())!
                        LineMark(
                            x: .value("X", x1Mark),
                            y: .value("Y", yMark/7)
                        )
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                        .foregroundStyle(Color.green)
                        LineMark(
                            x: .value("X", x2Mark),
                            y: .value("Y", yMark)
                        )
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                        .foregroundStyle(Color.green)
                    } else {
                        RuleMark(
                            y: .value("Target", yMark)
                        )
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                        .foregroundStyle(Color.green)
                    }
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

struct Candle: Hashable, Identifiable {
    let id = UUID()
    let date: String
    let start: Date
    let end: Date
    let actionTypeModel: ActionTypeModel?
    
    init(date: String, start: Date, end: Date, actionTypeModel: ActionTypeModel? = nil) {
        self.date = date
        self.start = start
        self.end = end
        self.actionTypeModel = actionTypeModel
    }
    
    var day: Date {
        Calendar.current.startOfDay(for: start)
    }
    
    static func == (lhs: Candle, rhs: Candle) -> Bool {
        return lhs.date == rhs.date
        && lhs.start == rhs.start
        && lhs.end == rhs.end
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(date)
        hasher.combine(start)
        hasher.combine(end)
    }
}

let offSetArray = [150, 150, 70, 45, 30, 23, 20, 15, 13]
extension [Candle] {
    var numDays: Int {
        let minDate = self.min { $0.start < $1.start }?.start ?? Date()
        let maxDate = self.max { $0.start < $1.start }?.start ?? Date()
        let ret = Swift.max(1, Calendar.current.dateComponents([.day], from: minDate, to: maxDate).day ?? 1)
        return offSetArray[ret]
    }
}


struct CandleView: View {
    var title: String
    var candles: [Candle]
    let hoursRange: ClosedRange<Int>
    var offsetHours: Int = 0
    var automaticYAxis: Bool = false
    var val: Int
    var redrawChart: Bool
    
    private var minHour: Int { hoursRange.lowerBound }
    private var maxHour: Int { hoursRange.upperBound }
    private func shortDuration(_ start: Date) -> Date {
        let duration = ((maxHour - minHour) * 60)/100
        let endOfDay = Calendar.currentInLocal.date(bySettingHour: 23, minute: 59, second: 59, of: start)!
        let calculatedDate = Calendar.currentInLocal.date(byAdding: .minute, value: duration, to: start)!
        return min(calculatedDate, endOfDay)
    }
    
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    var body: some View {
        Chart(candles) { period in
            let end = period.start == period.end ? shortDuration(period.start) : period.end
            RectangleMark(
                x: .value("Day", period.start, unit: .day),
                yStart: .value("Start", normalizedHours(period.start)),
                yEnd: .value("End", normalizedHours(end)),
                width: .ratio(0.6)
            )
            .foregroundStyle(period.actionTypeModel?.staticFields.color ?? Color.gray)
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                    .offset(x: CGFloat(offSetArray[val]))
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading, values: .stride(by: 1)) { value in
                AxisGridLine()
                AxisTick()
                if let hourValue = value.as(Int.self), hourValue % strideBy == 0 {
                    AxisValueLabel {
                        Text(formatHourLabel(hourValue))
                    }
                }
            }
        }
        .chartYScale(domain: 0...Double(maxHour - minHour))
        .frame(height: verticalSizeClass == .compact ? 250 : 300)
        .padding()
    }
    
    private var strideBy: Int {
        let range = maxHour - minHour
        return max(range / 5, 1)  // Ensure we have at most 6 labels
    }
    
    func normalizedHours(_ date: Date) -> Double {
        let hour = Calendar.current.component(.hour, from: date)
        let minute = Calendar.current.component(.minute, from: date)
        let totalHours = Double(hour) + Double(minute) / 60.0
        return Double(maxHour) - totalHours
    }
    
    func formatHourLabel(_ value: Int) -> String {
        let hour = maxHour - value
        let h = hour % 12
        return String( h == 0 ? 12 : h )
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
