//
//  SwitchUsers.swift
//  History
//
//  Created by Nathik Azad on 8/21/24.
//

import SwiftUI
struct SwitchUsersV: View {
    @State private var users: [AdminUserController.UserModel] = []
    @State private var searchText = ""
    @Environment(\.presentationMode) var presentationMode

    
    var body: some View {
        List {
            TextField("Search Users...", text: $searchText)
                .padding(7)
                .cornerRadius(8)
                .padding(2)
                .alignmentGuide(.listRowSeparatorLeading) { _ in
                    -20
                }
            
            ForEach(filteredUsers, id: \.id) { user in
                Button(action: {
                    auth.hasuraJWTObject?.userId = user.id
                    state.notifyCoreStateChanged()
                    goBack()
                }) {
                    Text(user.name)
                }
                .alignmentGuide(.listRowSeparatorLeading) { _ in
                    -20
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(action: {
                        Task {
                            let _ = await AdminUserController.deleteUser(id: user.id)
                            fetchObjects()
                        }
                    }) {
                        Image(systemName: "trash.fill")
                    }
                    .tint(.red)
                }
                
            }
        }
        .navigationBarTitle(Text("Select user"), displayMode: .inline)
        .onAppear(perform: fetchObjects)
    }
    
    private func fetchObjects() {
        Task {
            let userId = Authentication.shared.userId!
            let fetchedUsers = await AdminUserController.fetchUsers()
            DispatchQueue.main.async {
                users = fetchedUsers
            }
        }
    }
    
    private var filteredUsers: [AdminUserController.UserModel] {
        if searchText.isEmpty {
            return users.sorted { $0.name < $1.name }
        } else {
            return users.filter { $0.name.lowercased().contains(searchText.lowercased()) }
                .sorted { $0.name < $1.name }
        }
    }
    
    private func goBack() {
        presentationMode.wrappedValue.dismiss()
    }
}
