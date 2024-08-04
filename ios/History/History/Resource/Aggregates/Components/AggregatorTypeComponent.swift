import SwiftUI

struct AggregatorTypeSection: View {
    @ObservedObject var model: AggregateModel
    @Binding var changesToSave: Bool
    
    var body: some View {
        Section {
            AggregatorTypePicker(metadata: model.metadata, changesToSave: $changesToSave)
            if model.metadata.aggregatorType != .count {
                FieldPicker(metadata: model.metadata, changesToSave: $changesToSave)
            }
            WindowPicker(metadata: model.metadata, changesToSave: $changesToSave)
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
    
    var body: some View {
        Picker("Field", selection: $metadata.field) {
            if metadata.aggregatorType == .compare {
                Text("Start Time").tag("Start Time")
                Text("End Time").tag("End Time")
            }
            if metadata.aggregatorType == .sum {
                Text("Duration").tag("Duration")
            }
        }
        .pickerStyle(MenuPickerStyle())
        .onChange(of: metadata.field) { _ in
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
                Text(window.rawValue.capitalized).tag(window)
            }
        }
        .pickerStyle(MenuPickerStyle())
        .onChange(of: metadata.window) { _ in
            changesToSave = true
        }
    }
}
