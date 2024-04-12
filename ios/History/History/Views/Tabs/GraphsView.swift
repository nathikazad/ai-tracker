//
//  GraphsView.swift
//  History
//
//  Created by Nathik Azad on 4/8/24.
//

import SwiftUI
import Charts


//struct GraphsView: View {
//    var body: some View {
//        VStack {
//            Spacer()
//            Text("Waiting to get more data")
//                .foregroundColor(.secondary)
//                .font(.title2)
//            Spacer()
//        }
//    }
//}

struct GraphsView: View {
    
    let graphs: [GraphConfig] = [
        GraphConfig(type: .line, data: [
            ("M", 7.5),
            ("T", 8.5),
            ("W", 7.75),
            ("Th", 8.15),
            ("F", 9.15),
            ("S", 7.7)
        ], title: "Wake Up Time", ruleMarkValue: 8.5, ruleMarkLabel: "8:30 am"),
        
        GraphConfig(type: .bar, data: [
            ("M", 5),
            ("T", 4),
            ("W", 3),
            ("Th", 5),
            ("F", 1),
            ("S", 3)
        ], title: "Number of Prayers", ruleMarkValue: 5, ruleMarkLabel: "5")
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                ForEach(graphs.indices, id: \.self) { index in
                    VStack(alignment: .leading) {
                        Text(graphs[index].title)
                        //                                  .font(.title2)
                            .padding(.top, index == 0 ? 20 : 40) // Add space at the top for the first item, more for others
                            .padding(.bottom, 15)
                        
                        graphs[index].chartView()
                            .frame(height: 100) // Adjust height as necessary
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}
// Preview for ContentView






// Define the types of graphs
enum GraphType {
    case line, bar
}

// Graph configuration model
struct GraphConfig {
    var type: GraphType
    var data: [(day: String, time: Double)]
    var title: String
    var ruleMarkValue: Double?
    var ruleMarkLabel: String?
}

// Extend the model to include a method to generate the chart
extension GraphConfig {
    @ViewBuilder
    func chartView() -> some View {
        switch type {
        case .line:
            Chart {
                ForEach(data, id: \.day) { entry in
                    LineMark(
                        x: .value("Day", entry.day),
                        y: .value("Time", entry.time)
                    )
                }
                if let ruleValue = ruleMarkValue, let label = ruleMarkLabel {
                    RuleMark(
                        y: .value("Guide", ruleValue)
                    )
                    .foregroundStyle(.secondary)
                    .annotation(position: .top, alignment: .leading) {
                        Text(label)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .chartYScale(domain: data.map { $0.time }.min()!...data.map { $0.time }.max()!)
            
        case .bar:
            Chart {
                ForEach(data, id: \.day) { entry in
                    BarMark(
                        x: .value("Day", entry.day),
                        y: .value("Time", entry.time)
                    )
                }
                if let ruleValue = ruleMarkValue, let label = ruleMarkLabel {
                    RuleMark(
                        y: .value("Guide", ruleValue)
                    )
                    .foregroundStyle(.secondary)
                    .annotation(position: .top, alignment: .leading) {
                        Text(label)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .chartYScale(domain: 0...data.map { $0.time }.max()!)
        }
    }
}


#Preview {
    GraphsView()
}
