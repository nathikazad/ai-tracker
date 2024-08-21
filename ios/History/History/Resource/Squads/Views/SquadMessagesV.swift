//
//  SquadMessagesV.swift
//  History
//
//  Created by Nathik Azad on 8/20/24.
//

import SwiftUI
struct SquadMessagesTab: View {
    @ObservedObject var squad: SquadModel
    @State private var newSquadMessage = ""
    @FocusState private var isTextFieldFocused: Bool
    @State private var lastContentOffset: CGFloat = 0
    @State private var lastUpdateTime = Date()
    @State private var maxOffset: CGFloat = 0
    @State private var fetchingMoreMessages: Bool = false
    @State private var lastMessageId: Int = 0
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 10) {
                        ForEach(Array(sortedMessages.enumerated()), id: \.element.id) { index, message in
                            let user = squad.userOfMessage(message.id) ?? SquadUserModel(id: 0, name: "Unknown")
                            let showUserName = shouldShowUserName(for: index)
                            SquadMessageBubble(message: message, user: user, showUserName: showUserName)
                                .id(message.id)
                        }
                    }
                    .padding()
                    GeometryReader { innerGeometry in
                        Color.clear
                            .preference(key: ViewOffsetKey.self, value: innerGeometry.frame(in: .global).minY)
                    }
                }
                .onPreferenceChange(ViewOffsetKey.self) { currentOffset in
                    if abs(lastContentOffset - currentOffset) > 5 && Date().timeIntervalSince(lastUpdateTime) > 5 {
                        if(isTextFieldFocused) {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                isTextFieldFocused = false
                            }
                        }
                    }
                    
                    if !fetchingMoreMessages && currentOffset > lastContentOffset && currentOffset > (maxOffset * 9)/10 {
                        fetchMessages()
                        fetchingMoreMessages = true
                    }
                    lastContentOffset = currentOffset
                    maxOffset = max(currentOffset, maxOffset)
                }
                .onChange(of: sortedMessages.count) {
                    if lastMessageId != sortedMessages.last?.id {
//                        if lastContentOffset < (isTextFieldFocused ? 600 : 800) {
                            withAnimation {
                                proxy.scrollTo(sortedMessages.last?.id, anchor: .bottom)
                            }
//                        }
                    }
                    if let lastId = sortedMessages.last?.id {
                        lastMessageId = lastId
                    }
                }
                .onChange(of: isTextFieldFocused) { old, new in
                    print("focus \(new)")
                    if new {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            withAnimation {
                                proxy.scrollTo(sortedMessages.last?.id, anchor: .bottom)
                            }
                        }
                    }
                    lastUpdateTime = Date()
                }
            }
            
            HStack {
                TextField("Type a message...", text: $newSquadMessage)
                    .focused($isTextFieldFocused)
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
    
    private func fetchMessages() {
        Task {
            let messages = await SquadMessagesController.fetchMesssages(squadId: squad.id, offset: squad.messages.count)
            DispatchQueue.main.async {
                self.squad.ingestNewMessages(newMessages: messages)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    fetchingMoreMessages = false
                }
            }
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
        lastUpdateTime = Date()
        return squad.messages.values.sorted { $0.time < $1.time }
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
                    .foregroundColor(isCurrentUser ? .white : .primary)
                    .cornerRadius(10)
            }
            if !isCurrentUser { Spacer() }
        }
    }
    
    var isCurrentUser: Bool {
        user.id == auth.userId
    }
}
