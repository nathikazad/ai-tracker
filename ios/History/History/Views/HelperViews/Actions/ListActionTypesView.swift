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
    
    // action to execute
    
    var body: some View {
        List {
            TextField("Search actions...", text: $searchText)
                .padding(7)
                .foregroundColor(Color.black)
                .background(Color.white)
                .cornerRadius(8)
                .padding(2)
            
//            NavigationButton(destination: EditActionTypeView(
//                actionTypeName: "Sleep",
//                createAction: {
//                    action in
//                    actions.append(action)
//                }
//            )) {
//                Text(" ")
//                Spacer()
//                Image(systemName: "plus.circle")
//                Text("Add new action")
//                    .padding(.leading, 5)
//                // navigation link to create user with action to execute on creation
//                Spacer()
//            }
            
            
            
            ForEach(filteredActions, id: \.name) { action in
                if(clickAction != nil) {
                    Button(action: {
                        clickAction!(action)
                        goBack()
                    }) {
                        Text(action.name)
                    }
                } else {
                    NavigationButton(destination: ShowActionTypeView(
                        model: action,
                        createAction: {
                            action in
                            actions.append(action)
                        })
                    ) {
                        Text(action.name)
                    }
                }
            }
            
        }
        .navigationBarTitle(Text(clickAction == nil ? "Select Action" : "Actions"), displayMode: .inline)
        .onAppear(perform: fetchPeople)
    }
    
    func fetchPeople() {
        Task {
            let resp = await fetchActionTypes()
            DispatchQueue.main.async {
                actions = resp
            }
        }
    }
    
    var filteredActions: [ActionTypeModel] {
        if searchText.isEmpty {
            return actions
        } else {
            return actions.filter { $0.name.contains(searchText) }
        }
    }
    
    func goBack() {
        self.presentationMode.wrappedValue.dismiss()
    }
}
