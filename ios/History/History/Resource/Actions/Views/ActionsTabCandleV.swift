//
//  CandlesTest.swift
//  History
//
//  Created by Nathik Azad on 8/6/24.
//

import SwiftUI
import Combine

struct CandleChartWithList: View {
    @State private var actions: [ActionModel] = []
    @State private var unselectedModels: [Int] = []
    var offsetHours: Int = 0
    
    @State var hoursRange: ClosedRange<Int> = 5...22
    @State var daysRange: ClosedRange<Int> = 5...6
    @State var showColorPickerForActionTypeId: Int? = nil
    @State var redrawChart: Bool = true
    var timeZone: String = "America/Los_Angeles"
    @State private var coreStateSubcription: AnyCancellable?
    
    
    var numOfDays: Int {
        daysRange.upperBound - daysRange.lowerBound
    }
    
    var candles: [Candle] {
        let filteredCandles = convertActionsToCandles(actions, timeZone: timeZone, daysRange: daysRange)
        return filteredCandles
    }
    
    var truncatedCandles: [Candle] {
        truncateCandles(candles, startHour: hoursRange.lowerBound, endHour: hoursRange.upperBound, timeZone: timeZone)
    }
    
    var filteredCandles: [Candle] {
        let candles = truncatedCandles.filter({
            candle in
            return !unselectedModels.contains(candle.actionTypeModel!.id!)
        })
        return candles
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
                        CandleView(title: "", candles: filteredCandles, hoursRange: hoursRange, offsetHours: offsetHours, automaticYAxis: true, val: numOfDays, redrawChart: redrawChart)
                            .frame(width: geometry.size.width * 0.5)
                        
                        list
                            .frame(width: geometry.size.width * 0.5)
                    }
                } else {
                    // Portrait orientation
                    VStack(spacing: 0) {
                        
                        CandleView(title: "", candles: filteredCandles, hoursRange: hoursRange, offsetHours: offsetHours, automaticYAxis: true, val: numOfDays, redrawChart: redrawChart)
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
    enum Weekday: Int, CaseIterable {
        case monday = 1, tuesday, wednesday, thursday, friday, saturday, sunday
        
        var name: String {
            switch self {
            case .sunday: return "Sun"
            case .monday: return "Mon"
            case .tuesday: return "Tue"
            case .wednesday: return "Wed"
            case .thursday: return "Thu"
            case .friday: return "Fri"
            case .saturday: return "Sat"
            }
        }
    }

    func numberToWeekday(_ number: Int) -> Weekday? {
        return Weekday(rawValue: number)
    }
    
    var list: some View {
        List {
            HStack {
                Text("\(numberToWeekday(daysRange.lowerBound + 1)?.name ?? "Sun")")
                RangedSliderView(value: $daysRange, bounds: 0...6)
                    .onChange(of: daysRange) {
                        fetchActions()
                    }
                    .padding(.horizontal, 10)
                Text("\(numberToWeekday(daysRange.upperBound)?.name ?? "Sun" )")
            }
            HStack {
                Text("Hours: \(hoursRange.lowerBound)")
                RangedSliderView(value: $hoursRange, bounds: 0...24)
                    .padding(.horizontal, 10)
                Text("\(hoursRange.upperBound)")
            }
            HStack {
                Spacer()
                //                        if (daysRange.count > 2) {
                //                            Button("Days") {
                //                            }
                //                            .padding(.horizontal, 10)
                //                            .padding(.vertical, 6)
                //                            .background(Color.gray.opacity(0.2))
                //                            .cornerRadius(6)
                //                            .buttonStyle(PlainButtonStyle())
                //                        }
                Button("All") {
                    unselectedModels = []
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(6)
                .buttonStyle(PlainButtonStyle())
                Button("Clear") {
                    unselectedModels = actionTypeModels.compactMap { $0.id }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(6)
                .buttonStyle(PlainButtonStyle())
            }
            .alignmentGuide(.listRowSeparatorLeading) { _ in
                -20
            }
            let totalTimeOfAll = truncatedCandles.reduce(0) { (result, candle) -> Int in
                return result + Int(candle.end.timeIntervalSince(candle.start))
            }
            ForEach(actionTypeModels, id: \.name) { actionTypeModel in
                HStack {
                    ZStack {
                        Circle()
                            .fill(actionTypeModel.staticFields.color)
                            .frame(width: 20, height: 20)
                            .onTapGesture {
                                withAnimation {
                                    showColorPickerForActionTypeId = actionTypeModel.id
                                }
                            }
                        
                        if actionTypeModel.id == showColorPickerForActionTypeId {
                            CompactColorPicker(selectedColor:
                                                Binding(
                                                    get: { actionTypeModel.staticFields.color },
                                                    set: {
                                                        newValue in
                                                        actionTypeModel.staticFields.color = newValue
                                                    }
                                                ),
                                               isPickerVisible: Binding(
                                                get: {
                                                    actionTypeModel.id == showColorPickerForActionTypeId },
                                                set: {
                                                    newValue in
                                                    Task {
                                                        await ActionTypesController.updateActionTypeModel(model:actionTypeModel)
                                                        fetchActions()
                                                    }
                                                    showColorPickerForActionTypeId = nil
                                                }
                                               ))
                            
                        }
                    }
                    if actionTypeModel.id != showColorPickerForActionTypeId {
                        let totalTime = truncatedCandles.reduce(0) { (result, candle) -> Int in
                            if (candle.actionTypeModel?.id == actionTypeModel.id) {
                                return result + Int(candle.end.timeIntervalSince(candle.start))
                            }
                            return result
                        }
                        let percentage =  (totalTime * 100)/totalTimeOfAll
                        Text("\(actionTypeModel.name) (\(totalTime.fromSecondsToHHMMString)) \(percentage)%")
                        Spacer()
                        RadioButton(
                            isSelected: !unselectedModels.contains(where: { $0 == actionTypeModel.id }),
                            action: {
                                if unselectedModels.contains(where: { $0 == actionTypeModel.id }) {
                                    unselectedModels.removeAll(where: { $0 == actionTypeModel.id })
                                } else {
                                    unselectedModels.append(actionTypeModel.id!)
                                }
                            }
                        )
                    }
                }
                .alignmentGuide(.listRowSeparatorLeading) { _ in
                    -20
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    NavigationLink(destination: ActionTypeView(model: actionTypeModel))
                    {
                        Image(systemName: "gear")
                    }
                    .tint(.gray)
                }
                
            }
        }
    }
}

extension Date {
    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }
}

func convertActionsToCandles(_ actions: [ActionModel], timeZone: String, daysRange: ClosedRange<Int>) -> [Candle] {
    
    let dateFormatter = DateFormatter()
    let calendar = Calendar.current
    dateFormatter.dateFormat = "yyyy-MM-dd"
    
    guard let timezone = TimeZone(identifier: timeZone) else {
        fatalError("Invalid timezone identifier")
    }
    dateFormatter.timeZone = timezone

    let startDateOfRange = calendar.date(
        byAdding: .day,
        value: daysRange.lowerBound + 1,
        to: state.currentWeek.start
    )!
    
    var candles: [Candle] = []
    
    for action in actions {
        let startDate = action.startTime
        let endDate = action.endTime ?? action.startTime
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timezone
        
        if let midnight = calendar.date(bySettingHour: 23, minute: 59, second: 59, of:  startDate) {
            if (startDate < midnight && endDate > midnight) {
                if startDate > startDateOfRange {
                    let firstCandle = Candle(
                        date: dateFormatter.string(from: startDate),
                        start: startDate,
                        end: midnight,
                        actionTypeModel: action.actionTypeModel
                    )
                    candles.append(firstCandle)
                }
                let secondDay = calendar.date(byAdding: .day, value: 1, to: startDate)!
                if secondDay > startDateOfRange {
                    let secondCandle = Candle(
                        date: dateFormatter.string(from: midnight.addMinute(2)),
                        start: midnight.addMinute(2),
                        end: endDate,
                        actionTypeModel: action.actionTypeModel
                    )
                    candles.append(secondCandle)
                }
            }
            else {
                if startDate > startDateOfRange {
                    let candle = Candle(
                        date: dateFormatter.string(from: startDate),
                        start: startDate,
                        end: endDate,
                        actionTypeModel: action.actionTypeModel
                    )
                    candles.append(candle)
                }
            }
        }
    }
    return candles
}

//let endDate = endDate == startDate
//? min(
//    calendar.date(byAdding: .minute, value: 15, to: startDate)!,
//    calendar.date(bySettingHour: 23, minute: 59, second: 59, of: startDate)!
//)
//: endDate

func truncateCandles(_ candles: [Candle], startHour: Int, endHour: Int, timeZone: String) -> [Candle] {
    guard let timezone = TimeZone(identifier: timeZone) else {
        fatalError("Invalid timezone identifier")
    }
    
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = timezone
    
    let adjustedEndHour = endHour == 24 ? 0 : endHour
    let dayOffset = endHour == 24 ? 1 : 0
    
    return candles.filter { candle in
        guard let startDate = calendar.date(bySettingHour: startHour, minute: 0, second: 0, of: candle.start),
              var endDate = calendar.date(bySettingHour: adjustedEndHour, minute: 0, second: 0, of: candle.end) else {
            return false
        }
        
        if dayOffset == 1 {
            endDate = calendar.date(byAdding: .day, value: 1, to: endDate) ?? endDate
        }
        
        return candle.end > startDate && candle.start < endDate
    }.map { candle in
        guard let startDate = calendar.date(bySettingHour: startHour, minute: 0, second: 0, of: candle.start),
              var endDate = calendar.date(bySettingHour: adjustedEndHour, minute: 0, second: 0, of: candle.end) else {
            return candle // This should never happen due to the filter, but we need to handle it
        }
        
        if dayOffset == 1 {
            endDate = calendar.date(byAdding: .day, value: 1, to: endDate) ?? endDate
        }
        
        let truncatedStart = max(candle.start, startDate)
        let truncatedEnd = min(candle.end, endDate)
        
        return Candle(
            date: candle.date,
            start: truncatedStart,
            end: truncatedEnd,
            actionTypeModel: candle.actionTypeModel
        )
    }
}

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
