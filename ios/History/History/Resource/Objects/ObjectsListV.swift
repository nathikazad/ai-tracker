//
//  ListObjectsV.swift
//  History
//
//  Created by Nathik Azad on 8/9/24.
//

import Foundation
import SwiftUI

extension String {
    var pluralize: String {
        guard count != 1 else { return self }
        
        if self.lowercased().hasSuffix("y") {
            return String(self.dropLast()) + "ies"
        } else if self.lowercased().hasSuffix("s") ||
                  self.lowercased().hasSuffix("ch") ||
                  self.lowercased().hasSuffix("sh") ||
                  self.lowercased().hasSuffix("x") {
            return self + "es"
        } else {
            return self + "s"
        }
    }
}

struct ObjectListView: View {
    @State var objectType: ObjectTypeModel
    @State private var objects: [ObjectModel] = []
    @State private var searchText = ""
    var selectionAction: ((ObjectModel) -> Void)?
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        List {
            TextField("Search \(objectType.name.pluralize)...", text: $searchText)
                .padding(7)
                .cornerRadius(8)
                .padding(2)
                .alignmentGuide(.listRowSeparatorLeading) { _ in
                    -20
                }
            
            
            NavigationButton(destination: ObjectView(
                objectType: objectType,
                clickObject: { newObject in
                    objects.append(newObject)
                }
            )) {
                Label("Create New \(objectType.name)", systemImage: "plus.circle")
            }
            .alignmentGuide(.listRowSeparatorLeading) { _ in
                -20
            }
            
            ForEach(filteredObjects, id: \.name) { object in
                NavigationButton(destination: ObjectView(objectModel: object)) {
                    Text(object.name)
                }
                .alignmentGuide(.listRowSeparatorLeading) { _ in
                    -20
                }
            }
        }
        .navigationBarTitle(Text(selectionAction == nil ? "\(objectType.name)" : "Select \(objectType.name)"), displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: ObjectTypeView(
                    objectType: objectType,
                    updateObjectTypeCallback: {
                        model in
                        objectType = model
                    }
                )) {
                    Image(systemName: "gear")
                }
            }
        }
        .onAppear(perform: fetchObjects)
    }
    
    private func fetchObjects() {
        Task {
            let userId = Authentication.shared.userId!
            let fetchedTypes = await ObjectV2Controller.fetchObjects(userId: userId, objectTypeId: objectType.id)
            DispatchQueue.main.async {
                objects = fetchedTypes
            }
        }
    }
    
    private var filteredObjects: [ObjectModel] {
        if searchText.isEmpty {
            return objects.sorted { $0.name < $1.name }
        } else {
            return objects.filter { $0.name.lowercased().contains(searchText.lowercased()) }
                .sorted { $0.name < $1.name }
        }
    }
    
    private func goBack() {
        presentationMode.wrappedValue.dismiss()
    }
}
