//
//  MinPeopleView.swift
//  History
//
//  Created by Nathik Azad on 5/30/24.
//

import SwiftUI

struct MinPeopleView: View {
    @Binding var event: EventModel
    
    var body: some View {
        let people = event.people
        let childPeople = event.childObjects.people
        Section(header: Text("People")) {
            // tracked people
            ForEach(event.people, id: \.id) { person in
                NavigationButton(destination: PersonView(personId: person.id!)) {
                    Text("\(person.name.capitalized)")
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(action: {
                        Task {
                            if let association = event.getAssociation(associationType: .object, associationId: person.id!) {
                                await AssociationController.deleteAssociation(id: association.id)
                            }
                        }
                    }) {
                        Image(systemName: "trash.fill")
                    }
                    .tint(.red)
                }
            }
            
            ForEach(childPeople, id: \.id) { person in
                NavigationButton(destination: PersonView(personId: person.id!)) {
                    Text("\(person.name.capitalized)")
                }
            }
            // untracked people
            if let people = event.metadata?.meetingData?.people {
                ForEach(people, id: \.name) { person in
                    NavigationLink(destination: PersonView(
                        name: person.name.capitalized,
                        description: event.notes.first?.1 ?? "",
                        createAction: {
                            person in
                            Task {
                                let  _ = await AssociationController.createEventObjectAssociation(userId: auth.userId!, eventId: event.id, objectId: person.id!)
                                MetadataController.removePerson(event: event, personName: person.name)
                            }
                        })) {
                            HStack {
                                Text("Add \(person.name.capitalized)")
                                Button(action: {
                                    MetadataController.removePerson(event: event, personName: person.name)
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
                        await AssociationController.createEventObjectAssociation(userId: auth.userId!, eventId: event.id, objectId: person.id!)
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
