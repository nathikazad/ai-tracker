//
//  PeopleView.swift
//  History
//
//  Created by Nathik Azad on 5/30/24.
//

import SwiftUI
struct PeopleView: View {
    @State var people: [Person] = []
    @State private var searchText = ""
    var clickAction: ((Person) -> Void)?
    @Environment(\.presentationMode) var presentationMode
    
    // action to execute
    
    var body: some View {
        List {
            TextField("Search people...", text: $searchText)
                .padding(7)
                .cornerRadius(8)
                .padding(2)
            
            NavigationButton(destination: PersonView(
                createAction: {
                    person in
                    people.append(person)
                }
            )) {
                Text(" ")
                Spacer()
                Image(systemName: "plus.circle")
                Text("Add new person")
                    .padding(.leading, 5)
                // navigation link to create user with action to execute on creation
                Spacer()
            }
            
            
            
            ForEach(filteredPeople, id: \.id) { person in
                if(clickAction != nil) {
                    Button(action: {
                        clickAction!(person)
                        goBack()
                    }) {
                        Text(person.name)
                    }
                } else {
                    NavigationButton(destination: PersonView(
                        personId: person.id,
                        createAction: {
                            person in
                            people.append(person)
                        })
                    ) {
                        Text(person.name)
                    }
                }
            }
            
        }
        .navigationBarTitle(Text(clickAction == nil ? "Select People" : "People"), displayMode: .inline)
        .onAppear(perform: fetchPeople)
    }
    
    func fetchPeople() {
        Task {
            let resp = await ObjectController.fetchObjects(type: Person.self, userId: auth.userId!, objectType: .person)
            DispatchQueue.main.async {
                people = resp
            }
        }
    }
    
    var filteredPeople: [Person] {
        if searchText.isEmpty {
            return people
        } else {
            return people.filter { $0.name.contains(searchText) }
        }
    }
    
    func goBack() {
        self.presentationMode.wrappedValue.dismiss()
    }
}
