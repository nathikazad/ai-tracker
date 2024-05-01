//
//  File.swift
//  History
//
//  Created by Nathik Azad on 4/8/24.
//

import SwiftUI

enum ShowInPopup {
    case text
    case date
    case none
}

// Define your custom views for each tab
struct TimelineView: View {
    @StateObject var interactionController = InteractionsController()
    @State private var showPopupForId: Int?
    @State private var showInPopup: ShowInPopup = .none
    @State private var draftContent = ""
    @State private var selectedTime: Date = Date()
    @State private var isShowingDatePicker = false
    @State private var scrollProxy: ScrollViewProxy?
    func showCalendarPicker() {
        isShowingDatePicker = true
    }
    
    var body: some View {
        VStack {
            Button(action: {
                showCalendarPicker()
            }) {
                Text(interactionController.formattedDate)
                    .foregroundColor(.primary)
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
            }
            
            
            Group {
                if interactionController.interactions.isEmpty {
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
        .sheet(isPresented: $isShowingDatePicker) {
            CalendarPickerView { selectedDate in
                interactionController.goToDay(newDay: selectedDate)
                isShowingDatePicker = false
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
                    ForEach(interactionController.interactions.indices, id: \.self) { index in
                        let interaction = interactionController.interactions[index]
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
                                Text(interaction.content)
                                    .font(.subheadline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .onTapGesture {
                                        draftContent = interaction.content
                                        showPopupForId = interaction.id
                                        showInPopup = .text
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
                            let interactionId = interactionController.interactions[index].id
                            interactionController.deleteInteraction(id: interactionId)
                        }
                    }
                }
                .padding(.vertical, 0)
                .onAppear {
                    scrollProxy = proxy
                }
                .onChange(of: interactionController.interactions) { _ in
                    if interactionController.currentDate == Calendar.current.startOfDay(for: Date())
                    {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                            if let lastId = interactionController.interactions.last?.id {
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
                                interactionController.editInteraction(id: showPopupForId!, fieldName: "content", fieldValue: draftContent)
                            } else if (showInPopup == .date) {
                                interactionController.editInteraction(id: showPopupForId!, fieldName: "timestamp", fieldValue: selectedTime.toUTCString)
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
    TimelineView()
}
