//
//  SquadChatV.swift
//  History
//
//  Created by Nathik Azad on 8/19/24.
//

import SwiftUI

struct SquadView: View {
    let squadName: String
    let squadId: Int
    @ObservedObject var squad: SquadModel
    @State private var newSquadMessage = ""
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            SquadMessagesTab(squad: squad,
                             newSquadMessage: $newSquadMessage)
                .tabItem {
                    Label("Messages", systemImage: "message")
                }
                .tag(0)
            
            SquadGoalsView()
                .tabItem {
                    Label("Goals", systemImage: "target")
                }
                .tag(1)
            
            SettingsTab()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(2)
        }
        .navigationTitle(squadName)
        .onAppear {
            fetchSquad()
            SquadMessagesController.listenToMessages(subscriptionId: "squad/\(squadId)", squadId: squadId)
            { newMessages in
                DispatchQueue.main.async {
                    squad.ingestNewMessages(newMessages: newMessages)
                }
            }
        }
        .onDisappear {
            Hasura.shared.stopListening(subscriptionId: "squad/\(squadId)")
        }
    }
    private func fetchSquad() {
        Task {
            if let squad = await SquadController.fetchSquads(squadId: squadId, includeMessages: true).first {
                DispatchQueue.main.async {
                    print(squad.messages.count)
                    self.squad.copy(squad)
                }
            }
        }
    }
}




