//
//  ContentView.swift
//  History
//
//  Created by Nathik Azad on 3/17/24.
//

import SwiftUI

class ContentViewModel: ObservableObject {
    @Published var notSignedInAlready: Bool = User.shared.getJWT == nil
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
                        User.shared.clearJWT()
                        contentViewModel.notSignedInAlready = true
                    } label: {
                        Text("Signout")
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $contentViewModel.notSignedInAlready) {
            ChatView(contentViewModel: contentViewModel)
        }
    }
}
    

#Preview {
    ContentView(contentViewModel: ContentViewModel())
}
