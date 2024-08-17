//
//  CandlesTest.swift
//  History
//
//  Created by Nathik Azad on 8/6/24.
//

import SwiftUI
import Combine

enum SelectedGrouping: String, CodingKey {
    case byPercentage
    case byPeriod
}

struct CandleChartWithList: View {
    @State private var actions: [ActionModel] = []
    @State private var unselectedModels: [Int] = []
    var offsetHours: Int = 0
    
    @State var hoursRange: ClosedRange<Int> = 0...24
    @State var daysRange: ClosedRange<Int> = 0...7
    @State var showColorPickerForActionTypeId: Int? = nil
    @State var redrawChart: Bool = true
    @State private var coreStateSubcription: AnyCancellable?
    @State private var selectedGrouping: SelectedGrouping = .byPercentage
    @State private var selectedWeekday: Weekday = .saturday
    @State private var allSelected: Bool = true
    
    var numOfDays: Int {
        daysRange.upperBound - daysRange.lowerBound
    }
    
    var candles: [Candle] {
        let filteredCandles = convertActionsToCandles(actions, daysRange: daysRange)
        return filteredCandles
    }
    
    var truncatedCandles: [Candle] {
        truncateCandles(candles, startHour: hoursRange.lowerBound, endHour: hoursRange.upperBound)
    }
    
    var filterCandlesByActionType: [Candle] {
        let candles = truncatedCandles.filter({
            candle in
            return !unselectedModels.contains(candle.actionTypeModel!.id!)
        })
        return candles.sorted(by: { a, b in a.end.timeIntervalSince(a.start) > b.end.timeIntervalSince(b.start)})
    }
    
    var actionTypeModels: [ActionTypeModel] {
        return getUniqueActionTypeIds(candles: truncatedCandles).sorted(by: { a, b in a.name < b.name})
    }
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    var body: some View {
        GeometryReader { geometry in
            Group {
                if verticalSizeClass == .compact {
                    // Landscape orientation
                    HStack(spacing: 0) {
                        CandleView(title: "", candles: filterCandlesByActionType, hoursRange: hoursRange, offsetHours: offsetHours, automaticYAxis: true, val: numOfDays, redrawChart: redrawChart)
                            .frame(width: geometry.size.width * 0.5)
                        
                        list
                            .frame(width: geometry.size.width * 0.5)
                    }
                } else {
                    // Portrait orientation
                    VStack(spacing: 0) {
                        
                        CandleView(title: "", candles: filterCandlesByActionType, hoursRange: hoursRange, offsetHours: offsetHours, automaticYAxis: true, val: numOfDays, redrawChart: redrawChart)
                            .frame(height: geometry.size.height * 0.5)
                        
                        list
                            .frame(height: geometry.size.height * 0.5)
                    }
                }
            }
        }
        .onAppear {
            if(auth.areJwtSet) {
                fetchActions()
                coreStateSubcription?.cancel()
                coreStateSubcription = state.subscribeToCoreStateChanges {
                    print("Core state occurred")
                    fetchActions()
                }
                
            }
            selectedWeekday = Date().getWeekday
        }
        .onDisappear {
            coreStateSubcription?.cancel()
        }
    }
    
    func fetchActions() {
        Task {
            let fetchedActions = await ActionController.fetchActions(userId: auth.userId!, startDate: state.currentWeek.start, endDate: state.currentWeek.end)
            await MainActor.run {
                self.actions = fetchedActions
                redrawChart.toggle()
            }
        }
    }
    
    var list: some View {
        List {
            DayRangeSelector(daysRange: $daysRange, fetchActions: fetchActions)
            HourRangeSelector(hoursRange: $hoursRange)
            ControlBar(selectedGrouping: $selectedGrouping, unselectedModels: $unselectedModels, actionTypeModels: actionTypeModels)
            WeekdaySelectorForCandles(selectedDay: $selectedWeekday, daysRange: $daysRange, selectedGrouping: $selectedGrouping, allSelected: $allSelected)
                .alignmentGuide(.listRowSeparatorLeading) { _ in -20 }    
            if selectedGrouping == .byPercentage {
                ActionTypeList(
                    actionTypeModels: actionTypeModels, 
                    truncatedCandles: truncatedCandles,
                    daysRange: daysRange,
                    unselectedModels: $unselectedModels,
                    showColorPickerForActionTypeId: $showColorPickerForActionTypeId,
                    fetchActions: fetchActions,
                    allSelected: $allSelected, 
                    selectedWeekday: $selectedWeekday)
            } else {
                let weekBoundary = state.currentWeek.getStartAndEnd(weekday: selectedWeekday)
                let selectedActions = actions.filterEvents(weekBoundary: weekBoundary).sortEvents
                ForEach(selectedActions, id: \.id) { action in
                    ActionRowForCandleView(
                        actionModel: action,
                        showColorPickerForActionTypeId: $showColorPickerForActionTypeId,
                        unselectedModels: $unselectedModels,
                        truncatedCandles: truncatedCandles,
                        fetchActions: fetchActions)
                        .alignmentGuide(.listRowSeparatorLeading) { _ in
                            -20
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            NavigationLink(destination: ShowActionView(actionModel: action))
                            {
                                Image(systemName: "gear")
                            }
                            .tint(.gray)
                        }
                }
            }
        }
    }
}

