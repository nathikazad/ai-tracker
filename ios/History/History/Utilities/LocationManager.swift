import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    
    let locationManager = CLLocationManager()
    
    private let locationUpdateDistanceFilter: CLLocationDistance = 30
    var waitAndSendLocationTimer: Timer?
   let timeToWaitBeforeSending = 200.0 //seconds
    

    var receivedLocations: [(CLLocation, Bool)] = []
    var locationsQueue: [CLLocation] = []
    var sentToServerCount = 0
    var locationsReceivedCount = 0
    var locationsSentCount = 0
    @Published var isTrackingLocation = false
    
    override init() {
        super.init()
        print("LocationManager: init")
        locationManager.delegate = self
        setConfig()
        initializeTrackingState()
    }
    
    private func setConfig() {
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = locationUpdateDistanceFilter
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
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
        print("LocationManager: stopMonitoringLocation")
        locationManager.stopUpdatingLocation()
        isTrackingLocation = false
    }
    
    func startMonitoringLocation() {
        print("LocationManager: startMonitoringLocation")
        Task {
            if CLLocationManager.locationServicesEnabled() {
                print("LocationManager: startMonitoringLocation: location services enabled")
                // first check if always authorization is already granted
                if locationManager.authorizationStatus == .authorizedAlways {
                    print("LocationManager: startMonitoringLocation: authorizedAlways")
                    setConfig()
                    locationManager.startUpdatingLocation()
                    isTrackingLocation = true
                } else {
                    print("LocationManager: startMonitoringLocation: requestAlwaysAuthorization")
                    locationManager.requestAlwaysAuthorization()
                }
            }
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("LocationManager: locationManagerDidChangeAuthorization")
        checkLocationAuthorization(manager: manager)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("LocationManager: locationManager: didChangeAuthorization \(status)")
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
        locationsReceivedCount += 1
        waitAndSendLocationTimer?.invalidate()
        locationsQueue.append(location)

        if(locationsQueue.count == 1) {
            print("Only one starting timer for \(timeToWaitBeforeSending)")
            waitAndSendLocationTimer = Timer.scheduledTimer(timeInterval: timeToWaitBeforeSending, target: self, selector: #selector(sendQueue), userInfo: nil, repeats: false)
        } else {
            let timeDifference = locationsQueue.last!.timestamp.timeIntervalSince(locationsQueue.first!.timestamp)
            if timeDifference > timeToWaitBeforeSending {
                print("Time difference \(timeDifference) is greater than \(timeToWaitBeforeSending) seconds")
                sendQueue()
            } else {
                print("Time difference \(timeDifference) is less than \(timeToWaitBeforeSending) seconds, so starting timer for \(timeToWaitBeforeSending-timeDifference) seconds")
                waitAndSendLocationTimer = Timer.scheduledTimer(timeInterval: timeToWaitBeforeSending-timeDifference, target: self, selector: #selector(sendQueue), userInfo: nil, repeats: false)   
            }
        }
        
    }
    
    @objc private func sendQueue() {
        print("LocationManager: sendRemainingLocations: sending remaining locations \(locationsQueue.count)")
        if locationsQueue.count == 0 {
            return
        }
        var locationsToSend: [CLLocation] = []
        locationsToSend.append(locationsQueue[0])
        var lastAddedIndex = 0
        for i in 1..<locationsQueue.count {
            let timeDifference = locationsQueue[i].timestamp.timeIntervalSince(locationsQueue[lastAddedIndex].timestamp)
            if timeDifference > 60 {
                locationsToSend.append(locationsQueue[i])
                lastAddedIndex = i
            }

        }
        print("LocationManager: sendRemainingLocations: sending \(locationsQueue.count) -> \(locationsToSend.count) locations")
        locationsSentCount += locationsToSend.count
        locationsToSend.forEach {
            receivedLocations.append(($0, AppState.shared.inForeground)) 
        }
        
        uploadLocationToServer(locationsToSend)
        locationsQueue = []
        waitAndSendLocationTimer?.invalidate()
        waitAndSendLocationTimer = nil
    }
    
//    func forceUpdateLocation() {
//        print("LocationManager: forceUpdateLocation")
//        locationManager.stopUpdatingLocation()
//        setConfig()
//        locationManager.startUpdatingLocation()
//        locationManager.requestLocation()
//    }
    
    func uploadLocationToServer(_ locations: [CLLocation]) {
        print("LocationManager: UploadLocationToServer:sending location \(locations.count)")
        guard let token = Authentication.shared.hasuraJwt else {
            print("No token available")
            return
        }
        Task {
            print("sending location \(locations.count)")
            let body = [
                "locations": locations.map { $0.toJSON() },
                "fromBackground": !AppState.shared.inForeground
            ]
            ServerCommunicator.sendPostRequest(to: updateLocationEndpoint, body: body, token: token, stackOnUnreachable: true)
            sentToServerCount += 1
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
