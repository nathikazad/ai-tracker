//
//  ScatterChart.swift
//  History
//
//  Created by Nathik Azad on 4/27/24.
//

import SwiftUI
import Charts

struct BarView: View {
    var title: String
    var data: [(String, Double)]

    var body: some View {
        Section(header: Text(title)) {
            Chart {
                ForEach(data, id: \.0) { x, y in
                    BarMark(
                        x: .value("Key", x),
                        y: .value("Value", y)
                    )
                    .foregroundStyle(Color.gray)
                }
            }
            .frame(height: 200)
            .padding(.horizontal)
        }
    }
}

struct CandleView: View {
    struct Candle: Hashable {
        let open: Double
        let close: Double
        let low: Double
        let high: Double
    }
    let candles: [Candle] = [
        .init(open: 3, close: 6, low: 1, high: 8),
        .init(open: 4, close: 7, low: 2, high: 9),
        .init(open: 5, close: 8, low: 3, high: 10)
    ]
    
    var body: some View {
        Chart {
            ForEach(Array(zip(candles.indices, candles)), id: \.1) { index, candle in
                RectangleMark(
                    x: .value("index", index),
                    yStart: .value("low", candle.low),
                    yEnd: .value("high", candle.high),
                    width: 4
                )
//                
//                RectangleMark(
//                    x: .value("index", index),
//                    yStart: .value("open", candle.open),
//                    yEnd: .value("close", candle.close),
//                    width: 16
//                )
//                .foregroundStyle(.red)
            }
        }
    }
}


struct ScatterViewDoubles: View {
    var title: String
    var data: [(Double, Double)]
    var showLine: Bool = false
    var body: some View {
        
        return Section(header: Text(title)) {
            Chart {
                // Plotting the points
                ForEach(data, id: \.0) { (x, y) in
                    PointMark(
                        x: .value("x data", x),
                        y: .value("y data", y)
                    ).foregroundStyle(Color.gray)
                }
                if showLine, let regressionLine = linearRegression(data: data) {
                    ForEach(data.indices, id: \.self) { index in
                        LineMark(
                            x: .value("x data", data[index].0),
                            y: .value("y data", regressionLine[index])
                        ).foregroundStyle(Color.red)
                    }
                }
            }
            .chartXScale(domain: getDomain(data: data.map { $0.0 }))
            .chartYScale(domain: getDomain(data: data.map { $0.1 }))
            .frame(height: 200)
            .padding(.horizontal)
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


struct ScatterViewString: View {
    var title: String
    var data: [(String, Double)]
    var body: some View {
        Section(header: Text(title)) {
            Chart {
                ForEach(data, id: \.0) { x, y in
                    PointMark(
                        x: .value("x data", x),
                        y: .value("y data", y)
                            
                    ).foregroundStyle(Color.gray)
                }
            }
            .chartYScale(domain: getDomain(data: data.map{ $0.1 }))
            .frame(height: 200)
            .padding(.horizontal)
        }
    }
}

func getDomain(data:[Double]) -> ClosedRange<Double>{
    return { ((data.min() ?? 0) - 2)...((data.max() ?? 24) + 2) }()
}
