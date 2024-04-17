import Foundation
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    
    let locationManager = CLLocationManager()
    
    private let locationUpdateDistanceFilter: CLLocationDistance = 50 // meters
    private let movementDistanceThreshold: CLLocationDistance = 100 // meters
    private let movementCheckInterval: TimeInterval = 300 // seconds
    
    var movementLocations: [(location: CLLocation, time: Date)] = []
    var lastStationaryLocation: CLLocation?
    var movementCheckTimer: Timer?
    
    enum UserState {
        case stationary
        case moving
    }
    
    @Published var isTrackingLocation = false
    var currentState: UserState = .moving
    
    override init() {
        super.init()
        print("location init")
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = locationUpdateDistanceFilter
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        initializeTrackingState()
    }
    
    private func initializeTrackingState() {
        print("initalize tracking")
        let status = locationManager.authorizationStatus
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            print("initalize tracking true")
            isTrackingLocation = true
            locationManager.startUpdatingLocation()
        default:
            print("initalize tracking false")
            isTrackingLocation = false
        }
    }
    
    
    func stopMonitoringLocation() {
        print("stop monitoring")
        locationManager.stopUpdatingLocation()
        isTrackingLocation = false
    }
    
    func startMonitoringLocation() {
        print("start monitoring")
        DispatchQueue.main.async {
            if CLLocationManager.locationServicesEnabled() {
                self.locationManager.requestAlwaysAuthorization()
            }
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization(manager: manager)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization(manager: manager)
    }
    
    private func checkLocationAuthorization(manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            if CLLocationManager.locationServicesEnabled() {
                manager.startUpdatingLocation()
                isTrackingLocation = true
            }
        case .notDetermined, .restricted, .denied:
            print("Location authorization denied or restricted.")
            isTrackingLocation = false
        @unknown default:
            isTrackingLocation = false
            fatalError("Unhandled authorization status")
        }
    }
    
    fileprivate func checkMovement(_ location: CLLocation) {
        if(!movementLocations.isEmpty) {
            print("Distance since last movement \(location.distance(from: movementLocations.last!.location))")
        }
        
        if movementLocations.isEmpty {
            print("Appending location because empty")
            movementLocations.append((location: location, time: Date()))
        } else if (location.distance(from: movementLocations.last!.location) > movementDistanceThreshold + location.horizontalAccuracy + movementLocations.last!.location.horizontalAccuracy) {
            print("Appending location because past threshold")
            movementLocations.append((location: location, time: Date()))
        }
        
        
        let timeSinceLastUpdate = Date().timeIntervalSince(movementLocations.last!.time)
        if timeSinceLastUpdate > movementCheckInterval {
            print("stopped moving because user hasn't moved far in \(movementCheckInterval) seconds")
            stoppedMoving()
        } else {
            let remainingTimeInterval = movementCheckInterval - timeSinceLastUpdate
            print("starting timer for remaining \(remainingTimeInterval) seconds in case another location update doesn't come due to user being in same location")
            movementCheckTimer?.invalidate()  // Ensure no previous timer is running
            movementCheckTimer = Timer.scheduledTimer(timeInterval: remainingTimeInterval, target: self, selector: #selector(stoppedMoving), userInfo: nil, repeats: false)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        print("\(currentState), New location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        if(lastStationaryLocation == nil) {
            lastStationaryLocation = location
        }
        
        movementCheckTimer?.invalidate()
        switch currentState {
        case .moving:
            checkMovement(location)
        case .stationary:
            if let lastStationaryLocation = lastStationaryLocation {
                let distance = location.distance(from: lastStationaryLocation)
                print("Distance from last stationary location: \(distance)")
                if distance > movementDistanceThreshold + location.horizontalAccuracy + lastStationaryLocation.horizontalAccuracy {
                    startedMoving(debugInfo: [
                        "distanceChange": distance,
                        "threshold": movementDistanceThreshold,
                        "oldLocation": [
                            "lat": lastStationaryLocation.coordinate.latitude,
                            "lng": lastStationaryLocation.coordinate.longitude,
                            "accuracy": lastStationaryLocation.horizontalAccuracy
                        ],
                        "newLocation": [
                            "lat": location.coordinate.latitude,
                            "lng": location.coordinate.longitude,
                            "accuracy": location.horizontalAccuracy
                        ],
                    ])
                } else {
                    print("Not enough distance to consider moving")
                }
            }
        }
    }
    
    func startedMoving(debugInfo: [String: Any] = [:]) {
        print("User started moving.")
        currentState = .moving
        notifyServer(debugInfo: debugInfo)
        movementLocations = []
    }
    
    @objc func stoppedMoving() {
        print("User has stopped moving for more than \(movementCheckInterval) seconds.")
        currentState = .stationary
        notifyServer(debugInfo: [
            "numberOfPoints": movementLocations.count,
            "timeSinceLastMovement": Date().timeIntervalSince(movementLocations.last!.time)
        ])
        lastStationaryLocation = movementLocations.last!.location
    }
    
    
    func notifyServer(debugInfo: [String: Any] = [:]) {
        let locationsData: [[String: Double]]
        if currentState == .stationary {
            locationsData = movementLocations.map {
                ["lat": $0.location.coordinate.latitude, "lon": $0.location.coordinate.longitude]
            }
        } else {
            if let firstLocation = movementLocations.last?.location {
                locationsData = [["lat": firstLocation.coordinate.latitude, "lon": firstLocation.coordinate.longitude]]
            } else {
                locationsData = []
            }
        }
        sendToServer(eventName: currentState == .stationary ? "stoppedMoving" : "startedMoving", locationsData: locationsData)
        print("Notifying server...")
    }
    
    private func sendToServer(eventName: String, locationsData: [[String: Double]], debugInfo: [String: Any] = [:]) {
        var body: [String: Any] = ["eventName": eventName, "locations": locationsData, "debugInfo": debugInfo]
        let bodyCopy = body // Make an immutable copy for the send to server task
        Task {
            do {
                guard let data = try await ServerCommunicator.sendPostRequest(to: updateMovementEndpoint, body: bodyCopy, token: Authentication.shared.hasuraJwt) else {
                    print("Failed to receive data or no data returned")
                    return
                }
                if let json = try? JSONSerialization.jsonObject(with: data, options: []),
                   let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
                   let jsonString = String(data: jsonData, encoding: .utf8) {
                    print("Received JSON: \(jsonString)")
                } else {
                    print("Failed to decode JSON data")
                }
            } catch {
                print("Error sending data to server or parsing server response: \(error.localizedDescription)")
            }
        }
    }
}
