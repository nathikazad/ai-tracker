//
//  ChatView.swift
//  History
//
//  Created by Nathik Azad on 4/5/24.
//

import SwiftUI
import AuthenticationServices
import Combine

enum Sender {
    case Maximus, User
}

struct ViewOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct IdentifiableView: Identifiable, Hashable, Equatable {
    static func == (lhs: IdentifiableView, rhs: IdentifiableView) -> Bool {
        return lhs.id == rhs.id
    }
    
    let id: Int
    let view: AnyView
    
    init<Content: View>(id: Int, _ view: Content) {
        self.id = id
        self.view = AnyView(view)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct Message: Identifiable {
    let id: Int
    let sender: Sender
    let content: String
    let timestamp: String
    
    var isUser: Bool {
        return sender == .User
    }
}

class ChatViewModel: ObservableObject {
    @Published var chatContents: [IdentifiableView] = []
    @Published var isSignedIn: Bool = false
    @ObservedObject var appState = AppState.shared
    @Published var currentMessage: String = ""
    @Published var investorMessageCount: Int = 0
    
    let closeCallback: () -> Void
        
    init(closeCallback: @escaping () -> Void) {
        self.closeCallback = closeCallback
        setupInitialChatContents()
    }
    
    private func setupInitialChatContents() {
        chatContents = []
        if (appState.chatViewToShow == .onBoard) {
            addInitialContentsForOnboard()
        } else if (appState.chatViewToShow == .investor) {
            addComputerMessage(message: "Hey Nathik, how can I help you today?")
        } else {
            addInitialContentsForNormal()
        }
    }
    
    private func addInitialContentsForOnboard() {
        addComputerMessage(message: "Hi my name is Maximus, I'm an AI agent built with the singular purpose to help you reach your goals. Sign in by clicking the button below and we will get started.")
        
        addChatContent(view:SignInWithAppleButton(.signIn, onRequest: { request in
            request.requestedScopes = [.fullName]
        }, onCompletion: { result in
            Task {
                await self.localHandleSignIn(result: result)
            }
        })
            .frame(width: 200)
            .disabled(isSignedIn)
        )
    }
    
    private func addInitialContentsForNormal() {
        addComputerMessage(message: "Hi, what would you like to record?")
    }
    
    private func addComputerMessage(message: String) {
        addMessage(message: message, sender: .Maximus)
    }
    
    func addMessage(message: String, sender: Sender) {
        let newMessage = Message(id: chatContents.count, sender: sender, content: message, timestamp: "\(Date())")
        addChatContent(view: ChatMessageRow(message: newMessage))
    }
    
    @MainActor
    private func localHandleSignIn(result: Result<ASAuthorization, Error>) async {
        let isSuccess = await handleSignIn(result: result)
        if isSuccess {
            isSignedIn = true
            addLoginConfirmationMessage()
        }
    }
    
    @MainActor
    private func addLoginConfirmationMessage() {
        addComputerMessage(message: "Great, you are logged in now. You can click on the microphone and talk to me.")
        addOkButton()
    }
    
    func addOkButton() {
        let okButton = Button(action: {
            self.closeCallback()
        }) {
            Text("Ok")
                .foregroundColor(Color("OppositeColor"))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.primary)
                .cornerRadius(8)
        }
        addChatContent(view: okButton)
    }
    
    func sendUserMessage(_ message: String, scrollToUserMessage: (Int) -> Void) {
        
        print("ChatViewModel: sendUserMessage \(message)")
//        if(appState.chatViewToShow == .normal) {
            addMessage(message: message, sender: .User)
            Task {
                do {
                    var body = ["text": message]
                    if let parentEventId = state.parentEventId {
                        body["parentEventId"] = String(parentEventId)
                    }
                    try await ServerCommunicator.sendPostRequestAsync(to: parseTextEndpoint, body: body, token: Authentication.shared.hasuraJwt!, stackOnUnreachable: false)
                    addComputerMessage(message: "Your message has been recorded")
                    addOkButton()
                } catch {
                    print("Server communication error")
                }
            }
//        } else if (appState.chatViewToShow == .investor) {
//            let scrollTo = chatContents.last!.id
//            addInvestorMessage()
//            scrollToUserMessage(scrollTo + 2)
//        }
    }
    
    func addChatContent<V: View>(view: V) {
        let newChatMessageView = IdentifiableView(id: chatContents.count, AnyView(view))
        self.chatContents.append(newChatMessageView)
    }
}

struct ChatView: View {
    
    @StateObject var chatViewModel:ChatViewModel
    @ObservedObject var appState = AppState.shared
    @State private var showKeyboard: Bool = false
    @State private var lastContentOffset: CGFloat = 0
    @State private var lastUpdateTime = Date()
    @State private var scrollToId: Int?  // State to determine which item to scroll to
    
    
    let closeCallback: () -> Void
    init(closeCallback: @escaping () -> Void) {
        self.closeCallback = closeCallback
        _chatViewModel = StateObject(wrappedValue: ChatViewModel(closeCallback: closeCallback))
    }

    
    var body: some View {
        NavigationView {
            VStack {
                ScrollViewReader { scrollView in
                    ScrollView(showsIndicators: false) {
                        ForEach(chatViewModel.chatContents) { content in
                            content.view
                                .id(content.id)
                        }
                        GeometryReader { innerGeometry in
                            Color.clear
                                .preference(key: ViewOffsetKey.self, value: innerGeometry.frame(in: .global).minY)
                        }
                    }
                    .onPreferenceChange(ViewOffsetKey.self) { value in
                        if abs(lastContentOffset - value) > 5 && Date().timeIntervalSince(lastUpdateTime) > 0.5 {
                            if(showKeyboard) {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    showKeyboard = false
                                }
                            }
                        }
                        lastContentOffset = value
                    }
                    .onChange(of: scrollToId) { newValue, oldValue in
                        withAnimation {
                            scrollView.scrollTo(newValue, anchor: .bottom)
                        }
                    }
                }
                .padding()
                // .defaultScrollAnchor(.bottom)
                SendBar(currentMessage: $chatViewModel.currentMessage, showKeyboard: $showKeyboard) { message in
                    chatViewModel.sendUserMessage(message) {
                        id in
                        scrollToId = id
                        showKeyboard = false
                    }
                    lastUpdateTime = Date()
                }
            }
            .navigationBarTitle("Maximus", displayMode: .inline)
            .navigationBarItems(
                leading: appState.chatViewToShow != .onBoard ? Button(action: {
                    self.closeCallback()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.primary)
                } : nil  // No button when not in normal chat view
            )
        }
    }
}

struct ChatMessageRow: View {
    var message: Message
    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            if message.isUser {
                Spacer()
                VStack(alignment: .trailing) {
                    Text(message.content)
                        .padding()
                        .background(Color.primary)
                        .foregroundColor(Color("OppositeColor"))
                        .cornerRadius(15)
                }
            } else {
                VStack(alignment: .leading) {
                    Text(message.content)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(Color.primary)
                        .cornerRadius(15)
                }
                Spacer()
            }
        }
        //        .padding(.top)
        .padding(.horizontal)
        //        .padding(.bottom)
    }
}
