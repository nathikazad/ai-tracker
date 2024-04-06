//
//  ContentView.swift
//  History
//
//  Created by Nathik Azad on 3/17/24.
//

import SwiftUI

class ContentViewModel: ObservableObject {
    @Published var notSignedIn: Bool = User.shared.hasuraJwt == nil
}

struct ContentView: View {
    @StateObject var contentViewModel = ContentViewModel()
    var mySocket = HasuraSocket(didEnterBackgroundNotification: UIApplication.didEnterBackgroundNotification, willEnterForegroundNotification: UIApplication.willEnterForegroundNotification)
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
                    } label: {
                        Text("Signout")
                            .foregroundColor(.red)
                    }
                }
            }
            .onAppear(perform: {
//                let subscriptionQuery = """
//                    subscription { interactions(order_by: {timestamp: desc}, limit: 5) { timestamp id}}
//                """
//                _ = mySocket.startListening(subscriptionQuery: subscriptionQuery) { message in
//                    print("Received new interaction: \(message)")
//                    // Here you can parse the message and update your UI or application state accordingly
//                }
                
                Task {
                    await someAsyncFunction()
                }
                
            })
        }
        .fullScreenCover(isPresented: $contentViewModel.notSignedIn) {
            ChatView(contentViewModel: contentViewModel)
        }
    }
    
}

func someAsyncFunction() async {
    var jwtToken = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpYXQiOjE3MTIzNTM2OTcsImh0dHBzOi8vaGFzdXJhLmlvL2p3dC9jbGFpbXMiOnsieC1oYXN1cmEtZGVmYXVsdC1yb2xlIjoidXNlciIsIngtaGFzdXJhLWFsbG93ZWQtcm9sZXMiOlsidXNlciJdLCJ4LWhhc3VyYS11c2VyLWlkIjoiMSJ9LCJleHAiOjM0MjQ3OTM3OTR9.bPhZj6hLPmpxf_r0Sp43_dD5hTZ8ecYdqu_r_SKHF8Gokn1q8XOQ5VwNkvHBPyVGCpE69nTucz2nl_QlliFb3Bfq7QapYb7BqOHUcdoSH_PtkK5Ec0t78mitiIL6-F7N9Xg6vD8OA6mdvQoh8AHr-hRTLHw6CjlohU92UiiFJbyrJX1czieWnMEW_STkYGbQ98nsrpeajPBvnV4AgIEqMlfSvbRha3zJaVWDlijgUg7Yp1UhnVBELqMY2oIgICg0Swv2MmWsK7ZpYPol1xGSlRu3pokZ1mPshXwK-aKn_4zXar7Kt5inI9z6LIMd6q0-83YuezAPXq9FsmFjRg0wlw"
    let graphqlQuery = "query MyQuery { interactions(where: {user_id: {_eq: 1}}, limit: 10) { id timestamp } }"

    do {
        let data = try await fetchGraphQLData(jwtToken: jwtToken, graphqlQuery: graphqlQuery)
        
        // Process the returned data
        if let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            print("Response: \(jsonResult)")
        }
    } catch {
        print("Error: \(error.localizedDescription)")
    }
}
    

#Preview {
    ContentView(contentViewModel: ContentViewModel())
}
