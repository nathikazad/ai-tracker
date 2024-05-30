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


struct PersonView: View {
    //    @State private var person: Person
    @Environment(\.presentationMode) var presentationMode
    
    @State var personId:Int? = nil
    @State var person: Person = Person(name: "", data: PersonData())
    @State var name:String = ""
    @State private var description = ""
    @State private var contactMethods: [String] = []
    enum builderMode { case create, edit, view }
    @State var mode: builderMode = .create
    
    
    var createAction: ((Person) -> Void)?
    
    var body: some View {
        Form {
            HStack {
                Text("Name:")
                    .foregroundColor(.gray)
                    .frame(width: 80, alignment: .leading)
                if mode != .view {
                    TextField("Enter Name", text: $name) {
                        UIApplication.shared.minimizeKeyboard()
                    }
                } else {
                    Text(name)
                }
                
                Spacer()
                
                if mode != .create {
                    Button(action: {
                        mode = mode == .view ? .edit : .view
                    }) {
                        Image(systemName: mode == .view ? "pencil.circle" : "xmark.circle")
                    }
                    .buttonStyle(HighPriorityButtonStyle())
                }
            }
            
            if mode != .view || !description.isEmpty {
                Section(header: Text("Description")) {
                    if mode != .view {
                        TextEditor(text: $description)
                            .frame(minHeight: 50)
                    } else {
                        Text(description)
                    }
                }
            }
            
            if mode != .view || contactMethods.count  > 0 {
                Section(header: Text("Contact Methods")) {
                    List {
                        if mode != .view {
                            ForEach(contactMethods.indices, id: \.self) { index in
                                TextField("Enter contact method", text: $contactMethods[index]) {
                                    UIApplication.shared.minimizeKeyboard()
                                }
                            }
                            .onDelete(perform: {
                                offsets in
                                contactMethods.remove(atOffsets: offsets)
                                mode = .edit
                            })
                            Button(action: {
                                if !(contactMethods.last?.isEmpty ?? false) {
                                    contactMethods.append("")
                                }
                            }) {
                                Label("Add Contact Method", systemImage: "plus.circle")
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                        } else {
                            ForEach(contactMethods.indices, id: \.self) { index in
                                Text(contactMethods[index])
                            }
                            
                        }
                    }
                }
            }
       
            if mode != .view {
                Section {
                    Button(action: {
                        person.name = name
                        person.data?.description = description
                        person.data?.contactMethods = contactMethods
                        Task {
                            if mode == .create {
                                let personId = await ObjectController.createObject(userId: auth.userId!, object: person)
                                person.id = personId
                                if createAction != nil {
//                                    createAction?(person)
                                    self.presentationMode.wrappedValue.dismiss()
                                }
                            } else {
                                await ObjectController.mutateObject(object: person)
                                DispatchQueue.main.async {
                                    mode = .view
                                }
                            }
                        }

                    }) {
                        Text("Save")
                    }
                    .disabled(name.count < 3)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            
            if mode == .edit {
                Section {
                    Button(action: {
                        Task {
                            await ObjectController.deleteObject(id: person.id!)
                            self.presentationMode.wrappedValue.dismiss()
                        }
                        
                    }) {
                        Text("Delete")
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(.red)
                }
                
                
            }
            
        }
        .onAppear {
            if personId == nil {
                mode = .create
            } else {
                mode = .view
                Task {
                    if let person = await ObjectController.fetchObject(type: Person.self, objectId: personId!) {
                        DispatchQueue.main.async {
                            self.person = person
                            name = person.name
                            description = person.data?.description ?? ""
                            contactMethods = person.data?.contactMethods ?? []
                        }
                    }
                }
            }
        }
        .navigationTitle(name.isEmpty ? "Create Person" : name)
    }
}


struct MinPeopleView: View {
    @Binding var event: EventModel?
    
    var body: some View {
        if event?.eventType == .meeting {
            ForEach(event!.people, id: \.id) { person in
                NavigationButton(destination: PersonView(personId: person.id!)) {
                    Text("\(person.name.capitalized)")
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(action: {
                        Task {
                            if let association = event!.getAssociation(associationType: .object, associationId: person.id!) {
                                await AssociationController.deleteAssociation(id: association.id)
                            }
                        }
                    }) {
                        Image(systemName: "trash.fill")
                    }
                    .tint(.red)
                }
            }
            if let people = event?.metadata?.meetingData?.people {
                ForEach(people, id: \.self) { personName in
                    NavigationLink(destination: PersonView(
                        name: personName.capitalized,
                        createAction: {
                            person in
                            Task {
                                await AssociationController.createEventObjectAssociation(userId: auth.userId!, eventId: event!.id, objectId: person.id!)
                                MetadataController.removePerson(event: event!, personName: personName)
                            }
                        })) {
                            HStack {
                                Text("Add \(personName.capitalized)")
                                Button(action: {
                                    MetadataController.removePerson(event: event!, personName: personName)
                                }) {
                                    Image(systemName: "xmark.square.fill")
                                }
                                .buttonStyle(HighPriorityButtonStyle())
                            }
                        }
                }
            }
            NavigationButton(destination: PeopleView(
                clickAction: {
                    person in
                    Task {
                        await AssociationController.createEventObjectAssociation(userId: auth.userId!, eventId: event!.id, objectId: person.id!)
                    }
                }
            )) {
                Spacer()
                Image(systemName: "plus.circle")
                Spacer()
            }
        }
    }
}

// fetch all people

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
                .foregroundColor(Color.black)
                .background(Color.white)
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

