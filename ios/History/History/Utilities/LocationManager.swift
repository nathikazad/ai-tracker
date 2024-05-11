import Foundation
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    
    let locationManager = CLLocationManager()
    var waitingForImmediateLocation: Bool = false
    
    private let locationUpdateDistanceFilter: CLLocationDistance = 50
    var waitAndSendLocationTimer: Timer?
    let timeToWaitBeforeSending = 60.0 //seconds
    var locationsToSend: [CLLocation] = []
    
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
        if(waitingForImmediateLocation) {
            print("LocationManager: LocationManager: Immediate location")
            waitingForImmediateLocation = false
            uploadLocationToServer([location])
        } else {
            print("LocationManager: LocationManager: Regular OS location, Adding to be sent in 60 seconds")
            waitAndSendLocationTimer?.invalidate()
            waitAndSendLocationTimer = nil
            locationsToSend.append(location)
            waitAndSendLocationTimer = Timer.scheduledTimer(timeInterval: timeToWaitBeforeSending, target: self, selector: #selector(sendRemainingLocations), userInfo: nil, repeats: false)
        }
    }
    
    @objc private func sendRemainingLocations() {
        print("LocationManager: sendRemainingLocations: sending remaining locations")
        uploadLocationToServer(locationsToSend, fromBackground: true)
        locationsToSend = []
        waitAndSendLocationTimer = nil
    }
    
    func forceUpdateLocation() {
        print("LocationManager: forceUpdateLocation")
        locationManager.stopUpdatingLocation()
        locationManager.distanceFilter = locationUpdateDistanceFilter
        locationManager.startUpdatingLocation()
        waitingForImmediateLocation = true
    }
    
    func uploadLocationToServer(_ locations: [CLLocation], fromBackground:Bool = false) {
        guard let token = Authentication.shared.hasuraJwt else {
            print("No token available")
            return
        }
        Task {
            print("sending location \(locations.count)")
            let body = [
                "locations": locations.map { $0.toJSON() },
                "fromBackground": fromBackground
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
