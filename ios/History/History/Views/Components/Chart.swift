//
//  ScatterChart.swift
//  History
//
//  Created by Nathik Azad on 4/27/24.
//

import SwiftUI
import Charts

func configureAxisLabel(for value: Any, dataCount: Int) -> some AxisMark {
    if dataCount <= 7 {
        return AxisValueLabel(format: .dateTime.weekday(.abbreviated)).offset(x: -10)
    } else if dataCount < 10 {
        return AxisValueLabel(format: .dateTime.day()).offset(x: -10)
    } else {
        if let date = value as? Date {
            let day = Calendar.current.component(.day, from: date)
            if day % 2 == 0 {
                return AxisValueLabel(format: .dateTime.day()).offset(x: -10)
            }
        }
    }
    // Fallback view in case none of the conditions are met
    return AxisValueLabel(format: .dateTime.day()).offset(x: -10) // A default configuration; adjust as needed
}

struct BarView: View {
    var title: String
    var data: [(Date, Double)]
    
    var body: some View {
        Section(header: Text(title)) {
            Chart(data, id:\.0) {
                    BarMark(
                        x: .value("Key", $0.0),
                        y: .value("Value", $0.1)
                    )
                    .foregroundStyle(Color.gray)
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    configureAxisLabel(for: value, dataCount: data.count)
                }
            }
            .chartYAxis {
                AxisMarks(values: .automatic(desiredCount: 6))
            }
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
    var countOfUniqueDays: Int {
        var dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return Set(self.map { dateFormatter.string(from: $0.start) }).count
    }
}

struct CandleView: View {
    var title: String
    var candles: [Candle]
    var offsetHours: Int = 0
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
                AxisMarks(values: .stride(by: .day)) { value in
                    configureAxisLabel(for: value, dataCount: candles.countOfUniqueDays)
                }
            }
            .chartYAxis {
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
            .frame(height: 200)
            .padding()
        }
    }
}



struct ScatterView: View {
    var title: String
    var data: [Date]
    var showLine: Bool = false
    var body: some View {
        
        return Section(header: Text(title)) {
            Chart(data, id:\.self) {
                    PointMark(
                        x: .value("x data", Calendar.current.startOfDay(for:$0)),
                        y: .value("y data",  $0.dateWithHourAndMinute)
                    ).foregroundStyle(Color.gray)

            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    configureAxisLabel(for: value, dataCount: data.count)
                }
            }
            .frame(height: 200)
            .padding()
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


//struct ScatterViewString: View {
//    var title: String
//    var data: [(String, Double)]
//    var body: some View {
//        Section(header: Text(title)) {
//            Chart {
//                ForEach(data, id: \.0) { x, y in
//                    PointMark(
//                        x: .value("x data", x),
//                        y: .value("y data", y)
//                            
//                    ).foregroundStyle(Color.gray)
//                }
//            }
//            .chartYScale(domain: getDomain(data: data.map{ $0.1 }))
//            .frame(height: 200)
//            .padding(.horizontal)
//        }
//    }
//}

func getDomain(data:[Double]) -> ClosedRange<Double>{
    return { ((data.min() ?? 0) - 2)...((data.max() ?? 24) + 2) }()
}
