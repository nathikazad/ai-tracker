//
//  SquadChatV.swift
//  History
//
//  Created by Nathik Azad on 8/19/24.
//

import SwiftUI

struct SquadChatView: View {
    let squadName: String
    let squadId: Int
    @ObservedObject var squad: SquadModel
    @State private var newSquadMessage = ""
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            SquadMessagesTab(squad: squad, newSquadMessage: $newSquadMessage)
                .tabItem {
                    Label("Messages", systemImage: "message")
                }
                .tag(0)
            
            MediaTab()
                .tabItem {
                    Label("Graphs", systemImage: "photo")
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
            SquadMessagesController.listenToMessages(subscriptionId: "squad/\(squadId)", groupId: squadId)
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

struct SquadMessagesTab: View {
    @ObservedObject var squad: SquadModel
    @Binding var newSquadMessage: String
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 10) {
                    ForEach(Array(sortedMessages.enumerated()), id: \.element.id) { index, message in
                        let user = squad.userOfMessage(message.id) ?? SquadUserModel(id: 0, name: "Unknown")
                        let showUserName = shouldShowUserName(for: index)
                        SquadMessageBubble(message: message, user: user, showUserName: showUserName)
                    }
                }
                .padding()
            }
            
            HStack {
                TextField("Type a message...", text: $newSquadMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Button(action: sendSquadMessage) {
                    Text("Send")
                }
                .padding(.trailing)
            }
            .padding(.bottom)
        }
    }
    
    private func sendSquadMessage() {
        guard !newSquadMessage.isEmpty else { return }
        if let memberId = squad.memberIdOfUser(auth.userId!) {
            let payload = ["message": newSquadMessage]
            Task {
                let _ = await SquadMessagesController.sendMessage(
                    groupId: squad.id,
                    memberId: memberId,
                    payload: payload)
            }
        }
        newSquadMessage = ""
    }
    
    private var sortedMessages: [MessageModel] {
        squad.messages.values.sorted { $0.time < $1.time }
    }
    
    private func shouldShowUserName(for index: Int) -> Bool {
        guard index > 0 else { return true }
        let currentMessage = sortedMessages[index]
        let previousMessage = sortedMessages[index - 1]
        let currentUser = squad.userOfMessage(currentMessage.id)
        let previousUser = squad.userOfMessage(previousMessage.id)
        return currentUser?.id != previousUser?.id
    }
}

struct SquadMessageBubble: View {
    let message: MessageModel
    let user: SquadUserModel
    let showUserName: Bool
    
    var body: some View {
        HStack {
            if isCurrentUser { Spacer() }
            VStack(alignment: isCurrentUser ? .trailing : .leading) {
                if showUserName {
                    Text("\(user.name)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Text(message.payload.message)
                    .padding(10)
                    .background(isCurrentUser ? Color(red: 222/255, green: 152/255, blue: 64/255) : Color.gray.opacity(0.2))
                    .foregroundColor(isCurrentUser ? .white : .black)
                    .cornerRadius(10)
            }
            if !isCurrentUser { Spacer() }
        }
    }
    
    var isCurrentUser: Bool {
        user.id == auth.userId
    }
}

struct MediaTab: View {
    var body: some View {
        Text("Media content goes here")
            .font(.largeTitle)
    }
}

struct SettingsTab: View {
    var body: some View {
        List {
            Section(header: Text("Notifications")) {
                Toggle("Enable Notifications", isOn: .constant(true))
                Toggle("Sound", isOn: .constant(true))
                Toggle("Vibration", isOn: .constant(true))
            }
            
            Section(header: Text("Privacy")) {
                Toggle("Read Receipts", isOn: .constant(true))
                Toggle("Last Seen", isOn: .constant(false))
            }
            
            Section(header: Text("Chat")) {
                Picker("Theme", selection: .constant(0)) {
                    Text("Light").tag(0)
                    Text("Dark").tag(1)
                    Text("System").tag(2)
                }
                Picker("Font Size", selection: .constant(1)) {
                    Text("Small").tag(0)
                    Text("Medium").tag(1)
                    Text("Large").tag(2)
                }
            }
        }
    }
}


