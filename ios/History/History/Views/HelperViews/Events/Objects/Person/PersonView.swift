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
import PhotosUI


struct PersonView: View {
    //    @State private var person: Person
    @Environment(\.presentationMode) var presentationMode
    
    @State var personId:Int? = nil
    @State var person: Person = Person(name: "", data: PersonData())
    @State var name:String = ""
    @State var description = ""
    @State private var contactMethods: [String] = []
    enum builderMode { case create, edit, view }
    @State var mode: builderMode = .create  
    var createAction: ((Person) -> Void)?
    
    @State private var selectedItem: PhotosPickerItem?
    @State var image: UIImage?
    
    var body: some View {
        Form {
            HStack {
                if mode == .create || mode == .edit {
                    PhotosPicker(
                        selection: $selectedItem,
                        matching: .images,
                        photoLibrary: .shared()) {
                            if let image = image {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle().stroke(Color.white, lineWidth: 2) // Optional: Adds a white border for visual clarity
                                    )
                                    .padding(.trailing, 5)
                            } else {
                                Circle()
                                    .fill(Color.gray.opacity(0.5))
                                    .frame(width: 50, height: 50)
                                    .overlay(
                                        Image(systemName: "plus")
                                            .foregroundColor(.white)
                                    )
                                    .padding(.trailing, 5)
                            }
                        }
                        .onChange(of: selectedItem) {
                            Task {
                                if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
                                    let retImage = UIImage(data: data)
                                    if let loc = saveImage(image: retImage!, imageLocation: person.data?.photo) {
                                        image = loadImage(location: loc)
                                        person.data?.photo = loc
                                    }
                                } else {
                                    print("Failed to load the image")
                                }
                            }
                        }
                    } else {
                        if let image = image {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .aspectRatio(contentMode: .fill) // This will fill the space, possibly cropping the image
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                                .overlay(
                                    Circle().stroke(Color.white, lineWidth: 2) // Optional: Adds a white border for visual clarity
                                )
                                .padding(.trailing, 5)
                        }
                    }
                
                Text("Name:")
                    .foregroundColor(.gray)
                    .frame(width: 60, alignment: .leading)
                    .padding(.leading, 10)
                
                if mode == .create {
                    TextField("Enter Name", text: $name) {
                        UIApplication.shared.minimizeKeyboard()
                    }
                } else if mode == .edit {
                    TextField("Enter Name", text: $name) {
                        UIApplication.shared.minimizeKeyboard()
                    }
                    Spacer()
                    Button(action: {
                        mode = .view
                    }) {
                        Image(systemName: "xmark.circle")
                    }
                    .buttonStyle(HighPriorityButtonStyle())
                } else if mode == .view {
                    Text(name)
                    Spacer()
                    Button(action: {
                        mode = .edit
                    }) {
                        Image(systemName: "pencil.circle")
                    }
                    .buttonStyle(HighPriorityButtonStyle())
                }
            }
            
            if mode == .edit || mode == .create {
                Section(header: Text("Description")) {
                        TextEditor(text: $description)
                            .frame(minHeight: 50)
                            .onChange(of: description)  {
                                if description.last == "\n" {
                                    UIApplication.shared.minimizeKeyboard()
                                }
                            }
                }
            } else if !description.isEmpty {
                Section(header: Text("Description")) {
                    Text(description)
                }
            }
            
            if mode == .edit || mode == .create  {
                Section(header: Text("Contact Methods")) {
                    List {
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
                    }
                }
            } else if contactMethods.count  > 0 {
                Section(header: Text("Contact Methods")) {
                    List {
                        ForEach(contactMethods.indices, id: \.self) { index in
                            Text(contactMethods[index])
                        }
                    }
                }
            }
       
            if mode == .edit || mode == .create {
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
                                    createAction?(person)
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
            
            if mode == .view && person.events.count > 0 {
                EventsListView(events: $person.events)
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
                            if let photo = person.data?.photo {
                                image = loadImage(location: photo)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(name.isEmpty ? "Create Person" : name)
    }
}


