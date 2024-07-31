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
            ChatView {
                self.appState.hideChat()
            }
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


struct MainView: View {
    @State private var selectedTab: Tab = .timeline
    @ObservedObject var appState = state
    
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
                TabView(selection: $selectedTab) {
//                    TodosView().tabItem { Label("Todos", systemImage: "checklist") }.tag(Tab.todos)
                    ActionsTabView().tabItem { Label("Timeline", systemImage: "clock") }.tag(Tab.timeline)
//                    GoalsView().tabItem { Label("Goals", systemImage: "target") }.tag(Tab.goals)
                    ListActionsTypesView().tabItem { Label("Explorer", systemImage: "globe") }.tag(Tab.explorer)
//                    GraphsView().tabItem { Label("Graphs", systemImage: "chart.line.uptrend.xyaxis") }.tag(Tab.graphs)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        NavigationTitle(title: titleForTab(selectedTab)) {
                            appState.showSheet(newSheetToShow: .dailyQuotes)
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: ListActionsTypesView(
                            listActionType: .takeToActionView)) {
                            Image(systemName: "plus")
                                .foregroundColor(.primary)
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            appState.showSheet(newSheetToShow: .settings)
                        }) {
                            Image(systemName: "line.horizontal.3").foregroundColor(.primary)
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
    }
    
    private func titleForTab(_ tab: Tab) -> String {
        switch tab {
        case .todos:
            return "Todos"
        case .timeline:
            return "Timeline"
        case .goals:
            return "Goals"
        case .explorer:
            return "Explorer"
        case .graphs:
            return "Graphs"
            
        }
    }
    
    enum Tab {
        case todos
        case timeline
        case goals
        case explorer
        case graphs
    }
}



#Preview {
    ContentView()
}




