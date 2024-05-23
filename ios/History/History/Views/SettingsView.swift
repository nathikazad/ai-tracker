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
    @State private var isTrackingSleep = HealthKitManager.shared.isTracking
    @State private var currentUserName: String
    
    init() {
        _isTrackingLocation = State(initialValue: LocationManager.shared.isTrackingLocation)
        _currentUserName = State(initialValue: getName())
    }
    
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Settings")) {
                    NavigationLink(destination: LocationsListView()) {
                        Label("Places", systemImage: "mappin.and.ellipse")
                            .foregroundColor(.primary)
                    };
                    Button(action: changeUserId) {
                        Label("Change User \(currentUserName)", systemImage: "person.2.fill")
                            .foregroundColor(.primary)
                    }
                    
                    NavigationLink(destination: LocationsDebugView()) {
                        Label("Debug Locations \(LocationManager.shared.locationsReceivedCount) \(LocationManager.shared.locationsSentCount)  [\(LocationManager.shared.sentToServerCount)]", systemImage: "mappin.and.ellipse")
                            .foregroundColor(.primary)
                    };
                    
                    
                    
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
                    
                    Toggle(isOn: $isTrackingSleep) {
                        Label("Track Sleep", systemImage: "moon.zzz.fill")
                    }
                    .foregroundColor(.primary)
                    .onChange(of: isTrackingSleep) { value in
                        print("onChange \(value)")
                        if value {
                            print("change sleep to start")
                            healthManager.startTracking()
                        } else {
                            print("Stop Sleep Tracking")
                            healthManager.stopTracking()
                        }
                    }
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
        state.notifyCoreStateChanged()
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

