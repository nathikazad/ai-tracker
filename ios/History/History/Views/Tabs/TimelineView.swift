//
//  File.swift
//  History
//
//  Created by Nathik Azad on 4/8/24.
//

import SwiftUI

// Define your custom views for each tab
struct TimelineView: View {
    init() {
        print("timeline init")
    }
    @StateObject var interactionController = InteractionsController()
    @State private var showPopupForId: Int?
    @State private var draftContent = ""
    
    
    
    var body: some View {
        VStack {
            Text(interactionController.formattedDate)
            //                    .font(.title)
                .foregroundColor(.black)
                .padding(.top, 5)
                .frame(maxWidth: .infinity, alignment: .center)
                .gesture(
                    DragGesture().onEnded { gesture in
                        if gesture.translation.width < 0 { // swipe left
                            interactionController.goToNextDay()
                        } else if gesture.translation.width > 0 { // swipe right
                            interactionController.goToPreviousDay()
                        }
                    }
                )
            Group {
                if interactionController.interactions.isEmpty {
                    VStack {
                        Spacer()
                        Text("No Events Yet")
                            .foregroundColor(.black)
                            .font(.title2)
                        Text("Create an event by clicking the microphone below")
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center) // This will center-align the text horizontally
                            .padding(.horizontal, 20)
                        Spacer()
                    }
                } else {
                    listView
                }
            }
            .onAppear {
                print("Timelineview has appeared, going to listen to user \(Authentication.shared.userId)")
                if(Authentication.shared.areJwtSet) {
                    interactionController.fetchInteractions(userId: Authentication.shared.userId!)
                    interactionController.listenToInteractions(userId: Authentication.shared.userId!)
                }
            }
            .onDisappear {
                print("Timelineview has disappeared")
                interactionController.cancelListener()
            }
        }
        .overlay(
            popupView
        )
    }
    
    private var emptyStateView: some View {
        VStack {
            Spacer()
            Text("No Events Yet")
                .foregroundColor(.black)
                .font(.title2)
            Text("Record your first event by clicking the microphone below and saying what you did.")
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Spacer()
        }
    }
    
    private var listView: some View {
        List {
            ForEach(interactionController.interactions, id: \.id) { interaction in
                HStack {
                    Text(interaction.formattedTime)
                        .font(.headline)
                        .frame(width: 100, alignment: .leading)
                    Divider()
                    Text(interaction.content)
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .onTapGesture {
                            draftContent = interaction.content
                            showPopupForId = interaction.id
                        }
                }
                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                    Button(action: {
                        print("Tapped right on \(interaction.id)")
                        // TODO: start microphone with parameters
                    }) {
                        Image(systemName: "mic.fill")                                .foregroundColor(.green) // Setting the color of the icon
                    }
                }
            }
            .onDelete { indices in
                indices.forEach { index in
                    let interactionId = interactionController.interactions[index].id
                    interactionController.deleteInteraction(id: interactionId)
                }
            }
            
        }
    }
    
    private var popupView: some View {
        Group {
            if showPopupForId != nil {
                VStack {
                    Text("Edit Content")
                        .font(.headline) // Optional: Sets the font for the title
                        .padding(.bottom, 5) // Reduces the space below the title
                    
                    TextEditor(text: $draftContent)
                        .frame(minHeight: 50, maxHeight: 200) // Reduces the minimum height and sets a max height
                        .padding(4) // Reduces padding around the TextEditor
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.gray, lineWidth: 1) // Border for TextEditor
                        )
                    
                    Button(action: {
                        DispatchQueue.main.async {
                            interactionController.editInteraction(id: showPopupForId!, content: draftContent)
                            self.showPopupForId = nil
                        }
                    }) {
                        Text("Save")
                            .foregroundColor(.black)
                    }
                    .padding(.top, 5)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 5)
                .frame(width: 300)
                .overlay(
                    Button(action: {
                        showPopupForId = nil
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                    },
                    alignment: .topTrailing
                )
            }
        }
    }
}


#Preview {
    TimelineView()
}
