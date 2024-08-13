//
//  convertDurations.swift
//  History
//
//  Created by Nathik Azad on 8/12/24.
//

import Foundation
func convertDurationsToRightUnit(dateCounts: [(Date, Int)], aggregate: AggregateModel) -> ([(Date, Double)], String) {
    let array = dateCounts.map { ($0, Double($1)) }
    if !array.isEmpty {
        if let targetDuration: Duration = aggregate.metadata.goals.first?.value?.toType(Duration.self) {
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
    }
    return (array, "Minutes")
}

func convertCumDurationsToRightUnit(dateCounts: [(Date, Int, Int)], aggregate: AggregateModel, cumulative: Bool) -> ([(Date, Double)], String) {
    let modifiedDateCounts = dateCounts.map { (date, cumValue, incValue) in
        (date, cumulative ? cumValue : incValue)
    }
    return convertDurationsToRightUnit(dateCounts: modifiedDateCounts, aggregate: aggregate)
}

func convertCumCountToRightUnit(dateCounts: [(Date, Int, Int)], aggregate: AggregateModel, cumulative: Bool) -> ([(Date, Double)], String) {
    let modifiedDateCounts = dateCounts.map { (date, cumValue, incValue) in
        (date, cumulative ? cumValue : incValue)
    }
    return (modifiedDateCounts.map { ($0, Double($1)) }, "Count")
}
