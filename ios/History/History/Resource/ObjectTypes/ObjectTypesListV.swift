//
//  ListObjectTypesV.swift
//  History
//
//  Created by Nathik Azad on 8/9/24.
//

import Foundation
import SwiftUI

struct ObjectTypeListView: View {
    @State private var objectTypes: [ObjectTypeModel] = []
    @State private var searchText = ""
    var selectionAction: ((ObjectTypeModel) -> Void)?
    @Environment(\.presentationMode) var presentationMode
    var listType: ListType = .takeToObjectTypes

    enum ListType {
        case takeToObjectTypes
        case forTemplate
        case takeToObjects
    }
    
    var body: some View {
        List {
            TextField("Search nouns...", text: $searchText)
                .padding(7)
                .cornerRadius(8)
                .padding(2)
                .alignmentGuide(.listRowSeparatorLeading) { _ in
                    -20
                }
            
            if listType != .forTemplate {
                NavigationButton(destination: ObjectTypeView(
                    
                    objectType: ObjectTypeModel(name: "", description: "", fields: [:]),
                    updateObjectTypeCallback: { newObjectType in
                        objectTypes.append(newObjectType)
                    }
                )) {
                    Label("Create New Noun", systemImage: "plus.circle")
                }
                .alignmentGuide(.listRowSeparatorLeading) { _ in
                    -20
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
                .alignmentGuide(.listRowSeparatorLeading) { _ in
                    -20
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
                    .alignmentGuide(.listRowSeparatorLeading) { _ in
                        -20
                    }
                } else if listType == .takeToObjectTypes {
                    NavigationButton(destination: ObjectTypeView(objectType: objectType)) {
                        Text(objectType.name)
                    }
                    .alignmentGuide(.listRowSeparatorLeading) { _ in
                        -20
                    }
                } else {
                    NavigationButton(destination: ObjectListView(objectType: objectType)) {
                        Text(objectType.name)
                    }
                    .alignmentGuide(.listRowSeparatorLeading) { _ in
                        -20
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
    
    private var filteredObjectTypes: [ObjectTypeModel] {
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
