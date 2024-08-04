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
//    private var locationManager = LocationManager.shared
//    private var healthManager = HealthKitManager.shared
//    @State private var isTrackingLocation = LocationManager.shared.isTrackingLocation
//    @State private var isTrackingSleep = HealthKitManager.shared.isTracking
    @State private var currentUserName: String
    
    init() {
//        _isTrackingLocation = State(initialValue: LocationManager.shared.isTrackingLocation)
        _currentUserName = State(initialValue: getName())
    }
    
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Settings")) {
//                    NavigationLink(destination: LocationsListView()) {
//                        Label("Places", systemImage: "mappin.and.ellipse")
//                            .foregroundColor(.primary)
//                    };
                    Button(action: changeUserId) {
                        Label("Change User \(currentUserName)", systemImage: "person.2.fill")
                            .foregroundColor(.primary)
                    }
                    
//                    NavigationLink(destination: LocationsDebugView()) {
//                        Label("Debug Locations \(LocationManager.shared.locationsReceivedCount) \(LocationManager.shared.locationsSentCount)  [\(LocationManager.shared.sentToServerCount)]", systemImage: "mappin.and.ellipse")
//                            .foregroundColor(.primary)
//                    };
                    
                    
                    
//                    Toggle(isOn: $isTrackingLocation) {
//                        Label("Track Location", systemImage: "location.fill")
//                    }
//                    .foregroundColor(.primary)
//                    .onChange(of: isTrackingLocation) { value in
//                        print("onChange \(value)")
//                        if value {
//                            print("change to start")
//                            locationManager.startMonitoringLocation()
//                        } else {
//                            print("change to stop")
//                            locationManager.stopMonitoringLocation()
//                        }
//                    }
//                    
//                    Toggle(isOn: $isTrackingSleep) {
//                        Label("Track Sleep", systemImage: "moon.zzz.fill")
//                    }
//                    .foregroundColor(.primary)
//                    .onChange(of: isTrackingSleep) { value in
//                        print("onChange \(value)")
//                        if value {
//                            print("change sleep to start")
//                            healthManager.startTracking()
//                        } else {
//                            print("Stop Sleep Tracking")
//                            healthManager.stopTracking()
//                        }
//                    }
                    Button(action: {
                        Task {
                            await deleteUser()
                            auth.signOutCallback()
                            state.hideSheet()
                            state.showChat(newChatViewToShow: .onBoard)
                        }
                    }) {
                        Label("Delete User", systemImage: "trash.fill")
                            .foregroundColor(.primary)
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
    guard let userId = userId else {
        print("No user id")
        return
    }
    let deleteUserEndpoint = getDeleteUserEndpoint
    let body: [String: Any] = ["userId": 5]
    do {
        guard let data = try await ServerCommunicator.sendPostRequestAsync(to: deleteUserEndpoint, body: body, token: nil, waitAndSendIfServerUnreachable: false) else {
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
