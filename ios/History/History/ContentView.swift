//
//  ContentView.swift
//  History
//
//  Created by Nathik Azad on 3/17/24.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var appState = state
    var chatViewPresented: Binding<Bool> {
        Binding(
            get: {
                return self.appState.chatViewToShow != .none
            },
            set: { isPresented in
            }
        )
    }
    var body: some View {
        Group {
            if appState.chatViewToShow == AppState.ChatViewToShow.none {
                MainView()
            }
        }
        .fullScreenCover(isPresented: chatViewPresented) {
            LandingPageView()
        }
        .onAppear {
            DispatchQueue.main.async {
                if(!auth.areJwtSet) {
                    self.appState.showChat(newChatViewToShow:.onBoard)
                }
            }
        }
    }
    
}


enum SelectedTimeline: String, CodingKey {
    case list
    case bars
}

struct MainView: View {
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @State private var selectedTab: Tab = .timeline
    @ObservedObject var appState = state
    @ObservedObject private var timerManager = TimerManager.shared
    @State private var selectedExplorerType: ExplorerType = .actions
    
    var sheetViewPresented: Binding<Bool> {
        Binding(
            get: { self.appState.sheetViewToShow != .none },
            set: { isPresented in
                if(isPresented) {
                    self.appState.showSheet(newSheetToShow: .settings)
                } else {
                    self.appState.showSheet(newSheetToShow: .none)
                }
            }
        )
    }
    
    enum ExplorerType: String, CaseIterable {
        case actions = "Actions"
        case objects = "Objects"
    }
    
    var body: some View {
        NavigationStack {
            if selectedTab == Tab.explorer {
                Picker("", selection: $selectedExplorerType) {
                    ForEach(ExplorerType.allCases, id: \.self) { viewType in
                        Text(viewType.rawValue).tag(viewType)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
            }
            ZStack(alignment: .bottom) {

                TabView(selection: $selectedTab) {
                    CandleChartWithList()
                        .tabItem { Label("History", systemImage: "clock.arrow.circlepath") }
                        .tag(Tab.history)
                    
                    ActionsTabView()
                        .tabItem { Label("Timeline", systemImage: "list.dash") }
                        .tag(Tab.timeline)
                    
                    Color.clear
                        .tabItem {
                            Image(systemName: "plus.circle")
                        }
                        .tag(Tab.timeline) // Use an existing tag to prevent selection
                    
                    AggregatesTabView()
                        .tabItem { Label("Goals", systemImage: "target") }
                        .tag(Tab.goals)
                    if selectedExplorerType == .actions {
                        ListActionsTypesView()
                            .tabItem { Label("Explorer", systemImage: "globe") }
                            .tag(Tab.explorer)
                    } else {
                         ObjectTypeListView(listType: .takeToObjects)
                            .tabItem { Label("Explorer", systemImage: "globe") }
                            .tag(Tab.explorer)
                    }
                }
                let buttonSize: CGFloat = verticalSizeClass == .compact ? 40 : 60
                
                    NavigationLink(destination: ListActionsTypesView(
                        listActionType: .takeToActionView
                    )) {
                            ZStack {
                                // Gradient background
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 178/255, green: 72/255, blue: 49/255),
                                        Color(red: 222/255, green: 152/255, blue: 64/255)
                                    ]),
                                    startPoint: .topTrailing,
                                    endPoint: .bottomLeading
                                )
                                .clipShape(Circle())
                                
                                // Plus icon
                                Image(systemName: "plus")
                                    .resizable()
                                    .scaledToFit()
                                    .padding(buttonSize * 0.3)
                                    .foregroundColor(.white)
                            }
                            .frame(width: buttonSize, height: buttonSize)
                            .shadow(radius: 4)
                        }
                .offset(y: verticalSizeClass == .compact ? -15 : -30)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        NavigationTitle(title: titleForTab(selectedTab)) {
                            appState.showSheet(newSheetToShow: .dailyQuotes)
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            appState.showSheet(newSheetToShow: .settings)
                        }) {
                            Image(systemName: "gear").foregroundColor(.primary)
                        }
                    }
                }
                .sheet(isPresented: sheetViewPresented) {
                    if appState.sheetViewToShow == .settings {
                        SettingsView()
                    } else if appState.sheetViewToShow == .dailyQuotes {
                        RemindersView()
                    } else if appState.sheetViewToShow == .calendar {
                        CalendarPickerView { selectedDate in
                            appState.goToDay(newDay: selectedDate)
                            appState.hideSheet()
                        }
                    }
                }
//                MicrophoneButton()
            }
            .edgesIgnoringSafeArea(.bottom)
        }
        .alert(isPresented: $timerManager.showCompletionAlert) {
            Alert(title: Text("Timer Completed"), message: Text("Your timer has finished!"), dismissButton: .default(Text("OK")))
        }
    }
    
    private func titleForTab(_ tab: Tab) -> String {
        switch tab {
        case .timeline:
            return "Timeline"
        case .history:
            return "History"
        case .goals:
            return "Goals"
        case .explorer:
            return "Explorer"
        }
    }
    
    enum Tab {
        case timeline
        case history
        case goals
        case explorer
    }
}



#Preview {
    ContentView()
}




