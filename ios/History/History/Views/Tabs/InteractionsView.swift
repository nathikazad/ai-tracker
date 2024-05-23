//
//  File.swift
//  History
//
//  Created by Nathik Azad on 4/8/24.
//

import SwiftUI
import Combine

enum ShowInPopup {
    case text
    case date
    case none
}

// Define your custom views for each tab
struct InteractionsView: View {
    @State private var showPopupForId: Int?
    @State private var showInPopup: ShowInPopup = .none
    @State private var draftContent = ""
    @State private var selectedTime: Date = Date()
    @State private var scrollProxy: ScrollViewProxy?
    @State private var coreStateSubcription: AnyCancellable?
    @State private var interactions: [InteractionModel] = []

    

    
    var body: some View {
        VStack {
            
            CalendarButton()
            
            Group {
                if interactions.isEmpty {
                    VStack {
                        Spacer()
                        Text("No Events Yet")
                            .foregroundColor(.primary)
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
                if(Authentication.shared.areJwtSet) {
                    listenToInteractions()
                    coreStateSubcription?.cancel()
                    coreStateSubcription = AppState.shared.subscribeToCoreStateChanges {
                        print("Core state occurred")
                        listenToInteractions()
                    }
                    
                }
            }
            .onDisappear {
                print("Timelineview has disappeared")
                InteractionsController.cancelListener()
                coreStateSubcription?.cancel()
                coreStateSubcription = nil
            }
        }
        .overlay(
            popupView
        )
    }
    
    private func listenToInteractions() {
        InteractionsController.listenToInteractions(userId: Authentication.shared.userId!) { interactions in
            DispatchQueue.main.async {
                self.interactions = interactions
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack {
            Spacer()
            Text("No Events Yet")
                .foregroundColor(.primary)
                .font(.title2)
            Text("Record your first event by clicking the microphone below and saying what you did.")
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Spacer()
        }
    }
    
    private var listView: some View {
        ScrollViewReader { proxy in
            VStack {
                List {
                    ForEach(interactions.indices, id: \.self) { index in
                        let interaction = interactions[index]
                        HStack {
                            Text(interaction.timestamp.formattedTime)
                                .font(.headline)
                                .frame(width: 100, alignment: .leading)
                                .onTapGesture {
                                    selectedTime = interaction.timestamp
                                    showPopupForId = interaction.id
                                    showInPopup = .date
                                }
                            Divider()
                            
                            if let location = interaction.location {
                                NavigationLink(destination: LocationDetailView(location: location)) {
                                    Text(interaction.content)
                                        .font(.subheadline)
                                }
                            } else {
                                NavigationLink(destination: interactionLink(interaction: interaction)) {
                                    VStack {
                                        Text("\(interaction.content) ")
                                            .font(.subheadline)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        HStack {
                                            ForEach(interaction.eventTypes, id: \.self) { eventType in
                                                Text(eventType.capitalized)
                                                    .font(.subheadline)
                                                    .padding(5)
                                                    .background(Color.black)
                                                    .foregroundColor(.white)
                                                    .cornerRadius(5)
                                            }
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                            }
                        }
                        .id(interaction.id)
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button(action: {
                                print("Tapped right on \(interaction.id)")
                                // TODO: start microphone with parameters
                            }) {
                                Image(systemName: "mic.fill")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    .onDelete { indices in
                        indices.forEach { index in
                            let interactionId = interactions[index].id
                            InteractionsController.deleteInteraction(id: interactionId)
                        }
                    }
                }
                .padding(.vertical, 0)
                .onAppear {
                    scrollProxy = proxy
                }
                .onChange(of: interactions) { _ in
                    if state.currentDate == Calendar.current.startOfDay(for: Date())
                    {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                            if let lastId = interactions.last?.id {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    scrollProxy?.scrollTo(lastId, anchor: .top)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func interactionLink(interaction: InteractionModel) -> some View {
//        if interaction.eventTypes.contains(where: { $0 == "sleeping" }) {
//            return AnyView(SleepView())
//        } else {
            return AnyView(InteractionView(interaction: interaction.id))
//        }
    }
    
    
    private var popupView: some View {
        Group {
            if showPopupForId != nil {
                VStack {
                    if(showInPopup == .text) {
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
                    } else if (showInPopup == .date) {
                        DatePicker("Select Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(WheelDatePickerStyle())
                            .frame(maxHeight: 150)
                    }
                    
                    Button(action: {
                        DispatchQueue.main.async {
                            if(showInPopup == .text) {
                                InteractionsController.editInteraction(id: showPopupForId!, fieldName: "content", fieldValue: draftContent)
                            } else if (showInPopup == .date) {
                                InteractionsController.editInteraction(id: showPopupForId!, fieldName: "timestamp", fieldValue: selectedTime.toUTCString)
                            }
                            self.showInPopup = .none
                            self.showPopupForId = nil
                        }
                    }) {
                        Text("Save")
                            .foregroundColor(.primary)
                    }
                    .padding(.top, 5)
                }
                .padding()
                .background(Color("OppositeColor"))
                .cornerRadius(10)
                .shadow(radius: 5)
                .frame(width: 300)
                .overlay(
                    Button(action: {
                        showPopupForId = nil
                        showInPopup = .none
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
    InteractionsView()
}
