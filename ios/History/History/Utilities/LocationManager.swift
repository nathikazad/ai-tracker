import Foundation
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    
    let locationManager = CLLocationManager()
    
    
    private var locationUpdateDistanceFilter: CLLocationDistance {
//        20
        (currentState == .moving) ? 35 : 100
    }
    private let movementDistanceThresholdWhenStationary: CLLocationDistance = 150 // meters
    private let movementDistanceThresholdWhenMoving: CLLocationDistance = 10 // meters
    private let timeToConsiderStationary: TimeInterval = 150 // seconds TODO: change back
    private let rejectedLocationsToAddToMovement: TimeInterval = -120 //seconds
    
    var movementLocations: [CLLocation] = []
    var rejectedLocations: [CLLocation] = []
    var lastStationaryLocation: CLLocation?
    var movementCheckTimer: Timer?
    var waitingForImmediateLocation = false
    
    var timerExpirationDate: Date?
    
    
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
    
    fileprivate func checkIfLastStaySameAsCurrentLocation() {
        if let lastStayEvent = Authentication.shared.user?.events.first,
           let lastLocation = lastStayEvent.metadata?.location?.toCLLocation,
           !self.movementLocations.isEmpty {
            
            print("LocationManager: checkIfLastStaySameAsCurrentLocation: \(lastStayEvent.id) \(lastStayEvent.formattedTimeWithDate)")
            print(lastLocation)
            
            let firstMovementLocation = self.movementLocations[0]
            let distance = firstMovementLocation.distance(from: lastLocation)
            if (distance < movementDistanceThresholdWhenStationary)
            {
                print("LocationManager: checkIfLastStaySameAsCurrentLocation: same location \(distance)")
                let currentLocation = CLLocation(coordinate: CLLocationCoordinate2D(latitude: lastLocation.coordinate.latitude, longitude: lastLocation.coordinate.longitude), altitude: 0, horizontalAccuracy: 35, verticalAccuracy: 0, timestamp: lastStayEvent.startTime!)
                movementCheckTimer?.invalidate()
                stoppedMoving(currentLocation: currentLocation, notifyServer: false)
            } else {
                print("LocationManager: checkIfLastStaySameAsCurrentLocation: diff location, \(distance) update db")
                EventsController.editEvent(id: lastStayEvent.id, startTime: lastStayEvent.startTime!, endTime: Date())
            }
        }
    }
    
    func startMonitoringLocation() {
        print("start monitoring")
        Task {
            if CLLocationManager.locationServicesEnabled() {
                self.locationManager.requestAlwaysAuthorization()
                checkIfLastStaySameAsCurrentLocation()
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
            stoppedMoving(currentLocation: location)
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
            checkIfStopped(location)
        case .stationary:
            if let lastStationaryLocation = lastStationaryLocation {
                let distance = location.distance(from: lastStationaryLocation)
                print("LocationManager: UpdateLocation: Distance from last stationary location: \(distance)")
                if distance > movementDistanceThresholdWhenStationary + location.horizontalAccuracy + lastStationaryLocation.horizontalAccuracy {
                    // TODO: wait for 3 more locations that are beyond threshold within last n minutes and modify movementDistanceThresholdWhenStationary to be lower
                    startedMoving(distance: distance, lastLocation: lastStationaryLocation, newLocation: location )
                } else {
                    rejectedLocations.append(location)
                    print("LocationManager: UpdateLocation: Not enough distance to consider moving")
                }
            }
        }
    }
    
    fileprivate func startTimer(_ timeToCheckForNoMovement: TimeInterval) {
        print("LocationManager: Check Movement: Starting timer for \(timeToCheckForNoMovement) seconds in case another location update doesn't come due to the user being in the same location")
        timerExpirationDate = Date().addingTimeInterval(timeToCheckForNoMovement)
        movementCheckTimer = Timer.scheduledTimer(timeInterval: timeToCheckForNoMovement, target: self, selector: #selector(requestLocation), userInfo: nil, repeats: false)
        
    }
    
    func checkIfStopped(_ location: CLLocation) {
        print("LocationManager: Check Movement")
        if(!movementLocations.isEmpty) {
            print("LocationManager: Check Movement: Distance since last movement \(location.distance(from: movementLocations.last!))")
            print("LocationManager: Check Movement: Distance since first movement \(location.distance(from: movementLocations.first!))")
        }
        movementCheckTimer?.invalidate()
        var timeToCheckForNoMovement = timeToConsiderStationary
        if movementLocations.isEmpty {
            print("LocationManager: checkIfStopped: First movement check")
            movementLocations.append(location)
            startTimer(timeToConsiderStationary)
        } else if (location.distance(from: movementLocations.last!) > movementDistanceThresholdWhenMoving + location.horizontalAccuracy + movementLocations.last!.horizontalAccuracy) {
            print("LocationManager: Check Movement: Appending location because past threshold")
            movementLocations.append(location)
            startTimer(timeToConsiderStationary)
        } else {
            print("LocationManager: Check Movement: Did not append location because below threshold")
            print("LocationManager: Check Movement: Checking if elapsed time since last movement is greater than timeToConsiderStationary")
            // you got a new location but it wasn't above movement threshold
            // then you check if elapsed time was greated than timeToConsiderStationary
            // if yes then you call stop moving
            // otherwise you start the timer for a reduced time
            let elapsedTime = Date().timeIntervalSince(movementLocations.last!.timestamp)
            if elapsedTime > timeToConsiderStationary {
                print("LocationManager: Check Movement: Stopped moving because the user hasn't moved far in \(timeToConsiderStationary) seconds")
                stoppedMoving(currentLocation: location)
                return;
            } else {
                print("LocationManager: Check Movement: Not greater than stationary so going to reduce the timer time")
                startTimer(timeToConsiderStationary - elapsedTime)
            }
        }
        
        
    }
    
    @objc private func requestLocation() {
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
            "threshold": movementDistanceThresholdWhenStationary,
            "oldLocation": lastLocation.toJSON(),
            "newLocation": newLocation.toJSON(),
            // "rejectedLocations": rejectedLocations.map {
            //     $0.toJSON()
            // },
            "rejectedNumberOfPoints": rejectedLocations.count,
        ])
        
        movementLocations = [lastStationaryLocation!]
        movementLocations += rejectedLocations.filter { $0.timestamp > Date().addingTimeInterval(rejectedLocationsToAddToMovement) }
        rejectedLocations = []
        locationManager.stopUpdatingLocation()
        locationManager.distanceFilter = locationUpdateDistanceFilter
        locationManager.startUpdatingLocation()
    }
    

    func findLocationsOfInterest(location: CLLocation) async -> String? {
        print("LocationManager: findLocationsOfInterest: \(location)")
        let geocoder = CLGeocoder()
        
        do {
            return try await withCheckedThrowingContinuation { continuation in
                geocoder.reverseGeocodeLocation(location) { placemarks, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let placemark = placemarks?.first {
                        if let areasOfInterest = placemark.areasOfInterest, let firstAreaOfInterest = areasOfInterest.first {
                            continuation.resume(returning: firstAreaOfInterest)
                        } else {
                            continuation.resume(returning: nil)
                        }
                    }
                }
            }
        } catch {
            print("Error: \(error.localizedDescription)")
            return nil
        }
    }

    
    func stoppedMoving(currentLocation: CLLocation, notifyServer:Bool = true) {
        Task {
            lastStationaryLocation = currentLocation
            print("LocationManager: StoppedMoving: User has stopped moving. Notify server \(notifyServer)")
            movementLocations.append(currentLocation)
            currentState = .stationary
            if notifyServer {
                var body = [
                    "eventType": "stoppedMoving",
                    "locations": movementLocations.map {
                        $0.toJSON()
                    },
                    "numberOfPoints": movementLocations.count,
                    //            "timeSinceLastMovement": Date().timeIntervalSince(previousLocationTime),
                    "timeStopped": Date().addingTimeInterval(-timeToConsiderStationary).toUTCString
                ]
                if let landmark = await findLocationsOfInterest(location: currentLocation) {
                    print("LocationManager: StoppedMoving: landmark \(landmark)")
                    body["landmark"] = landmark
                } else {
                    print("LocationManager: StoppedMoving: no landmark")
                }
                sendToServer(body: body)
            }
        }
        
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
            "timestamp": self.timestamp.toUTCString
        ]
    }
}
