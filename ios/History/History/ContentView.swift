//
//  ContentView.swift
//  History
//
//  Created by Nathik Azad on 3/17/24.
//

import SwiftUI

class AppState: ObservableObject {
    static let shared = AppState()
    @Published var chatViewToShow: ChatViewToShow = .none
}
enum ChatViewToShow {
    case none, onBoard, normal
}

struct ContentView: View {
    @ObservedObject var appState = AppState.shared
    var chatViewPresented: Binding<Bool> {
            Binding(
                get: { self.appState.chatViewToShow != .none },
                set: { isPresented in
                    self.appState.chatViewToShow = isPresented ? .normal : .none
                }
            )
        }
    var body: some View {
        Group {
            if appState.chatViewToShow == ChatViewToShow.none {
                MainView()
            }
        }
        .fullScreenCover(isPresented: chatViewPresented) {
            ChatView()
        }
        .onAppear {
            DispatchQueue.main.async {
                if(!Authentication.shared.areJwtSet) {
                    self.appState.chatViewToShow = .onBoard
                }
            }
            registerBackroundNotifiers()
        }
    }
    
    func registerBackroundNotifiers() {
        Hasura.shared.setBackgroundNotifiers(didEnterBackgroundNotification: UIApplication.didEnterBackgroundNotification, willEnterForegroundNotification: UIApplication.willEnterForegroundNotification)
    }
}


struct MainView: View {
    @State private var showingSettings = false
    @State private var selectedTab: Tab = .todos
    @ObservedObject var appState = AppState.shared
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                // TabView for managing your tabs
                TabView(selection: $selectedTab) {
                    TodosView()
                        .tabItem {
                            Image(systemName: "checklist")
                            Text("Todos")
                        }
                        .tag(Tab.todos)
                    
                    TimelineView()
                        .tabItem {
                            Image(systemName: "clock")
                            Text("Timeline")
                        }
                        .tag(Tab.timeline)
                    
                    // Placeholder for the center button
                    Text("")
                        .tabItem {
                            Image(systemName: "mic.fill") // Just a placeholder to keep the layout consistent
                        }
                    
                    GoalsView()
                        .tabItem {
                            Image(systemName: "target")
                            Text("Goals")
                        }
                        .tag(Tab.goals)
                    
                    GraphsView()
                        .tabItem {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                            Text("Graphs")
                        }
                        .tag(Tab.graphs)
                }
                .navigationTitle(titleForTab(selectedTab))
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showingSettings = true
                        }) {
                            Image(systemName: "line.horizontal.3")
                                .foregroundColor(.black)
                        }
                    }
                }
                .sheet(isPresented: $showingSettings) {
                    SettingsView()
                }

                // Positioned the MicrophoneButton on top of the TabView
                MicrophoneButton()
               
            }
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
        case .graphs:
            return "Graphs"
            
        }
    }
    
    enum Tab {
        case todos
        case timeline
        case goals
        case graphs
    }
}



#Preview {
    ContentView()
}



//
//NavigationStack {
//    ZStack {
//        VStack {
//            // Toggle Button for Expandable Widget
//            DailyRemindersView()
//            InteractionsView()
//            BottomBar()
//        }
//    }
//    .navigationTitle("Observe and Improve")
//    .navigationBarTitleDisplayMode(.inline)
//    .toolbar {
//        ToolbarItem(placement: .navigationBarTrailing) {
//            Button {
//                Authentication.shared.signOut()
//                contentViewModel.showChat = true
//            } label: {
//                Text("Signout")
//                    .foregroundColor(.red)
//            }
//        }
//    }
//    .onAppear(perform: {
//
//        HasuraSocket.shared.setup()
//    })
//}
//.fullScreenCover(isPresented: $contentViewModel.showChat) {
//    ChatView(contentViewModel: contentViewModel)
//}


