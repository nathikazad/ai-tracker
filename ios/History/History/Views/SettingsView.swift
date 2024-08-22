//
//  SettingsView.swift
//  History
//
//  Created by Nathik Azad on 4/9/24.
//
import SwiftUI


struct SettingsView: View {
    @State private var showingDeleteConfirmation = false
    @State var notificationsOn: Bool = false

    
    var originalUserId: Int? {
        if let originalJwt = auth.hasuraJwt, let currentUserId = auth.hasuraJWTObject?.userId {
            let originalUser =  HasuraJWTObject(jwt: originalJwt)
            return originalUser.userId
        }
        return nil
    }
    
    private func checkNotificationSettings() {
        APNSTokenManager.shared.getNotificationSettings { isAuthorized in
            if auth.user?.deviceToken != nil {
                DispatchQueue.main.async {
                    notificationsOn = isAuthorized
                }
            }
        }
    }
    
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Settings")) {
                    if originalUserId == 1 {
                        NavigationLink(destination: SwitchUsersV()){
                            Text("Switch User")
                        }
                    }
                    
                    Toggle("Notifications", isOn: $notificationsOn)
                    .onChange(of: notificationsOn) { old, new in
                        if new {
                            APNSTokenManager.shared.registerForPushNotifications()
                        } else {
                            APNSTokenManager.shared.unregisterForPushNotifications()
                        }
                    }
                    .alignmentGuide(.listRowSeparatorLeading) { _ in
                        -20
                    }
                    
                    NavigationLink(destination: InteractionsView()) {
                        Label {
                            Text("Memos")
                                .foregroundColor(.primary)
                        } icon: {
                            Image(systemName: "mic")
                        }
                        .alignmentGuide(.listRowSeparatorLeading) { _ in
                            -20
                        }
                    }
                    Button(action: {
                        showingDeleteConfirmation = true
                    }) {
                        Label {
                            Text("Delete Your Account")
                                .foregroundColor(.primary)
                        } icon: {
                            Image(systemName: "trash.fill")
                                .foregroundColor(.red)
                        }
                        .alignmentGuide(.listRowSeparatorLeading) { _ in
                            -20
                        }
                    }
                    
                    Button(action: {
                        auth.signOutCallback()
                        state.hideSheet()
                        state.showChat(newChatViewToShow: .onBoard)
                    }) {
                        Label("Logout", systemImage: "arrow.right.square.fill")
                            .foregroundColor(.primary)
                    }
                }
            }
            .alert("Confirm Deletion", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    Task {
                        await deleteUser()
                        auth.signOutCallback()
                        state.hideSheet()
                        state.showChat(newChatViewToShow: .onBoard)
                    }
                }
            } message: {
                Text("Are you sure you want to delete your account? This action cannot be undone.")
            }
            .onAppear {
                checkNotificationSettings()
            }
        }
    }
}

private func deleteUser() async {
    let deleteUserEndpoint = getDeleteUserEndpoint
    let body: [String: Any] = ["userId": auth.userId!]
    do {
        guard let data = try await ServerCommunicator.sendPostRequestAsync(to: deleteUserEndpoint, body: body, token: Authentication.shared.hasuraJwt!, waitAndSendIfServerUnreachable: false) else {
            print("Failed to receive data")
            return
        }
        if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let jwt = jsonResponse["jwt"] as? String {
            print("User deleted")
        } else {
            print("Invalid response received from the server")
        }
    } catch {
        print("Error deleting user: \(error)")
    }
}

