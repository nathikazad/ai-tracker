//
//  SquadsTabView.swift
//  History
//
//  Created by Nathik Azad on 8/19/24.
//

import Foundation
import SwiftUI

struct SquadsTabView: View {
    @State private var squads: [SquadModel] = []
    @State private var isShowingCreateSheet = false
    @State private var newSquadName = ""
    @State private var isLoading = false
        
    var body: some View {
        NavigationView {
            List {
                ForEach(squads, id: \.id) { squad in
                    NavigationLink(destination: SquadView(squadName: squad.name, squadId: squad.id, squad: squad)) {
                        Text(squad.name)
                    }
                }
                
                Button(action: {
                    isShowingCreateSheet = true
                }) {
                    Label("Create New Squad", systemImage: "plus.circle")
                }
            }
            .sheet(isPresented: $isShowingCreateSheet) {
                createSquadView
            }
            .onAppear {
                fetchSquads()
            }
        }
    }
    
    private var createSquadView: some View {
        NavigationView {
            Form {
                Section("Create New Squad"){
                    TextField("Squad Name", text: $newSquadName)
                    Button("Create Squad") {
                        createSquad()
                    }
                    .disabled(newSquadName.isEmpty || isLoading)
                }
            }
            .navigationBarItems(trailing: Button("Cancel") {
                isShowingCreateSheet = false
                newSquadName = ""
            })
        }
    }
    
    private func createSquad() {
        isLoading = true
        Task {
            let _ = await SquadController.createSquad(name: newSquadName, ownerId: auth.userId!)
            fetchSquads()
            DispatchQueue.main.async {
                isLoading = false
            }
        }
    }
    
    private func fetchSquads() {
        Task {
            let fetchedGroups = await SquadController.fetchSquads(userId: auth.userId!)
            DispatchQueue.main.async {
                squads = fetchedGroups
            }
        }
    }
}
