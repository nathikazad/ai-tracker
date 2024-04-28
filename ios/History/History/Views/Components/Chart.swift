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
    var xdata: [Double]
    var ydata: [Double]
    var body: some View {
        Section(header: Text(title)) {
            Chart {
                ForEach(Array(zip(xdata, ydata)), id: \.0) { x, y in
                    PointMark(
                        x: .value("x data", x),
                        y: .value("y data", y)
                            
                    ).foregroundStyle(Color.gray)
                }
            }
            .chartXScale(domain: getDomain(data: xdata))
            .chartYScale(domain: getDomain(data: ydata))
            .frame(height: 200)
            .padding(.horizontal)
        }
    }
}

struct ScatterViewString: View {
    var title: String
    var xdata: [String]
    var ydata: [Double]
    var body: some View {
        Section(header: Text(title)) {
            Chart {
                ForEach(Array(zip(xdata, ydata)), id: \.0) { x, y in
                    PointMark(
                        x: .value("x data", x),
                        y: .value("y data", y)
                            
                    ).foregroundStyle(Color.gray)
                }
            }
            .chartYScale(domain: getDomain(data: ydata))
            .frame(height: 200)
            .padding(.horizontal)
        }
    }
}

func getDomain(data:[Double]) -> ClosedRange<Double>{
    return { ((data.min() ?? 0) - 2)...((data.max() ?? 24) + 2) }()
}
