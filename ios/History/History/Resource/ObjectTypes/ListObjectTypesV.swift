//
//  ListObjectTypesV.swift
//  History
//
//  Created by Nathik Azad on 8/9/24.
//

import Foundation
import SwiftUI

struct ObjectTypeListView: View {
    @State private var objectTypes: [ObjectType] = []
    @State private var searchText = ""
    var selectionAction: ((ObjectType) -> Void)?
    @Environment(\.presentationMode) var presentationMode
    var listType: ListType = .normal

    enum ListType {
        case normal
        case forTemplate
    }
    
    var body: some View {
        List {
            TextField("Search object types...", text: $searchText)
                .padding(7)
                .foregroundColor(Color.black)
                .background(Color.white)
                .cornerRadius(8)
                .padding(2)
            
            if listType != .forTemplate {
                NavigationButton(destination: ObjectTypeView(
                    
                    objectType: ObjectType(name: "", description: "", fields: [:]),
                    updateObjectTypeCallback: { newObjectType in
                        objectTypes.append(newObjectType)
                    }
                )) {
                    Label("Create New Object Type", systemImage: "plus.circle")
                }
                
                NavigationButton(destination: ObjectTypeListView(
                    selectionAction: { selectedObjectType in
                        Task {
                            await ObjectTypeController.createObjectType(objectType: selectedObjectType)
                            fetchObjectTypes()
                        }
                    },
                    listType: .forTemplate
                )) {
                    Label("Import From Templates", systemImage: "plus.circle")
                }
            }
            
            ForEach(filteredObjectTypes, id: \.name) { objectType in
                if listType == .forTemplate {
                    Button(action: {
                        selectionAction?(objectType)
                        goBack()
                    }) {
                        Text(objectType.name)
                    }
                } else {
                    NavigationButton(destination: ObjectTypeView(objectType: objectType)) {
                        Text(objectType.name)
                    }
                }
            }
        }
        .navigationBarTitle(Text(selectionAction == nil ? "Object Types" : "Select Object Type"), displayMode: .inline)
        .onAppear(perform: fetchObjectTypes)
    }
    
    private func fetchObjectTypes() {
        Task {
            let userId = listType == .forTemplate ? 1 : Authentication.shared.userId!
            let fetchedTypes = await ObjectTypeController.fetchObjectTypes(userId: userId)
            DispatchQueue.main.async {
                objectTypes = fetchedTypes
            }
        }
    }
    
    private var filteredObjectTypes: [ObjectType] {
        if searchText.isEmpty {
            return objectTypes.sorted { $0.name < $1.name }
        } else {
            return objectTypes.filter { $0.name.lowercased().contains(searchText.lowercased()) }
                .sorted { $0.name < $1.name }
        }
    }
    
    private func goBack() {
        presentationMode.wrappedValue.dismiss()
    }
}
