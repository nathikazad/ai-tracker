//
//  ListActions.swift
//  History
//
//  Created by Nathik Azad on 7/22/24.
//

import Foundation

import SwiftUI
struct ListActionsTypesView: View {
    @State var actions: [ActionTypeModel] = []
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
                        actions.append(actionType)
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
                            await ActionTypesController.createActionTypeModel(model: actionType)
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
        for action: ActionTypeModel,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        Group {
            switch listActionType {
            case .forTemplate, .returnToActionType:
                Button(action: {
                    clickAction?(action)
                    goBack()
                }) {
                    content()
                }
            case .takeToActionView:
                NavigationLink(destination: 
                                ShowActionView(actionTypeId: action.id!,
                                               clickAction: { _ in goBack() })) {
                    content()
                }
            case .takeToAggregateCreateView:
                NavigationLink(destination: ShowGoalView(
                    aggregateModel: AggregateModel(actionTypeId: action.id!),
                    clickAction: { goBack() }
                )) {
                    content()
                }
            default:
                NavigationLink(destination: ListActionsView(
                    actionType: action,
                    actionTypeName: action.name,
                    createAction: { action in actions.append(action) }
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
                actions = resp
            }
        }
    }
    
    var filteredActions: [ActionTypeModel] {
        if searchText.isEmpty {
            return actions.sorted { $0.name < $1.name }
        } else {
            return actions.filter { $0.name.contains(searchText) }.sorted { $0.name < $1.name }
        }
    }
    
    func goBack() {
        self.presentationMode.wrappedValue.dismiss()
    }
}
