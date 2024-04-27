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
    private var locationManager = LocationManager.shared
    private var healthManager = HealthKitManager.shared
    @State private var isTrackingLocation = LocationManager.shared.isTrackingLocation
    @State private var isTrackingSleep = HealthKitManager.shared.authorized
    @State private var currentUserName: String
    
    init() {
        _isTrackingLocation = State(initialValue: LocationManager.shared.isTrackingLocation)
        _currentUserName = State(initialValue: getName())
    }
    
    fileprivate func changeSleeptracking(_ value: Bool) {
        if value {
            print("change sleep to start")
            healthManager.requestAuthorization {  authorized, error in
                
                if let error = error {
                    print("Authorization failed with error: \(error.localizedDescription)")
                    return
                }
                DispatchQueue.main.async {
                    self.isTrackingSleep = authorized
                }
                if authorized {
                    print("HealthKit authorization granted.")
                } else {
                    print("HealthKit authorization denied.")
                }
            }
        } else {
            print("change to stop")
            locationManager.stopMonitoringLocation()
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Settings")) {
                    NavigationLink(destination: LocationsListView()) {
                        Label("Places", systemImage: "mappin.and.ellipse")
                            .foregroundColor(.primary)
                    };
                    if(Authentication.shared.isAdmin){
                        NavigationLink(destination: LocationsDebugView()) {
                            Label("Debug Places", systemImage: "mappin.and.ellipse")
                                .foregroundColor(.primary)
                        }
                    }
                    //                    NavigationLink(destination: Text("People View")) { // Replace with actual view when ready
                    //                        Label("People", systemImage: "person.2.fill")
                    //                            .foregroundColor(.primary)
                    //                    }
                    //                    NavigationLink(destination: Text("Recipes View")) { // Replace with actual view when ready
                    //                        Label("Recipes", systemImage: "book.fill")
                    //                            .foregroundColor(.primary)
                    //                    }
                    Button(action: changeUserId) {
                        Label("Change User \(currentUserName)", systemImage: "person.2.fill")
                            .foregroundColor(.primary)
                    }
                    
                    Toggle(isOn: $isTrackingLocation) {
                        Label("Track Location", systemImage: "location.fill")
                    }
                    .foregroundColor(.primary)
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
                    
//                    NavigationLink(destination: SleepView()) {
                        Toggle(isOn: $isTrackingSleep) {
                            Label("Track Sleep", systemImage: "moon.zzz.fill")
                        }
                        .foregroundColor(.primary)
                        .onChange(of: isTrackingSleep) { value in
                            print("onChange \(value)")
                            changeSleeptracking(value)
                        }
//                    }
                    
                    Button(action: {
                        healthManager.uploadSleepData()
                    }) {
                        Text("Upload Sleep Data")
                    }
                    //                    }
                    Button(action: {
                        Authentication.shared.signOutCallback()
                        AppState.shared.hideSheet()
                        AppState.shared.showChat(newChatViewToShow: .onBoard)
                    }) {
                        Label("Logout", systemImage: "arrow.right.square.fill")
                            .foregroundColor(.primary)
                    }
                }
            }
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

