//
//  MinActionComponent.swift
//  History
//
//  Created by Nathik Azad on 7/27/24.
//

import SwiftUI
struct MinActionComponent: View {
    var action: ActionModel
    var body: some View {
        VStack(alignment: .leading) {
            if(!action.actionTypeModel.meta.hasDuration) {
                Text("Time: \(action.startTime.formattedShortDateAndTime)")
            } else {
                let startTimeName =  action.actionTypeModel.staticFields.startTime?.name ?? "Start Time"
                Text("\(startTimeName): \(action.startTime.formattedShortDateAndTime)")
                if let endTime = action.endTime {
                    let endTimeName =  action.actionTypeModel.staticFields.endTime?.name ?? "End Time"
                    Text("\(endTimeName): \(endTime.formattedShortDateAndTime) ")
                }
            }
            ForEach(Array(action.actionTypeModel.dynamicFields.keys), id: \.self) { key in
                if let value = action.dynamicData[key] {
                    let fieldName: String = action.actionTypeModel.dynamicFields[key]!.name
                    Text("\(fieldName): \(value.toString)")
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
