//
//  ActionTypeRow.swift
//  History
//
//  Created by Nathik Azad on 8/10/24.
//

import SwiftUI
struct ActionTypeRowView: View {
    @ObservedObject var actionTypeModel: ActionTypeModel
    @Binding var showColorPickerForActionTypeId: Int?
    @Binding var unselectedModels: [Int]
    let truncatedCandles: [Candle]
    let totalTimeOfAll: Int
    var fetchActions: () -> Void
    @Binding var allSelected: Bool
    @Binding var selectedWeekday: Weekday

    var body: some View {
        HStack {
            ActionTypeColorPicker(actionTypeModel: actionTypeModel, showColorPickerForActionTypeId: $showColorPickerForActionTypeId, fetchActions: fetchActions)
            
            if actionTypeModel.id != showColorPickerForActionTypeId {
                let totalTime = getCandles.reduce(0) { (result, candle) -> Int in
                    if (candle.actionTypeModel?.id == actionTypeModel.id) {
                        return result + Int(candle.end.timeIntervalSince(candle.start))
                    }
                    return result
                }
                let percentage = (totalTime * 100) / totalTimeOfAll
                
                Text("\(actionTypeModel.name) [\(totalTime.fromSecondsToHHMMString)] \(percentage)%")
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
    }
    
    private var getCandles: [Candle] {
        if !allSelected {
            return truncatedCandles.filterByWeekday(selectedWeekday: selectedWeekday)
        } else {
            return truncatedCandles
        }
    }
}

extension [Candle] {
    fileprivate func filterByWeekday(selectedWeekday: Weekday) -> [Candle] {
        let weekBoundary: WeekBoundary = state.currentWeek.getStartAndEnd(weekday: selectedWeekday)
        let startDate = weekBoundary.start
        let endDate = weekBoundary.end
        let ret = self.filter { candle in
            let startInRange = candle.start >= startDate && candle.start <= endDate
            let endInRange = candle.end >= startDate && candle.end <= endDate
            let spansRange = candle.start <= startDate && candle.end >= endDate
            return startInRange || endInRange || spansRange
        }
        return ret
    }
}

struct ActionRowForCandleView: View {
    @ObservedObject var actionModel: ActionModel
    @Binding var showColorPickerForActionTypeId: Int?
    @Binding var unselectedModels: [Int]
    let truncatedCandles: [Candle]
    var fetchActions: () -> Void

    var body: some View {
        ZStack(alignment: .leading) {
            HStack {
                ActionTypeColorPicker(actionTypeModel: actionModel.actionTypeModel, showColorPickerForActionTypeId: $showColorPickerForActionTypeId, fetchActions: fetchActions)
                if actionModel.actionTypeModel.id != showColorPickerForActionTypeId {
                    Text("\(actionModel.startTime.formattedTimeWithoutMeridian): \(actionModel.actionTypeModel.name) [\(actionModel.durationInSeconds.fromSecondsToHHMMString)]")
                    Spacer()
                    RadioButton(
                        isSelected: !unselectedModels.contains(where: { $0 == actionModel.actionTypeModel.id }),
                        action: {
                            if unselectedModels.contains(where: { $0 == actionModel.actionTypeModel.id }) {
                                unselectedModels.removeAll(where: { $0 == actionModel.actionTypeModel.id })
                            } else {
                                unselectedModels.append(actionModel.actionTypeModel.id!)
                            }
                        }
                    )
                }
            }
            ActionDestination(event: actionModel)
        }
        
    }
}


struct ActionTypeColorPicker: View {
    @ObservedObject var actionTypeModel: ActionTypeModel
    @Binding var showColorPickerForActionTypeId: Int?
    var fetchActions: () async -> Void

    var body: some View {
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
                CompactColorPicker(
                    selectedColor: Binding(
                        get: { actionTypeModel.staticFields.color },
                        set: { newValue in
                            actionTypeModel.staticFields.color = newValue
                        }
                    ),
                    isPickerVisible: Binding(
                        get: { actionTypeModel.id == showColorPickerForActionTypeId },
                        set: { _ in
                            Task {
                                await ActionTypesController.updateActionTypeModel(model: actionTypeModel)
                                await fetchActions()
                                showColorPickerForActionTypeId = nil
                            }
                        }
                    )
                )
            }
        }
    }
}
