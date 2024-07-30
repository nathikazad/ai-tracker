//
//  ShowActionView.swift
//  History
//
//  Created by Nathik Azad on 7/27/24.
//

import SwiftUI

struct ShowActionView: View {
    @StateObject private var action: ActionModel
    
    init(actionModel: ActionModel) {
        _action = StateObject(wrappedValue: actionModel)
    }
    
    init(actionType: ActionTypeModel) {
        _action = StateObject(wrappedValue:  ActionModel(actionTypeId: actionType.id!, startTime: Date().toUTCString, actionTypeModel: actionType))
    }
    
    var body: some View {
        Form {
            Section(header: Text("Time Information")) {
                DatePicker(
                    action.actionTypeModel.staticFields.startTime?.name ?? "Start Time",
                    selection: Binding(
                        get: { self.action.startTime},
                        set: { self.action.startTime = $0 }
                    ),
                    displayedComponents: [.date, .hourAndMinute]
                )
                
                if action.actionTypeModel.meta.hasDuration {
                    DatePicker(
                        action.actionTypeModel.staticFields.endTime?.name ?? "End Time",
                        selection: Binding(
                            get: { self.action.endTime ?? Date() },
                            set: { self.action.endTime = $0 }
                        ),
                        displayedComponents: [.date, .hourAndMinute]
                    )
                }
            }
            
            if(Array(action.actionTypeModel.dynamicFields.keys).count > 0) {
                DynamicFieldsView(
                    dynamicFields: $action.actionTypeModel.dynamicFields,
                    dynamicData: $action.dynamicData,
                    updateView: {
                        self.action.objectWillChange.send()
                    })
            }
            
            Section {
                Button("Save") {
                    saveChanges()
                }
            }
        }
        .navigationTitle(action.id == nil ?  "Create \(action.actionTypeModel.name) Action": "Edit Action")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: ActionTypeView(
                    model: action.actionTypeModel
                )) {
                    Image(systemName: "gear")
                }
            }
        }
        .onAppear {
            Task {
                if (action.id != nil) {
                    let actions = await ActionController.fetchActions(userId: Authentication.shared.userId!, actionId: action.id)
                    if (!actions.isEmpty) {
                        self.action.copy(actions[0])
                    }
                }
            }
        }
    }

    private func saveChanges() {
        Task {
//            print(action.id)
            if action.id != nil {
                print("updating")
                await ActionController.updateActionModel(model: action)
            } else {
                print("creating")
                let actionId = await ActionController.createActionModel(model: action)
                action.id = actionId
            }
        }
    }
}



struct DynamicFieldsView: View {
    @Binding var dynamicFields: [String: Schema]
    @Binding var dynamicData: [String: AnyCodable]
    var updateView: (() -> Void)
    var body: some View {
        Section {
            Section(header: Text("Dynamic Fields")) {
                ForEach(Array(dynamicFields.keys), id: \.self) { key in
                    if let field = dynamicFields[key] {
                        if let dataType = getDataType(from: field.dataType) {
                            Group {
                                switch dataType {
                                case .longString:
                                    LongStringComponent(fieldName: field.name,
                                                        value: bindingFor(key, "") as Binding<String>)
                                case .shortString:
                                    ShortStringComponent(fieldName: field.name,
                                                         value: bindingFor(key, "") as Binding<String>)
                                case .enumerator:
                                    EnumComponent(fieldName: field.name,
                                                  value: bindingFor(key, field.getEnums.first!),
                                                  enumValues: field.getEnums)
                                case .unit:
                                    UnitComponent(
                                        fieldName: field.name,
                                        unit: bindingFor(key, Unit.defaultUnit) as Binding<Unit>
                                    )
                                case .currency:
                                    CurrencyComponent(
                                        fieldName: field.name,
                                        currency: bindingFor(key, Currency.defaultCurrency) as Binding<Currency>
                                    )
                                case .duration:
                                    DurationComponent(
                                        fieldName: field.name,
                                        duration: bindingFor(key, Duration.defaultDuration) as Binding<Duration>
                                    )
                                case .dateTime:
                                    TimeComponent(
                                        fieldName: field.name,
                                        time: bindingFor(key, Date()) as Binding<Date>
                                    )
                                case .time:
                                    TimeComponent(
                                        fieldName: field.name,
                                        time: bindingFor(key, Date()) as Binding<Date>
                                    )
                                default:
                                    EmptyView()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func bindingFor<T>(_ key: String, _ defaultValue: T) -> Binding<T> {
        Binding(
            get: {
                (dynamicData[key]?.toType(T.self) as? T) ?? defaultValue
            },
            set: { newValue in
                dynamicData[key] = AnyCodable(newValue)
                updateView()
            }
        )
    }
}
