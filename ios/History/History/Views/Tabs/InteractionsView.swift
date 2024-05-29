//
//  File.swift
//  History
//
//  Created by Nathik Azad on 4/8/24.
//

import SwiftUI
import Combine



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
                if(auth.areJwtSet) {
                    listenToInteractions()
                    coreStateSubcription?.cancel()
                    coreStateSubcription = state.subscribeToCoreStateChanges {
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
    
    func closePopup() {
        showPopupForId = nil
        showInPopup = .none
        draftContent = ""
    }
    
    private var popupView: some View {
        Group {
            if(showInPopup == .modifyDate) {
                PopupViewForDate(selectedTime: $selectedTime,
                saveAction: {
                    DispatchQueue.main.async {
                        InteractionsController.editInteraction(id: showPopupForId!, fieldName: "timestamp", fieldValue: selectedTime.toUTCString)
                        closePopup()
                    }
                }, closeAction: closePopup)
            } else if showInPopup == .modifyText {
                PopupViewForText(draftContent: $draftContent,
                 saveAction: {
                     DispatchQueue.main.async {
                         InteractionsController.editInteraction(id: showPopupForId!, fieldName: "content", fieldValue: draftContent)
                         closePopup()
                     }
                 }, closeAction: closePopup)
            }
        }
    }
    
    private func listenToInteractions() {
        InteractionsController.listenToInteractions(userId: auth.userId!) { interactions in
            DispatchQueue.main.async {
                self.interactions = []
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
                                    showInPopup = .modifyDate
                                }
                            Divider()
                            
                            if let location = interaction.location {
                                NavigationLink(destination: LocationDetailView(location: location)) {
                                    Text(interaction.content)
                                        .font(.subheadline)
                                }
                            } else {
                                VStack {
                                    Text(interaction.content)
                                        .font(.subheadline)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .onTapGesture {
                                            draftContent = interaction.content
                                            showPopupForId = interaction.id
                                            showInPopup = .modifyText
                                        }
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
                                
//                                NavigationLink(destination: interactionLink(interaction: interaction)) {
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
}

#Preview {
    InteractionsView()
}
