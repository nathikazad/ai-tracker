//
//  SettingsView.swift
//  History
//
//  Created by Nathik Azad on 4/9/24.
//
import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Settings")) {
                    NavigationLink(destination: PlacesView()) {
                        Label("Places", systemImage: "mappin.and.ellipse")
                            .foregroundColor(.black)
                    }
                    NavigationLink(destination: Text("People View")) { // Replace with actual view when ready
                        Label("People", systemImage: "person.2.fill")
                            .foregroundColor(.black)
                    }
                    NavigationLink(destination: Text("Recipes View")) { // Replace with actual view when ready
                        Label("Recipes", systemImage: "book.fill")
                            .foregroundColor(.black)
                    }
                    Button(action: {
                        Authentication.shared.signOutCallback()
                        AppState.shared.chatViewToShow = .onBoard
                    }) {
                        Label("Logout", systemImage: "arrow.right.square.fill")
                            .foregroundColor(.black)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct PlacesView: View {
    var body: some View {
        Text("This is the Places View")
        // Build your Places View content here
    }
}

