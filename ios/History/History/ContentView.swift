//
//  ContentView.swift
//  History
//
//  Created by Nathik Azad on 3/17/24.
//

import SwiftUI


struct ContentView: View {
    @State private var shouldShowMainView = false
    var body: some View {
            Group {
                if shouldShowMainView {
                    MainView()
                } else {
                    ChatView()
                }
            }
            .onAppear {
                DispatchQueue.main.async {
                    self.shouldShowMainView = Authentication.shared.isSignedIn()
                }
                registerBackroundNotifiers()
            }
        }
    
    func registerBackroundNotifiers() {
        Hasura.shared.setBackgroundNotifiers(didEnterBackgroundNotification: UIApplication.didEnterBackgroundNotification, willEnterForegroundNotification: UIApplication.willEnterForegroundNotification)
    }
}

struct MainView: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView {
                TodosView()
                    .tabItem {
                        Image(systemName: "checklist")
                        Text("Todos")
                    }
                
                TimelineView()
                    .tabItem {
                        Image(systemName: "clock")
                        Text("Timeline")
                    }
                
                Text("") // Placeholder for the center button
                
                GoalsView()
                    .tabItem {
                        Image(systemName: "target")
                        Text("Goals")
                    }
                
                GraphsView()
                    .tabItem {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                        Text("Graphs")
                    }
            }
            
            MicrophoneButton()
        }
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


