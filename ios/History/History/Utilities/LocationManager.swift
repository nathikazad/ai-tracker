import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    
    let locationManager = CLLocationManager()
    
    private let locationUpdateDistanceFilter: CLLocationDistance = 40
    var waitAndSendLocationTimer: Timer?
//    let timeToWaitBeforeSending = 60.0 //seconds
    

    var receivedLocations: [(CLLocation, Bool)] = []
    var locationsQueue: [CLLocation] = []
    @Published var isTrackingLocation = false
    
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
        locationsQueue.append(location)
        receivedLocations.append((location, AppState.shared.inForeground))
        waitAndSendLocationTimer?.invalidate()
        waitAndSendLocationTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(sendQueue), userInfo: nil, repeats: false)
    }
    
    @objc private func sendQueue() {
        print("LocationManager: sendRemainingLocations: sending remaining locations \(locationsQueue.count)")
        uploadLocationToServer(locationsQueue)
        locationsQueue = []
        waitAndSendLocationTimer?.invalidate()
        waitAndSendLocationTimer = nil
    }
    
    func forceUpdateLocation() {
        print("LocationManager: forceUpdateLocation")
        locationManager.stopUpdatingLocation()
        locationManager.startUpdatingLocation()
    }
    
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
