//
//  MinPeopleView.swift
//  History
//
//  Created by Nathik Azad on 5/30/24.
//

import SwiftUI

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
                                let  _ = await AssociationController.createEventObjectAssociation(userId: auth.userId!, eventId: event!.id, objectId: person.id!)
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
