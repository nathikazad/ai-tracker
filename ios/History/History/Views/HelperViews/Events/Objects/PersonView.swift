//
////
////  PersonView.swift
////  History
////
////  Created by Nathik Azad on 5/17/24.
////
//
//
//import SwiftUI
//
//
//import SwiftUI
//
import SwiftUI


struct PersonBuilderView: View {
//    @State private var person: Person
    @Environment(\.presentationMode) var presentationMode
    @State private var name = ""
    @State private var description = ""
    @State private var contactMethods: [String]
    var saveAction: (Person) -> Void
    
    init(name: String? = nil, person:Person? = nil, saveAction: @escaping (Person) -> Void) {
        _name = State(initialValue: person?.name ?? name ?? "")
        _description = State(initialValue: person?.notes.first ?? "")
        _contactMethods = State(initialValue: person?.contactMethods ?? [""])
        self.saveAction = saveAction
    }
    
    var body: some View {
        Form {
            LabelledTextField(name: "Name", value: $name)
            Section(header: Text("Description")) {
                TextEditor(text: $description)
                    .frame(minHeight: 50)
            }
            
            Section(header: Text("Contact Methods")) {
                List {
                    ForEach(contactMethods.indices, id: \.self) { index in
                        TextField("Enter contact method", text: $contactMethods[index]) {
                            UIApplication.shared.minimizeKeyboard()
                        }
                    }
                    .onDelete(perform: deleteMethod)
                    
                    Button(action: {
                        self.contactMethods.append("")
                    }) {
                        Label("Add New Method", systemImage: "plus.circle")
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            
            Button(action: {
                let person: Person = Person(name: name, notes: [description], contactMethods: contactMethods)
                saveAction(person)
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Text("Save")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .disabled(name.count < 3)
        }
        .navigationTitle(name.isEmpty ? "Create Person" : name)
    }
    
    private func deleteMethod(at offsets: IndexSet) {
        contactMethods.remove(atOffsets: offsets)
    }
}

struct PersonView: View {
    var personId: Int
    @State private var person: Person?
    
    var body: some View {
        ScrollView {
            if let person = person {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Name: \(person.name)")
                        .font(.title)
                    if let description = person.notes.first {
                        Text("Description: \(description)")
                            .font(.body)
                    }
                    if(!person.contactMethods.isEmpty) {
                        Text("Contact Methods")
                            .font(.headline)
                        ForEach(person.contactMethods, id: \.self) { contact in
                            Text(contact)
                                .padding(.leading, 10)
                        }
                    }
                }
                .padding()
                
                NavigationLink(destination: PersonBuilderView(person: person, saveAction: self.savePerson)) {
                    Text("Edit")
                        .foregroundColor(.blue)
                }
                .padding()
            } else {
                Text("Loading...")
            }
        }
        .navigationTitle(person?.name ?? "Person Details")
        .onAppear {
            fetchPerson()
        }
    }
    
    private func fetchPerson() {
        Task {
            if let fetchedPerson = await ObjectController.fetchObject(type: Person.self, objectId: personId) {
                DispatchQueue.main.async {
                    person = fetchedPerson
                }
            }
        }
    }
    
    private func savePerson(updatedPerson: Person) {
        Task {
//            await ObjectController.updateObject(person: updatedPerson)
            DispatchQueue.main.async {
                self.person = updatedPerson
            }
        }
    }
}


struct MinPeopleView: View {
    @Binding var event: EventModel?
    
    var body: some View {
        if event?.eventType == .meeting {
            ForEach(event!.people, id: \.id) { person in
                NavigationLink(destination: PersonView(personId: person.id!)) {
                    Text("Person: \(person.name.capitalized)")
                }
            }
            if let people = event?.metadata?.meetingData?.people {
                ForEach(people, id: \.self) { personName in
                    NavigationLink(destination: PersonBuilderView(
                        name: personName.capitalized,
                        saveAction: {
                            person in
                            print(person.name)
                    })) {
                        Text("Add \(personName.capitalized)")
                    }
                }
            }
            NavigationButton(destination: PeopleView()) {
                Spacer()
                Image(systemName: "plus.circle")
                Spacer()
            }
        }
    }
}

// fetch all people

struct PeopleView: View {
    @State var people: [ASObject] = []
    @State private var searchText = ""
    var clickAction: ((ASObject) -> Void)? 
    @Environment(\.presentationMode) var presentationMode
    
    // action to execute
    
    var body: some View {
        List {
            TextField("Search people...", text: $searchText)
                .padding(7)
                .foregroundColor(Color.black)
                .background(Color.white)
                .cornerRadius(8)
                .padding(2)
            
            NavigationButton(destination: PersonBuilderView(
                saveAction: {
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
                        personId: person.id!),
                        content: {
                            Text(person.name)
                        }
                    )
                }
            }
            
        }
        .navigationBarTitle(Text(clickAction == nil ? "Select People" : "People"), displayMode: .inline)
        .onAppear(perform: fetchPeople)
    }
    
    func fetchPeople() {
        Task {
            let resp = await ObjectController.fetchObjects(userId: auth.userId!, objectType: .book)
            DispatchQueue.main.async {
                people = resp.books
            }
        }
    }
    
    var filteredPeople: [ASObject] {
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

