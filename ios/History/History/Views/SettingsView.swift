//
//  SettingsView.swift
//  History
//
//  Created by Nathik Azad on 4/9/24.
//
import SwiftUI
import CoreLocation
import HealthKit

struct SettingsView: View {
    
    @State private var currentUserName: String
    @State private var showingDeleteConfirmation = false
    
    
    init() {
        _currentUserName = State(initialValue: getName())
    }
    
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Settings")) {
                    if Authentication.shared.userId == 1 {
                        Button(action: changeUserId) {
                            Label("Change User \(currentUserName)", systemImage: "person.2.fill")
                                .foregroundColor(.primary)
                        }
                    }
                    NavigationLink(destination: InteractionsView()) {
                        Label {
                            Text("Memos")
                                .foregroundColor(.primary)
                        } icon: {
                            Image(systemName: "mic")
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
        }
    }
    
    func changeUserId() {
        let originalUser =  HasuraJWTObject(jwt: auth.hasuraJwt!)
        guard var currentUserId = auth.hasuraJWTObject?.userId else { return }
        
        switch currentUserId {
        case 1:
            currentUserId = (originalUser.userId == 4) ? 4 : 3
        case 3:
            currentUserId = (originalUser.userId == 1) ? 4 : 1
        case 4:
            currentUserId = 1
        default:
            currentUserId = 1
        }
        
        auth.hasuraJWTObject?.userId = currentUserId
        print("User switched to \(currentUserId)")
        self.currentUserName = getName()
        state.notifyCoreStateChanged()
    }
}

func getName() -> String {
    guard var currentUserId = auth.hasuraJWTObject?.userId else { return "Unknown"}
    switch currentUserId {
    case 1:
        return "Nathik"
    case 3:
        return "Yareni"
    case 4:
        return "Tito"
    default:
        return "Unknown"
    }
}

private func deleteUser() async {
    let userId = auth.userId
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
