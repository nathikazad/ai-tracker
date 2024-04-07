//
//  ChatView.swift
//  History
//
//  Created by Nathik Azad on 4/5/24.
//

import SwiftUI
import AuthenticationServices

class ChatViewModel: ObservableObject {
    @Published var messages = [Message]()
    @Published var mockData = [
        Message(userUid: "12345", text: "The quick fox jumps over the lazy dog", photoURL: "", createdAt: Date()),
        Message(userUid: "12345", text: "The quick fox jumps over the lazy dog", photoURL: "", createdAt: Date()),
        Message(userUid: "12345", text: "The quick fox jumps over the lazy dog", photoURL: "", createdAt: Date()),
        Message(userUid: "12345", text: "The quick fox jumps over the lazy dog", photoURL: "", createdAt: Date()),
        Message(userUid: "12345", text: "The quick fox jumps over the lazy dog", photoURL: "", createdAt: Date())
    ]
}

struct ChatView: View {
    @StateObject var contentViewModel: ContentViewModel
    @StateObject var chatViewModel = ChatViewModel()
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 8) {
                            ForEach(chatViewModel.mockData) {
                                message in MessageView(message: message)
                            }
                            SignInWithAppleButton(.signIn) { request in
                                request.requestedScopes = [.fullName]
                            } onCompletion: {
                                result in 
                                Task {
                                    await handleSignIn(result: result) { isSuccess in
                                        if isSuccess {
                                            DispatchQueue.main.async {
                                                self.contentViewModel.showChat = false
                                            }
                                        }
                                    }
                                }
                            }
                            // black button
                            .signInWithAppleButtonStyle(.black)
                            // white button
                            .signInWithAppleButtonStyle(.white)
                            // white with border
                            .signInWithAppleButtonStyle(.whiteOutline)
                        }
                    }
                    SendMessageBar()
                }
            }
            .navigationTitle("Chatroom")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}


struct ChatView_Previews : PreviewProvider {
    static var previews: some View {
        ChatView(contentViewModel: ContentViewModel())
    }
}

struct SendMessageBar: View {
    @State var text = ""
    var body: some View {
        HStack {
            TextField("Hello there", text: $text, axis: .vertical)
                .padding()
            Button {
                if(text.count > 2) {
                    // execute
                }
                text = ""
            } label: {
                Text("Send")
                    .padding()
                    .foregroundColor(.white)
                    .background(.cyan)
                    .cornerRadius(50)
                    .padding(.trailing)
            }
        }.background(Color(uiColor: .systemGray6))
    }
}
