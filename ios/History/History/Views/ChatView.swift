//
//  ChatView.swift
//  History
//
//  Created by Nathik Azad on 4/5/24.
//

import SwiftUI
import AuthenticationServices

struct Message: Identifiable {
    let id: Int
    let sender: String
    let content: String
    let timestamp: String
    let isCurrentUser: Bool // to differentiate between sender and receiver
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
            if message.isCurrentUser {
                Spacer()
                VStack(alignment: .trailing) {
                    Text(message.content)
                        .padding()
                        .background(Color.black)
                        .foregroundColor(Color.white)
                        .cornerRadius(15)
                }
            } else {
                VStack(alignment: .leading) {
                    Text(message.content)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(Color.black)
                        .cornerRadius(15)
                }
                Spacer()
            }
        }
        .padding(.top)
        .padding(.horizontal)
        .padding(.bottom)
    }
}

import SwiftUI
import Combine
import AuthenticationServices

class ChatViewModel: ObservableObject {
    @Published var chatContents: [IdentifiableView] = []
    @Published var isSignedIn: Bool = false
    
    init() {
        setupInitialChatContents()
    }

    private func setupInitialChatContents() {
        let welcomeMessage = IdentifiableView(
            id: 1,
            ChatMessageRow(message: Message(id: 0, sender: "Sophie", content: "Hi my name is Maximus, I'm an AI agent built with the singular purpose to help you reach your goals. Sign in by clicking the button below and we will get started.", timestamp: "Yesterday 8:30 PM", isCurrentUser: false))
        )

        let signInButton = IdentifiableView(
            id: 4,
            SignInWithAppleButton(.signIn, onRequest: { request in
                request.requestedScopes = [.fullName]
            }, onCompletion: { result in
                Task {
                    await self.localHandleSignIn(result: result)
                }
            })
            .frame(width: 200)
            .disabled(isSignedIn)
        )
        chatContents = [welcomeMessage, signInButton]
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
        let newMessage = Message(id: chatContents.count, sender: "System", content: "Great, you are logged in now. You can click on the microphone and talk to me.", timestamp: "\(Date())", isCurrentUser: false)
        let successSignInMessage = IdentifiableView(id: chatContents.count + 1, ChatMessageRow(message: newMessage))
        
        let okButton = IdentifiableView(
            id: chatContents.count,
            Button(action: {
                AppState.shared.showChat(newChatViewToShow:.none)
            }) {
                Text("Ok")
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.black)
                    .cornerRadius(8)
            }
        )
        chatContents.append(successSignInMessage)
        chatContents.append(okButton)
        
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
//                SendBar()
                
            }
            .navigationBarTitle("Maximus", displayMode: .inline)
            .navigationBarItems(
                leading: appState.chatViewToShow == .normal ? Button(action: {
                    self.appState.showChat(newChatViewToShow:.none)
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
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
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.black)
                .cornerRadius(8)
        }
    }
}

struct SendBar: View {
    @State var currentMessage: String = ""
    @State var isRecording: Bool = false
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        HStack {
            TextField("Message", text: $currentMessage)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .focused($isTextFieldFocused)
            Button(action: {
                // Toggle recording state
                self.isRecording.toggle()
                isTextFieldFocused = false
                // Here, add the functionality to start/stop recording
            }) {
                Image(systemName: isRecording ? "stop.fill" : "mic.fill") // Change icon based on recording state
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 8)
                    .background(Color.black)
                    .cornerRadius(8)
            }
            .padding(.trailing, 0)
            .padding(.leading, 0)
            
            SendButton {
                AppState.shared.showChat(newChatViewToShow:.none)
            }
            .disabled(isRecording)
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
////                            .signInWithAppleButtonStyle(.black)
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

