import SwiftUI

struct AggregatorFieldsSection: View {
    @ObservedObject var model: AggregateModel
    @ObservedObject var actionTypeModel: ActionTypeModel
    @Binding var changesToSave: Bool
    @State var selectedDataType: String = "Duration"
    
    var dataType: String {
        if model.metadata.aggregatorType == .compare {
            return "Time"
        } else if model.metadata.aggregatorType == .count {
            return "Number"
        } else {
            return selectedDataType
        }
    }
    
    var body: some View {
        Section {
            HStack {
                ShortStringComponent(fieldName: "Name: ", value: $model.metadata.name)
                    .onChange(of: model.metadata.name) {
                        changesToSave = true
                    }
            }
            WindowPicker(metadata: model.metadata, changesToSave: $changesToSave)
            AggregatorTypePicker(metadata: model.metadata, changesToSave: $changesToSave)
            if model.metadata.aggregatorType != .count {
                FieldPicker(metadata: model.metadata, changesToSave: $changesToSave, dynamicFields: actionTypeModel.dynamicFields.filterNumericTypes, dataType: $selectedDataType)
            }
            GoalsSection(aggregate: model, dataType: dataType, changesToSave: $changesToSave)
        }
    }
}

struct AggregatorTypePicker: View {
    @ObservedObject var metadata: AggregateMetaData
    @Binding var changesToSave: Bool
    
    var body: some View {
        Picker("Aggregator Type", selection: $metadata.aggregatorType) {
            ForEach(AggregatorType.allCases, id: \.self) { type in
                Text(type.rawValue.capitalized).tag(type)
            }
        }
        .pickerStyle(MenuPickerStyle())
        .onChange(of: metadata.aggregatorType) { old, new in
            if new == .sum {
                if metadata.field.isEmpty {
                    metadata.field = "Duration"
                }
            }
            if new == .compare {
                if metadata.field.isEmpty {
                    metadata.field = "Start Time"
                }
            }
            changesToSave = true
        }
    }
}

struct FieldPicker: View {
    @ObservedObject var metadata: AggregateMetaData
    @Binding var changesToSave: Bool
    var dynamicFields: [String: Schema]
    @Binding var dataType: String
    
    var body: some View {
        Picker("Field", selection: $metadata.field) {
            if metadata.aggregatorType == .compare {
                Text("Start Time").tag("Start Time")
                Text("End Time").tag("End Time")
            } else if metadata.aggregatorType == .sum {
                Text("Duration").tag("Duration")
                ForEach(Array(dynamicFields.keys.sorted()), id: \.self) { key in
                    Text(dynamicFields[key]?.name ?? key).tag(key)
                }
            }
        }
        .pickerStyle(MenuPickerStyle())
        .onChange(of: metadata.field) {
            if metadata.field != "Duration" {
                dataType = dynamicFields[metadata.field]?.dataType ?? "Duration"
            } else {
                dataType = "Duration"
            }
            changesToSave = true
        }
    }
}

struct WindowPicker: View {
    @ObservedObject var metadata: AggregateMetaData
    @Binding var changesToSave: Bool
    
    var body: some View {
        Picker("Window", selection: $metadata.window) {
            ForEach(ASWindow.allCases, id: \.self) { window in
                if window != .monthly {
                    Text(window.rawValue.capitalized).tag(window)
                }
            }
        }
        .pickerStyle(MenuPickerStyle())
        .onChange(of: metadata.window) {
            changesToSave = true
        }
    }
}
