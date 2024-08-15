//
//  ChartView.swift
//  History
//
//  Created by Nathik Azad on 8/5/24.
//

import Foundation
import SwiftUI
struct AggregateChartView: View {
    @ObservedObject var aggregate: AggregateModel
    @ObservedObject var actionTypeModel: ActionTypeModel
    let actionsParam: [ActionModel]
    let weekBoundary: WeekBoundary?
    let showWeekNavigator: Bool
    
    init(aggregate: AggregateModel, actionsParam: [ActionModel], weekBoundary: WeekBoundary? = nil, endDate: Date? = nil, showWeekNavigator:Bool = true, actionTypeModel: ActionTypeModel) {
        self.aggregate = aggregate
        self.actionsParam = actionsParam
        self.weekBoundary = weekBoundary
        self.showWeekNavigator = showWeekNavigator
        self.actionTypeModel = actionTypeModel
    }
 
    var actions: [ActionModel] {
        actionsParam.filter { $0.actionTypeId == aggregate.actionTypeId }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if aggregate.metadata.aggregatorType == .compare {
                let mark: Date? = aggregate.metadata.goals.first?.value?.toType(Date.self)
                let times = minTimeForEachDay(actions: actions, timezone: Authentication.shared.user!.timezone!, timeSelect: aggregate.metadata.field)
                    ScatterView(title: "", data: times,
                                mark: mark,
                                range: 2)
                    .id(aggregate.id)
            } else  {
                let dateCounts = getCumulativePerWeek(actions: actions, timezone: Authentication.shared.user!.timezone!, adder: adder)
                WeeklyBarView(weeklyDurations: dateCounts, aggregate: aggregate, showWeekNavigator: showWeekNavigator, mark: mark, units: units)
            }
        }
    }
    
    var mark: Double? {
        if aggregate.metadata.field == "Duration" {
            let duration = aggregate.metadata.goals.first?.value?.toType(Duration.self)
            return Double(duration?.durationInSeconds ?? 0)
        } else {
            let schema = aggregate.actionType?.dynamicFields[aggregate.metadata.field]
            if schema?.dataType == .currency {
                return Double(aggregate.metadata.goal.value?.toType(Currency.self)?.value ?? 0)
            }
        }
        return aggregate.metadata.goals.first?.value?.toType(Double.self) ?? 0.0
    }
    
    var units: String {
        if aggregate.metadata.aggregatorType == .count {
            return "Count"
        } else if aggregate.metadata.field == "Duration" {
            return "Seconds"
        } else {
            let schema = aggregate.actionType?.dynamicFields[aggregate.metadata.field]
            if schema?.dataType == .currency {
                let curr = aggregate.metadata.goal.value?.toType(Currency.self)
                return curr?.currencyType.rawValue ?? "USD"
            }
        }
        return ""
    }
    
    func adder(action: ActionModel) -> Int {
        if aggregate.metadata.aggregatorType == .count {
            return 1
        } else if aggregate.metadata.field == "Duration" {
            return Int(action.durationInSeconds)
        } else {
            let schema = aggregate.actionType?.dynamicFields[aggregate.metadata.field]
            if schema?.dataType == .currency {
                return Int(action.dynamicData[aggregate.metadata.field]?.toType(Currency.self)?.value ?? 0)
            } else {
                return Int(action.dynamicData[aggregate.metadata.field]?.toType(Double.self) ?? 0)
            }
        }
    }
    
    func getDateRange(from dates: [Date], timezone: String) -> (Calendar, Date, Date)? {
        var calendar = Calendar.current
        let timeZone = TimeZone(identifier: timezone) ?? Calendar.current.timeZone
        calendar.timeZone = timeZone
        
        if let startDate = weekBoundary?.start, let endDate = weekBoundary?.end {
            return (calendar, calendar.startOfDay(for: startDate), calendar.startOfDay(for: endDate))
        } else {
            guard let minDate = dates.min(),
                  let maxDate = dates.max() else {
                return nil
            }
            return (calendar, calendar.startOfDay(for: minDate), calendar.startOfDay(for: maxDate))
        }
    }
}


