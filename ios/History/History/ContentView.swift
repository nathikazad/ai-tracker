//
//  ContentView.swift
//  History
//
//  Created by Nathik Azad on 3/17/24.
//

import SwiftUI

class ContentViewModel: ObservableObject {
    @Published var showChat: Bool = Authentication.shared.hasuraJwt == nil
}

struct ContentView: View {
    @StateObject var contentViewModel = ContentViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    // Toggle Button for Expandable Widget
                    DailyRemindersView()
                    InteractionsView()
                    BottomBar()
                }
            }
            .navigationTitle("Observe and Improve")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Authentication.shared.signOut()
                        contentViewModel.showChat = true
                    } label: {
                        Text("Signout")
                            .foregroundColor(.red)
                    }
                }
            }
            .onAppear(perform: {
                HasuraSocket.shared.setBackgroundNotifiers(didEnterBackgroundNotification: UIApplication.didEnterBackgroundNotification, willEnterForegroundNotification: UIApplication.willEnterForegroundNotification)
                HasuraSocket.shared.setup()
            })
        }
        .fullScreenCover(isPresented: $contentViewModel.showChat) {
            ChatView(contentViewModel: contentViewModel)
        }
    }
    
}


    

#Preview {
    ContentView(contentViewModel: ContentViewModel())
}
