//
//  CandlesTest.swift
//  History
//
//  Created by Nathik Azad on 8/6/24.
//

import SwiftUI


struct CandleChartWithList: View {
    @State private var actions: [ActionModel] = []
    @State private var unselectedModels: [Int] = []
    //    let candles: [Candle] = []
    var offsetHours: Int = 0
    @State private var fetchTask: Task<Void, Never>?
    
    @State var hoursRange: ClosedRange<Int> = 6...18
    @State var daysRange: ClosedRange<Int> = 6...7
    @State var showColorPickerForActionTypeId: Int? = nil
    @State var redrawChart: Bool = true
    var timeZone: String = "America/Los_Angeles"
    
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
            fetchActions()
        }
    }
    
    func fetchActions() {
        let calendar = Calendar.current
        let timezone = TimeZone(identifier: timeZone) ?? TimeZone.current
        
        print( daysRange.lowerBound - 7, daysRange.upperBound - 7)
        let startDate = calendar.date(
            byAdding: .day,
            value: daysRange.lowerBound - 7,
            to: calendar.startOfDay(for: Date())
        )!
        
        let endDate = calendar.date(
            byAdding: .day,
            value: daysRange.upperBound - 7 + 1,
            to: calendar.startOfDay(for: Date()).addMinute(-1)
        )!
        fetchTask?.cancel()
        fetchTask = Task { @MainActor in
            let fetchedActions = await ActionController.fetchActions(userId: auth.userId!, startDate: startDate, endDate: endDate)
            if !Task.isCancelled {
                print("setting actions")
                self.actions = fetchedActions
                redrawChart.toggle()
            }
        }
    }
    
    var list: some View {
        List {
            HStack {
                Text("Days: \(daysRange.lowerBound)")
                RangedSliderView(value: $daysRange, bounds: 0...7)
                    .onChange(of: daysRange) {
                        fetchActions()
                    }
                Text("\(daysRange.upperBound)")
            }
            HStack {
                Text("Hours: \(hoursRange.lowerBound)")
                RangedSliderView(value: $hoursRange, bounds: 0...24)
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
                Spacer()
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
                        Text(actionTypeModel.name)
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
        value: daysRange.lowerBound - 7 + 1,
        to: calendar.startOfDay(for: Date())
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
                
                let secondCandle = Candle(
                    date: dateFormatter.string(from: midnight.addMinute(2)),
                    start: midnight.addMinute(2),
                    end: endDate,
                    actionTypeModel: action.actionTypeModel
                )
                candles.append(secondCandle)
            }
            else {
                let endDate = endDate == startDate
                ? min(
                    calendar.date(byAdding: .minute, value: 15, to: startDate)!,
                    calendar.date(bySettingHour: 23, minute: 59, second: 59, of: startDate)!
                )
                : endDate
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


struct RangedSliderView: View {
    let currentValue: Binding<ClosedRange<Int>>
    let sliderBounds: ClosedRange<Int>
    
    public init(value: Binding<ClosedRange<Int>>, bounds: ClosedRange<Int>) {
        self.currentValue = value
        self.sliderBounds = bounds
    }
    
    var body: some View {
        GeometryReader { geomentry in
            sliderView(sliderSize: geomentry.size)
        }
    }
    
    
    @ViewBuilder private func sliderView(sliderSize: CGSize) -> some View {
        let sliderViewYCenter = sliderSize.height / 2
        ZStack {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(UIColor.systemGray6))
                .frame(height: 4)
            ZStack {
                let sliderBoundDifference = sliderBounds.count
                let stepWidthInPixel = CGFloat(sliderSize.width) / CGFloat(sliderBoundDifference)
                
                // Calculate Left Thumb initial position
                let leftThumbLocation: CGFloat = currentValue.wrappedValue.lowerBound == Int(sliderBounds.lowerBound)
                ? 0
                : CGFloat(currentValue.wrappedValue.lowerBound - Int(sliderBounds.lowerBound)) * stepWidthInPixel
                
                // Calculate right thumb initial position
                let rightThumbLocation = CGFloat(currentValue.wrappedValue.upperBound) * stepWidthInPixel
                
                // Path between both handles
                lineBetweenThumbs(from: .init(x: leftThumbLocation, y: sliderViewYCenter), to: .init(x: rightThumbLocation, y: sliderViewYCenter))
                
                // Left Thumb Handle
                let leftThumbPoint = CGPoint(x: leftThumbLocation, y: sliderViewYCenter)
                thumbView(position: leftThumbPoint, value: currentValue.wrappedValue.lowerBound)
                    .highPriorityGesture(DragGesture().onChanged { dragValue in
                        
                        let dragLocation = dragValue.location
                        let xThumbOffset = min(max(0, dragLocation.x), sliderSize.width)
                        
                        let newValue = Int(sliderBounds.lowerBound) + Int(xThumbOffset / stepWidthInPixel)
                        
                        // Stop the range thumbs from colliding each other
                        if newValue < currentValue.wrappedValue.upperBound {
                            currentValue.wrappedValue = newValue...currentValue.wrappedValue.upperBound
                        }
                    })
                
                // Right Thumb Handle
                thumbView(position: CGPoint(x: rightThumbLocation, y: sliderViewYCenter), value: currentValue.wrappedValue.upperBound)
                    .highPriorityGesture(DragGesture().onChanged { dragValue in
                        let dragLocation = dragValue.location
                        let xThumbOffset = min(max(CGFloat(leftThumbLocation), dragLocation.x), sliderSize.width)
                        
                        var newValue = Int(xThumbOffset / stepWidthInPixel) // convert back the value bound
                        newValue = min(newValue, Int(sliderBounds.upperBound))
                        
                        // Stop the range thumbs from colliding each other
                        if newValue > currentValue.wrappedValue.lowerBound {
                            currentValue.wrappedValue = currentValue.wrappedValue.lowerBound...newValue
                        }
                    })
            }
        }
    }
    
    @ViewBuilder func lineBetweenThumbs(from: CGPoint, to: CGPoint) -> some View {
        Path { path in
            path.move(to: from)
            path.addLine(to: to)
        }.stroke(Color.black, lineWidth: 4)
    }
    
    @ViewBuilder func thumbView(position: CGPoint, value: Int) -> some View {
        ZStack {
            //            Text(String(value))
            //                .font(.secondaryFont(weight: .semibold, size: 10))
            //                .offset(y: -20)
            Circle()
                .frame(width: 24, height: 24)
                .foregroundColor(Color.white)
                .shadow(color: Color.black.opacity(0.16), radius: 8, x: 0, y: 2)
                .contentShape(Rectangle())
        }
        .position(x: position.x, y: position.y)
    }
}

struct RadioButton: View {
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .stroke(Color.gray, lineWidth: 2)
                    .frame(width: 20, height: 20)
                if isSelected {
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 12, height: 12)
                }
            }
        }
    }
}
