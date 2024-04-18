import Foundation
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    
    let locationManager = CLLocationManager()
    
    private let locationUpdateDistanceFilter: CLLocationDistance = 40 // meters
    private let movementDistanceThreshold: CLLocationDistance = 150 // meters
    private let timeToConsiderStationary: TimeInterval = 300 // seconds
    
    var movementLocations: [CLLocation] = []
    var rejectedLocations: [CLLocation] = []
    var lastStationaryLocation: CLLocation?
    var movementCheckTimer: Timer?
    var waitingForImmediateLocation = false
    
    
    enum UserState {
        case stationary
        case moving
    }
    
    @Published var isTrackingLocation = false
    var currentState: UserState = .moving
    
    override init() {
        super.init()
        print("LocationManager: init")
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = locationUpdateDistanceFilter
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        initializeTrackingState()
    }
    
    private func initializeTrackingState() {
        let status = locationManager.authorizationStatus
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            print("LocationManager: initalize tracking: true")
            isTrackingLocation = true
            locationManager.startUpdatingLocation()
        default:
            print("LocationManager: initalize tracking: false")
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
        Task {
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
            manager.startUpdatingLocation()
            isTrackingLocation = true
        case .notDetermined, .restricted, .denied:
            print("Location authorization denied or restricted.")
            isTrackingLocation = false
        @unknown default:
            isTrackingLocation = false
            fatalError("Unhandled authorization status")
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager Error: \(error)")
        if let clError = error as? CLError {
            switch clError.code {
            case .locationUnknown:
                print("Location data unavailable")
            case .denied:
                print("Location services denied by the user")
            case .network:
                print("Network issues preventing location updates")
            default:
                print("Other CLLocation error")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("LocationManager: LocationManager: receive new location")
        guard let location = locations.last else { return }
        if(waitingForImmediateLocation) {
            print("LocationManager: LocationManager: Immediate location")
            stoppedMoving(previousLocationTime: location.timestamp)
            waitingForImmediateLocation = false
        } else {
            print("LocationManager: LocationManager: Regular OS location")
            updateLocation(location)
        }
    }
    
    func updateLocation(_ location: CLLocation) {
        print("LocationManager: UpdateLocation: \(currentState), New location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
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
                print("LocationManager: UpdateLocation: Distance from last stationary location: \(distance)")
                if distance > movementDistanceThreshold + location.horizontalAccuracy + lastStationaryLocation.horizontalAccuracy {
                    startedMoving(distance: distance, lastLocation: lastStationaryLocation, newLocation: location )
                } else {
                    rejectedLocations.append(location)
                    print("LocationManager: UpdateLocation: Not enough distance to consider moving")
                }
            }
        }
    }
    
    func checkMovement(_ location: CLLocation) {
        print("LocationManager: Check Movement")
        if(!movementLocations.isEmpty) {
            print("LocationManager: Check Movement: Distance since last movement \(location.distance(from: movementLocations.last!))")
            print("LocationManager: Check Movement: Distance since first movement \(location.distance(from: movementLocations.first!))")
        }
        movementCheckTimer?.invalidate()
        var timeToCheckForNoMovement = timeToConsiderStationary
        if movementLocations.isEmpty {
            print("LocationManager: Check Movement: First movement check")
            movementLocations.append(location)
        } else if (location.distance(from: movementLocations.last!) > movementDistanceThreshold + location.horizontalAccuracy + movementLocations.last!.horizontalAccuracy) {
            print("LocationManager: Check Movement: Appending location because past threshold")
            movementLocations.append(location)
        } else {
            print("LocationManager: Check Movement: Did not append location because below threshold")
            print("LocationManager: Check Movement: Checking if elapsed time since last movement is greater than timeToConsiderStationary")
            // you got a new location but it wasn't above movement threshold
            // then you check if elapsed time was greated than timeToConsiderStationary
            // if yes then you call stop moving
            // otherwise you start the timer for a reduced time
            let elapsedTime = Date().timeIntervalSince(location.timestamp)
            if elapsedTime > timeToConsiderStationary {
                print("LocationManager: Check Movement: Stopped moving because the user hasn't moved far in \(timeToConsiderStationary) seconds")
                stoppedMoving(previousLocationTime: location.timestamp)
                return;
            } else {
                print("LocationManager: Check Movement: Not greater than stationary so going to reduce the timer time")
                timeToCheckForNoMovement = timeToConsiderStationary - elapsedTime
            }
        }
        
        print("LocationManager: Check Movement: Starting timer for \(timeToConsiderStationary) seconds in case another location update doesn't come due to the user being in the same location")
        movementCheckTimer = Timer.scheduledTimer(timeInterval: timeToConsiderStationary, target: self, selector: #selector(requestLocation), userInfo: nil, repeats: false)
    }
    
    @objc private func requestLocation() {
        lastStationaryLocation = movementLocations.last!
        print("LocationManager: RequestLocation")
        locationManager.stopUpdatingLocation()
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
        waitingForImmediateLocation = true
    }
    
    
    
    func startedMoving(distance: Double, lastLocation: CLLocation, newLocation: CLLocation) {
        print("LocationManager: StartedMoving")
        currentState = .moving
        sendToServer(body: [
            "eventType": "startedMoving",
            "distanceChange": distance,
            "threshold": movementDistanceThreshold,
            "oldLocation": lastLocation.toJSON(),
            "newLocation": newLocation.toJSON()
        ])
        movementLocations = []
    }
    

    
    func stoppedMoving(previousLocationTime: Date) {
        print("LocationManager: StoppedMoving: User has stopped moving for more than \(timeToConsiderStationary) seconds.")
        currentState = .stationary
        sendToServer(body: [
            "eventType": "stoppedMoving",
            "locations": movementLocations.map {
                $0.toJSON()
            },
            "numberOfPoints": movementLocations.count,
            "rejectedLocations": rejectedLocations.map {
                $0.toJSON()
            },
            "rejectedNumberOfPoints": rejectedLocations.count,
            "timeSinceLastMovement": Date().timeIntervalSince(previousLocationTime),
            "timeStopped": HasuraUtil.dateToUTCString(date:previousLocationTime)
        ])
        
        rejectedLocations = []
        
        locationManager.stopUpdatingLocation()
        locationManager.distanceFilter = locationUpdateDistanceFilter
        locationManager.startUpdatingLocation()
    }
    
    
    private func sendToServer(body: [String: Any] = [:]) {
        print("LocationManager: SendToServer")
        print(body)
        Task {
            do {
                guard let data = try await ServerCommunicator.sendPostRequest(to: updateMovementEndpoint, body: body, token: Authentication.shared.hasuraJwt) else {
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


extension CLLocation {
    func toJSON() -> [String: Any] {
        return [
            "lat": self.coordinate.latitude,
            "lon": self.coordinate.longitude,
            "accuracy": self.horizontalAccuracy,
            "timestamp": HasuraUtil.dateToUTCString(date: self.timestamp)
        ]
    }
}
