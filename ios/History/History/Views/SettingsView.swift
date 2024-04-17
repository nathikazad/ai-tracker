//
//  SettingsView.swift
//  History
//
//  Created by Nathik Azad on 4/9/24.
//
import SwiftUI

struct SettingsView: View {
    private var locationManager = LocationManager.shared
    @State private var isTrackingLocation = LocationManager.shared.isTrackingLocation
    @State private var currentUserName: String
    
    init() {
        _isTrackingLocation = State(initialValue: LocationManager.shared.isTrackingLocation)
        _currentUserName = State(initialValue: getName())
    }
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Settings")) {
                    //                    NavigationLink(destination: PlacesView()) {
                    //                        Label("Places", systemImage: "mappin.and.ellipse")
                    //                            .foregroundColor(.black)
                    //                    }
                    //                    NavigationLink(destination: Text("People View")) { // Replace with actual view when ready
                    //                        Label("People", systemImage: "person.2.fill")
                    //                            .foregroundColor(.black)
                    //                    }
                    //                    NavigationLink(destination: Text("Recipes View")) { // Replace with actual view when ready
                    //                        Label("Recipes", systemImage: "book.fill")
                    //                            .foregroundColor(.black)
                    //                    }
//                    if(Authentication.shared.isAdmin){
                        Button(action: changeUserId) {
                            Label("Change User \(currentUserName)", systemImage: "person.2.fill")
                                .foregroundColor(.black)
                        }
                        
                        Toggle(isOn: $isTrackingLocation) {
                            Label("Track Location", systemImage: "location.fill")
                        }
                        .foregroundColor(.black)
                        .onChange(of: isTrackingLocation) { value in
                            print("onChange \(value)")
                            if value {
                                print("change to start")
                                locationManager.startMonitoringLocation()
                            } else {
                                print("change to stop")
                                locationManager.stopMonitoringLocation()
                            }
                        }
//                    }
                    Button(action: {
                        Authentication.shared.signOutCallback()
                        AppState.shared.hideSheet()
                        AppState.shared.showChat(newChatViewToShow: .onBoard)
                    }) {
                        Label("Logout", systemImage: "arrow.right.square.fill")
                            .foregroundColor(.black)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
    
    func changeUserId() {
        let originalUser =  HasuraJWTObject(jwt: Authentication.shared.hasuraJwt!)
        guard var currentUserId = Authentication.shared.hasuraJWTObject?.userId else { return }
        
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
        
        Authentication.shared.hasuraJWTObject?.userId = currentUserId
        print("User switched to \(currentUserId)")
        self.currentUserName = getName()
    }
}

func getName() -> String {
    guard var currentUserId = Authentication.shared.hasuraJWTObject?.userId else { return "Unknown"}
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


struct PlacesView: View {
    var body: some View {
        Text("This is the Places View")
        // Build your Places View content here
    }
}