struct DayRangeSelector: View {
    @Binding var daysRange: ClosedRange<Int>
    var fetchActions: () -> Void
    
    var body: some View {
        HStack {
            Text("\(numberToWeekday(Int(daysRange.lowerBound) + 1)?.name ?? "Sun")")
            Spacer()
            RangedSliderView(value: $daysRange, bounds: 0...7)
                .onChange(of: daysRange) { fetchActions() }
                .frame(width: 150)
                .padding(.horizontal, 10)
            Spacer()
            Text("\(numberToWeekday(Int(daysRange.upperBound))?.name ?? "Sun")")
        }
    }
}

struct HourRangeSelector: View {
    @Binding var hoursRange: ClosedRange<Int>
    
    var body: some View {
        HStack {
            let lower = hoursRange.lowerBound%12 == 0 ? 12 : hoursRange.lowerBound%12
            Text("\(Int(lower)) \(hoursRange.lowerBound/12 >= 1 ? "pm" : "am")")
            Spacer()
            RangedSliderView(value: $hoursRange, bounds: 0...24)
                .frame(width: 150)
                .padding(.horizontal, 10)
                Spacer()
            let upper = hoursRange.upperBound%12 == 0 ? 12 : hoursRange.upperBound%12
            Text("\(Int(upper)) \(hoursRange.upperBound/12 == 1 ? "pm" : "am")")
        }
    }
}

struct ControlBar: View {
    @Binding var selectedGrouping: SelectedGrouping
    @Binding var unselectedModels: [Int]
    var actionTypeModels: [ActionTypeModel]
    
    var body: some View {
        HStack {
            Button(action: {
                selectedGrouping = selectedGrouping == .byPercentage ? .byPeriod : .byPercentage
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "clock.arrow.2.circlepath")
                    Text(selectedGrouping == .byPercentage ? "Percentages" : "Periods")
                }
            }
            .buttonStyle(ControlBarButtonStyle())
            Spacer()
            if !unselectedModels.isEmpty {
                Button("All") { unselectedModels = [] }
                    .buttonStyle(ControlBarButtonStyle())
            } else {
                Button("Clear") { unselectedModels = actionTypeModels.compactMap { $0.id } }
                    .buttonStyle(ControlBarButtonStyle())
            }
        }
        .alignmentGuide(.listRowSeparatorLeading) { _ in -20 }
    }
}

struct ActionTypeList: View {
    var actionTypeModels: [ActionTypeModel]
    var truncatedCandles: [Candle]
    var daysRange: ClosedRange<Int>
    @Binding var unselectedModels: [Int]
    @Binding var showColorPickerForActionTypeId: Int?
    var fetchActions: () -> Void
    @Binding var allSelected: Bool
    @Binding var selectedWeekday: Weekday
    
    var body: some View {
        let numOfDays = allSelected ? (daysRange.upperBound - daysRange.lowerBound) : 1
        let totalTimeOfAll = numOfDays * 24 * 60 * 60
        let durationByActionType = calculateDurationByActionType(truncatedCandles)
        let sortedActionTypes = sortActionTypes(actionTypeModels, durationByActionType)
        
        ForEach(sortedActionTypes, id: \.name) { actionTypeModel in
            ActionTypeRowView(actionTypeModel: actionTypeModel, showColorPickerForActionTypeId: $showColorPickerForActionTypeId, unselectedModels: $unselectedModels, truncatedCandles: truncatedCandles, totalTimeOfAll: totalTimeOfAll, fetchActions: fetchActions, allSelected: $allSelected,
                              selectedWeekday: $selectedWeekday)
                .alignmentGuide(.listRowSeparatorLeading) { _ in -20 }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    NavigationLink(destination: ActionTypeView(model: actionTypeModel)) {
                        Image(systemName: "gear")
                    }
                    .tint(.gray)
                }
        }
    }
    
    private func calculateDurationByActionType(_ candles: [Candle]) -> [Int: Int] {
        candles.reduce(into: [:]) { result, candle in
            if let actionTypeId = candle.actionTypeModel?.id {
                let duration = Int(candle.end.timeIntervalSince(candle.start))
                result[actionTypeId, default: 0] += duration
            }
        }
    }
    
    private func sortActionTypes(_ actionTypes: [ActionTypeModel], _ durations: [Int: Int]) -> [ActionTypeModel] {
        actionTypes.sorted { (a1, a2) in
            let duration1 = durations[a1.id!] ?? 0
            let duration2 = durations[a2.id!] ?? 0
            return duration1 > duration2
        }
    }
}

struct ControlBarButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .fontWeight(.medium)
            .background(Color.gray.opacity(0.2))
            .foregroundColor(.primary)
            .cornerRadius(6)
    }
}

extension Date {
    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }
}

//let endDate = endDate == startDate
//? min(
//    calendar.date(byAdding: .minute, value: 15, to: startDate)!,
//    calendar.date(bySettingHour: 23, minute: 59, second: 59, of: startDate)!
//)
//: endDate

func getUniqueActionTypeIds(candles: [Candle]) -> [ActionTypeModel] {
    var uniqueDict: [Int: ActionTypeModel] = [:]
    
    for candle in candles {
        if let id = candle.actionTypeModel?.id {
            if uniqueDict[id] == nil {
                uniqueDict[id] = candle.actionTypeModel
            }
        }
    }
    
    return uniqueDict.map { (actionTypeId, value) in
        return value
    }
}
