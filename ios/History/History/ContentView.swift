//
//  ContentView.swift
//  History
//
//  Created by Nathik Azad on 3/17/24.
//

import SwiftUI
import Combine

var state: AppState {
    return AppState.shared
}

class AppState: ObservableObject, MicrophoneDelegate {
    static let shared = AppState()
    @Published var currentDate = Calendar.current.startOfDay(for: Date())
    @Published private(set) var chatViewToShow: ChatViewToShow = .none
    @Published private(set) var sheetViewToShow: SheetViewToShow = .none
    @Published private(set) var isRecording: Bool = false
    @Published private(set) var isProcessingRecording: Bool = false
    @Published var inForeground = true
    
    private var microphone = Microphone()
    private let coreStatePublisher = PassthroughSubject<Void, Never>()
    
    init() {
        microphone.delegate = self
    }
    
    func microphoneButtonClick() {
        microphone.microphoneButtonClick()
    }
    
    func didStartRecording() {
        print("ViewController is aware: Recording has started")
        isRecording = true
        isProcessingRecording = false
    }

    func didStopRecording(response: String) {
        print("ViewController is aware: Recording has stopped with response \(response)")
        isRecording = false
        isProcessingRecording = false
    }
    
    func didStartProcessingRecording() {
        isProcessingRecording = true
    }

    
    func hideChat() {
        chatViewToShow = .none
    }
    
    func showChat(newChatViewToShow: ChatViewToShow) {
        chatViewToShow = newChatViewToShow
    }
    
    func hideSheet() {
        sheetViewToShow = .none
    }
    
    func showSheet(newSheetToShow: SheetViewToShow) {
        sheetViewToShow = newSheetToShow
    }
    
    func goToNextDay() {
        print("next day")
        currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
        coreStatePublisher.send()
    }
    
    func goToPreviousDay() {
        print("previous day")
        currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate)!
        coreStatePublisher.send()
    }
    
    func goToDay(newDay:Date) {
        currentDate = Calendar.current.startOfDay(for:newDay)
        coreStatePublisher.send()
    }
    
    func notifyCoreStateChanged() {
        coreStatePublisher.send()
    }
    
    func subscribeToCoreStateChanges(_ callback: @escaping () -> Void) -> AnyCancellable {
        return coreStatePublisher
            .sink(receiveValue: callback)
    }
}

enum ChatViewToShow {
    case none, onBoard, normal, investor
}

enum SheetViewToShow {
    case none, settings, dailyQuotes, calendar
}

struct ContentView: View {
    @ObservedObject var appState = AppState.shared
    var chatViewPresented: Binding<Bool> {
        Binding(
            get: { self.appState.chatViewToShow != .none },
            set: { isPresented in
                if(isPresented) {
                    self.appState.showChat(newChatViewToShow: .normal)
                } else {
                    self.appState.showChat(newChatViewToShow: .none)
                }
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
                    self.appState.showChat(newChatViewToShow:.onBoard)
                }
            }
        }
    }
    
}


struct MainView: View {
    @State private var selectedTab: Tab = .timeline
    @ObservedObject var appState = AppState.shared
    
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
        NavigationView {
            ZStack(alignment: .bottom) {
                TabView(selection: $selectedTab) {
                    TodosView().tabItem { Label("Todos", systemImage: "checklist") }.tag(Tab.todos)
                    EventsView().tabItem { Label("Timeline", systemImage: "clock") }.tag(Tab.timeline)
                    Text("").tabItem { Image(systemName: "mic.fill") } // Placeholder
                    GoalsView().tabItem { Label("Goals", systemImage: "target") }.tag(Tab.goals)
                    InteractionsView().tabItem { Label("Interactions", systemImage: "message.badge.waveform.fill") }.tag(Tab.interactions)
//                    GraphsView().tabItem { Label("Graphs", systemImage: "chart.line.uptrend.xyaxis") }.tag(Tab.graphs)
                }
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
                MicrophoneButton()
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
        case .interactions:
            return "Interactions"
        case .graphs:
            return "Graphs"
            
        }
    }
    
    enum Tab {
        case todos
        case timeline
        case goals
        case interactions
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


