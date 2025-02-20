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

enum TimelineType: String, CaseIterable {
    case candle = "Candle"
    case list = "List"
}

enum Tab {
    case history, goals, squads, explorer
}

struct MainView: View {
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @State private var selectedTab: Tab = .history
    @ObservedObject var appState = state
    @ObservedObject private var timerManager = TimerManager.shared
    @State private var selectedExplorerType: ExplorerType = .actions
    @State private var selectedTimelineType: TimelineType = .list
    @StateObject private var datePickerModel: TwoDatePickerModel = TwoDatePickerModel()
    @State var enteringTimelineDayTab: Bool = true
    // Usage    
    enum ExplorerType: String, CaseIterable {
        case actions = "Verbs"
        case objects = "Nouns"
    }
    
    
    
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
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    NavigationBar(
                        selectedTab: $selectedTab,
                        selectedTimelineType: $selectedTimelineType
                    )  {
                        if selectedTab == Tab.explorer {
                            HStack {
                                Text("Explorer")
                                    .font(.title)
                                    .foregroundColor(.primary)
                                    .padding(.horizontal, 10)
                                Spacer()
                            }
                        } else if selectedTab == Tab.squads {
                            HStack {
                                Text("Squads")
                                    .font(.title)
                                    .foregroundColor(.primary)
                                    .padding(.horizontal, 10)
                                Spacer()
                            }
                        } else {
                            TimeNavigator()
                        }
                    }
                    
                    if selectedTab == Tab.explorer {
                        Picker("", selection: $selectedExplorerType) {
                            ForEach(ExplorerType.allCases, id: \.self) { viewType in
                                Text(viewType.rawValue).tag(viewType)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding()
                        Divider()
                    }
                    
                    TabView(selection: $selectedTab) {
                        if selectedTimelineType == .candle {
                            CandleChartWithList()
                                .tabItem { Label("History", systemImage: "clock.arrow.circlepath") }
                                .tag(Tab.history)
                        } else {
                            ActionsTabView(datePickerModel: datePickerModel, cameFromAnotherTab: $enteringTimelineDayTab)
                                .tabItem { Label("Timeline", systemImage: "clock.arrow.circlepath") }
                                .tag(Tab.history)
                        }
                        GoalsTabView()
                            .tabItem { Label("Goals", systemImage: "target") }
                            .tag(Tab.goals)
                        
                        Color.clear
                            .tabItem { Label("", systemImage: "plus.circle") }
                            .tag(Tab.history) // Use an existing tag to prevent selection
                        
                        SquadsTabView()
                            .tabItem { Label("Squads", systemImage: "person.3.fill") }
                            .tag(Tab.squads)
                        
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
                    .onChange(of: selectedTab) {
                        old, new in
                        if new == .history {
                            enteringTimelineDayTab = true
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
                    .overlay(popupView)
                }
                AddNewActionButton(verticalSizeClass: verticalSizeClass)
                    .offset(x: verticalSizeClass == .compact ? -15 : 0)
            }
        }
        .alert(isPresented: $timerManager.showCompletionAlert) {
            Alert(title: Text("Timer Completed"), message: Text("Your timer has finished!"), dismissButton: .default(Text("OK")))
        }
    }
    
    private var popupView: some View {
        Group {
            if datePickerModel.showPopupForId != nil {
                TwoDatePickerView(datePickerModel: datePickerModel)
            }
        }
    }
}

#Preview {
    ContentView()
}




