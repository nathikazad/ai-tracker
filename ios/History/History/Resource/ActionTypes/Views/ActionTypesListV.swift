//
//  ListActions.swift
//  History
//
//  Created by Nathik Azad on 7/22/24.
//

import Foundation

import SwiftUI
struct ListActionsTypesView: View {
    @State var actionsTypes: [ActionTypeModel] = []
    @State private var searchText = ""
    var clickAction: ((ActionTypeModel) -> Void)?
    @Environment(\.presentationMode) var presentationMode
    var listActionType: ListActionType = .takeToActionListView

    enum ListActionType {
        case takeToActionView
        case takeToActionListView
        case takeToAggregateCreateView
        case forTemplate
        case returnToActionType
    }
    
    
    var body: some View {
        List {
            TextField("Search verbs...", text: $searchText)
                .padding(7)
                .cornerRadius(8)
                .padding(2)
                .alignmentGuide(.listRowSeparatorLeading) { _ in
                    -20
                }
            if (listActionType != .forTemplate) {
                NavigationButton(destination: ActionTypeView(
                    updateActionTypeCallback: {
                        actionType in
                        actionsTypes.append(actionType)
                    }
                )) {
                    Text(" ")
                    Spacer()
                    Image(systemName: "plus.circle")
                    Text("Create New Verb")
                        .padding(.leading, 5)
                    // navigation link to create user with action to execute on creation
                    Spacer()
                }
                .alignmentGuide(.listRowSeparatorLeading) { _ in
                    -20
                }
            
                NavigationButton(destination: ListActionsTypesView(
                    clickAction: {
                        actionType in
                        print("Create new action type \(actionType)")
                        Task {
                            let _ = await ActionTypesController.createActionTypeModel(model: actionType)
                            fetchActionTypes()
                        }
                    }, listActionType: .forTemplate
                )) {
                    Text(" ")
                    Spacer()
                    Image(systemName: "plus.circle")
                    Text("Import From Templates")
                        .padding(.leading, 5)
                    // navigation link to create user with action to execute on creation
                    Spacer()
                }
                .alignmentGuide(.listRowSeparatorLeading) { _ in
                    -20
                }
            }
            
            ForEach(filteredActions, id: \.name) { action in
                 destinationView(for: action) {
                    Text(action.name)
                }
                .alignmentGuide(.listRowSeparatorLeading) { _ in -20 }
            }
            
        }
        .navigationBarTitle(Text(clickAction == nil ? "Select Verb" : "Verbs"), displayMode: .inline)
        .onAppear(perform: fetchActionTypes)
    }
    
    func destinationView<Content: View>(
        for actionTypeModel: ActionTypeModel,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        Group {
            switch listActionType {
            case .forTemplate, .returnToActionType:
                Button(action: {
                    clickAction?(actionTypeModel)
                    goBack()
                }) {
                    content()
                }
            case .takeToActionView:
                NavigationLink(destination: 
                                ShowActionView(actionTypeId: actionTypeModel.id!,
                                               clickAction: { _ in goBack() })) {
                    content()
                }
            case .takeToAggregateCreateView:
                NavigationLink(destination: ShowGoalView(
                    aggregateModel: AggregateModel(actionTypeId: actionTypeModel.id!),
                    clickAction: { goBack() }
                )) {
                    content()
                }
            default:
                NavigationLink(destination: ListActionsView(
                    actionType: actionTypeModel,
                    actionTypeName: actionTypeModel.name,
                    createAction: { action in actionsTypes.append(actionTypeModel) }
                )) {
                    content()
                }
            }
        }
    }
    
    func fetchActionTypes() {
        Task {
            let resp = await ActionTypesController.fetchActionTypes(userId: listActionType == .forTemplate ? 1 : Authentication.shared.userId!)
            DispatchQueue.main.async {
                actionsTypes = resp
            }
        }
    }
    
    var filteredActions: [ActionTypeModel] {
        if searchText.isEmpty {
            return actionsTypes.sorted { $0.name < $1.name }
        } else {
            return actionsTypes.filter { $0.name.contains(searchText) }.sorted { $0.name < $1.name }
        }
    }
    
    func goBack() {
        self.presentationMode.wrappedValue.dismiss()
    }
}
