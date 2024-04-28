//
//  ChatView.swift
//  History
//
//  Created by Nathik Azad on 4/5/24.
//

import SwiftUI
import AuthenticationServices
import Combine

struct Message: Identifiable {
    let id: Int
    let sender: Sender
    let content: String
    let timestamp: String
    
    var isUser: Bool {
        return sender == .User
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

// Create a view for a single chat message
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





enum Sender {
    case Maximus, User
}

class ChatViewModel: ObservableObject {
    @Published var chatContents: [IdentifiableView] = []
    @Published var isSignedIn: Bool = false
    @ObservedObject var appState = AppState.shared
    @Published var currentMessage: String = ""
    
    init() {
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
            AppState.shared.showChat(newChatViewToShow:.none)
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
    
    func sendUserMessage(_ message: String) {
        addMessage(message: message, sender: .User)
        if(appState.chatViewToShow == .normal) {
            Task {
                do {
                    let response = try await ServerCommunicator.sendPostRequest(to: parseTextEndpoint, body: ["text": message], token: Authentication.shared.hasuraJwt!)
                    addComputerMessage(message: "Your message has been recorded")
                    addOkButton()
                } catch {
                    print("Server communication error")
                }
            }
        } else if (appState.chatViewToShow == .investor) {
            addInvestorMessage()
        }
    }
    
    func addInvestorMessage() {
        switch chatContents.count {
        case 4:
            addMessage(message: "33", sender: .Maximus)
            addChatContent(view: BarView(title: "Bar Chart", data: [("A", 1), ("B", 2), ("C", 3), ("D", 4), ("E", 5)]));
        default:
            addChatContent(view: CandleView())
            addMessage(message: "\(chatContents.count)", sender: .Maximus)
        }
    }
    
    func addChatContent<V: View>(view: V) {
        let newChatMessageView = IdentifiableView(id: chatContents.count, AnyView(view))
        self.chatContents.append(newChatMessageView)
    }
}


struct ChatView: View {
    @StateObject var chatViewModel = ChatViewModel()
    @ObservedObject var appState = AppState.shared
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                
                    ForEach(chatViewModel.chatContents) { content in
                        content.view
                    }
                  
                }
                .padding()
                .defaultScrollAnchor(.bottom)
                SendBar(currentMessage: $chatViewModel.currentMessage) {
                    message in
                    chatViewModel.sendUserMessage(message)
                    
                }
            }
            .navigationBarTitle("Maximus", displayMode: .inline)
            .navigationBarItems(
                leading: appState.chatViewToShow != .onBoard ? Button(action: {
                    self.appState.showChat(newChatViewToShow:.none)
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.primary)
                } : nil  // No button when not in normal chat view
            )
        }
    }
}




#Preview {
    ChatView()
}
