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

struct IdentifiableView: Identifiable {
    let id: Int
    let view: AnyView
    
    init<Content: View>(id: Int, _ view: Content) {
        self.id = id
        self.view = AnyView(view)
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
        let welcomeMessage =
            ChatMessageRow(message: Message(id: 0, sender: .Maximus, content: "Hi my name is Maximus, I'm an AI agent built with the singular purpose to help you reach your goals. Sign in by clicking the button below and we will get started.", timestamp: "\(Date())"))
        
        let signInButton = SignInWithAppleButton(.signIn, onRequest: { request in
                request.requestedScopes = [.fullName]
            }, onCompletion: { result in
                Task {
                    await self.localHandleSignIn(result: result)
                }
            })
            .frame(width: 200)
            .disabled(isSignedIn)
        
        
        
        let normalMessage = ChatMessageRow(message: Message(id: 0, sender: .Maximus, content: "Hi, what would you like to record?", timestamp: "Yesterday 8:30 PM"))
        
        

        if (appState.chatViewToShow == .onBoard) {
            addChatContent(view: welcomeMessage)
            addChatContent(view: signInButton)
        } else {
            addChatContent(view: normalMessage)
        }
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
        let newMessage = Message(id: chatContents.count, sender: .Maximus, content: "Great, you are logged in now. You can click on the microphone and talk to me.", timestamp: "\(Date())")
        let successSignInMessage = ChatMessageRow(message: newMessage)
        
        
        addChatContent(view: successSignInMessage)
        addOkButton()
    }
    
    func addMessage(content: String, sender: Sender) {
        let newMessage = Message(id: chatContents.count, sender: sender, content: content, timestamp: "\(Date())")
        addChatContent(view: ChatMessageRow(message: newMessage))
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
    
    func sendMessage(_ message: String) {
        addMessage(content: message, sender: .User)
        Task {
            do {
                let response = try await ServerCommunicator.sendPostRequest(to: parseTextEndpoint, body: ["text": message], token: Authentication.shared.hasuraJwt!)
                addMessage(content: "Your message has been recorded", sender: .Maximus)
                addOkButton()
            } catch {
                print("Server communication error")
            }
        }
    }
    
    func addChatContent<V: View>(view: V) {
        let newChatMessageView = IdentifiableView(id: chatContents.count, AnyView(view))
//        DispatchQueue.main.async {
            self.chatContents.append(newChatMessageView)
//        }
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
                if(appState.chatViewToShow == .normal) {
                    SendBar(currentMessage: $chatViewModel.currentMessage, chatViewModel: chatViewModel)
                    
                }
            }
            .navigationBarTitle("Maximus", displayMode: .inline)
            .navigationBarItems(
                leading: appState.chatViewToShow == .normal ? Button(action: {
                    self.appState.showChat(newChatViewToShow:.none)
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.primary)
                } : nil  // No button when not in normal chat view
            )
        }
    }
}

struct SendButton: View {
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            Text("Send")
                .foregroundColor(Color("OppositeColor"))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.primary)
                .cornerRadius(8)
        }
    }
}

struct SendBar: View {
    @Binding var currentMessage: String
    var chatViewModel: ChatViewModel  // Pass ViewModel to SendBar
    @State var isRecording: Bool = false
    @FocusState private var isTextFieldFocused: Bool
    
    private func getLineLimit(for text: String) -> Int {
        let lineCount = text.components(separatedBy: "\n").count
        let newLength = (text.count / 28) + lineCount
        return max(1, min(5, newLength))
    }
    
    var body: some View {
        HStack {
            TextField("Message", text: $currentMessage, axis: .vertical)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .focused($isTextFieldFocused)
                .lineLimit(getLineLimit(for: currentMessage), reservesSpace: true)
            Button(action: {
                // Toggle recording state
                self.isRecording.toggle()
                isTextFieldFocused = false
                // Here, add the functionality to start/stop recording
            }) {
                Image(systemName: isRecording ? "stop.fill" : "mic.fill") // Change icon based on recording state
                    .foregroundColor(Color("OppositeColor"))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 8)
                    .background(Color.primary)
                    .cornerRadius(8)
            }
            .padding(.trailing, 0)
            .padding(.leading, 0)
            
            SendButton {
                if !currentMessage.isEmpty {
                    chatViewModel.sendMessage(currentMessage)
                    currentMessage = ""
                }
            }
            .disabled(isRecording || currentMessage.isEmpty)
        }
        .padding(.bottom, 10)
        .padding(.horizontal, 20)
    }
    
}


#Preview {
    ChatView()
}

//        IdentifiableView(
//            id: 2,
//            ChatMessageRow(message: Message(id: 1, sender: "ChatGPT", content: "Sure", timestamp: "Yesterday 8:31 PM", isCurrentUser: true))),
//        IdentifiableView(
//            id: 3,
//            ChatMessageRow(message: Message(id: 0, sender: "Sophie", content: "Ok sign in by clicking the button below and I will set everything up.", timestamp: "Yesterday 8:30 PM", isCurrentUser: false))),

//class ChatViewModel: ObservableObject {
//
//
//    @Published var messages = [Message]()
//    @Published var mockData = [
//        Message(userUid: "12345", text: "The quick fox jumps over the lazy dog", photoURL: "", createdAt: Date()),
//        Message(userUid: "12345", text: "The quick fox jumps over the lazy dog", photoURL: "", createdAt: Date()),
//        Message(userUid: "12345", text: "The quick fox jumps over the lazy dog", photoURL: "", createdAt: Date()),
//        Message(userUid: "12345", text: "The quick fox jumps over the lazy dog", photoURL: "", createdAt: Date()),
//        Message(userUid: "12345", text: "The quick fox jumps over the lazy dog", photoURL: "", createdAt: Date())
//    ]
//}
//
//struct ChatView: View {
//    @StateObject var chatViewModel = ChatViewModel()
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                VStack {
//                    ScrollView(showsIndicators: false) {
//                        VStack(spacing: 8) {
//                            ForEach(chatViewModel.mockData) {
//                                message in MessageView(message: message)
//                            }
//                            SignInWithAppleButton(.signIn) { request in
//                                request.requestedScopes = [.fullName]
//                            } onCompletion: {
//                                result in
//                                Task {
//                                    var  isSuccess = await handleSignIn(result: result)
//                                    if isSuccess {
//                                        Authentication.shared.signInCallback()
//                                        AppState.shared.shouldShowMainView = true
//                                    }
//                                }
//                            }
//                            // black button
////                            .signInWithAppleButtonStyle(.primary)
////                            // white button
////                            .signInWithAppleButtonStyle(.white)
//                            // white with border
//                            .signInWithAppleButtonStyle(.whiteOutline)
//                        }
//                    }
//                    SendMessageBar()
//                }
//            }
//            .navigationTitle("Chatroom")
//            .navigationBarTitleDisplayMode(.inline)
//        }
//    }
//}
//
//
//struct ChatView_Previews : PreviewProvider {
//    static var previews: some View {
//        ChatView()
//    }
//}
//
//struct SendMessageBar: View {
//    @State var text = ""
//    var body: some View {
//        HStack {
//            TextField("Hello there", text: $text, axis: .vertical)
//                .padding()
//            Button {
//                if(text.count > 2) {
//                    // execute
//                }
//                text = ""
//            } label: {
//                Text("Send")
//                    .padding()
//                    .foregroundColor(.white)
//                    .background(.cyan)
//                    .cornerRadius(50)
//                    .padding(.trailing)
//            }
//        }.background(Color(uiColor: .systemGray6))
//    }
//}

