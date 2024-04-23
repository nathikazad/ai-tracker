import SwiftUI
import MapKit
import CoreLocation

struct IdentifiableLocation: Identifiable {
    let id = UUID()  // Unique identifier for each location
    var location: CLLocation
    var color: Color
}

class LocationViewModel: ObservableObject {
    
    var locationManager = LocationManager.shared
    @Published var locations: [IdentifiableLocation] = []
    @Published var lastDistance: Double = 0.0
    @Published var timeLeft: Double = 0.0
    @Published var timeAtLocation: Double = 0.0
    @Published var region: MKCoordinateRegion = MKCoordinateRegion()
    
    
    init() {
        update()
    }
    
    func update(recalculateCenter:Bool = true) {
        self.locations = []
        self.locations = locationManager.rejectedLocations.map { IdentifiableLocation(location: $0, color: .red) }
        if(locationManager.currentState == .moving) {
            self.locations += locationManager.movementLocations.map { IdentifiableLocation(location: $0, color: .green) }
        }
        self.timeLeft = locationManager.timerExpirationDate?.timeIntervalSince(Date()) ?? 0.0
        if let lastStationaryLocation = locationManager.lastStationaryLocation {
            self.timeAtLocation = Date().timeIntervalSince(lastStationaryLocation.timestamp)
            self.locations.append(IdentifiableLocation(location: lastStationaryLocation, color: .orange))
            self.lastDistance = locationManager.rejectedLocations.last?.distance(from: lastStationaryLocation) ?? 0.0
        }
        if(recalculateCenter) {
            setCenterAndSpan()
        }
        objectWillChange.send()
    }
    
    
    func setCenterAndSpan()  {
        if !locations.isEmpty {
            let lats = locations.map { $0.location.coordinate.latitude }
            let lons = locations.map { $0.location.coordinate.longitude }
            let maxLat = lats.max()!
            let minLat = lats.min()!
            let maxLon = lons.max()!
            let minLon = lons.min()!
            
            let center = CLLocationCoordinate2D(
                latitude: (maxLat + minLat) / 2,
                longitude: (maxLon + minLon) / 2
            )
            let span = MKCoordinateSpan(
                latitudeDelta: (maxLat - minLat) * 1.4,  // 10% padding
                longitudeDelta: (maxLon - minLon) * 1.4  // 10% padding
            )
            updateRegion(center: center, span: span)
        }
    }
    
    
    func updateRegion(center: CLLocationCoordinate2D, span: MKCoordinateSpan) {
        region = MKCoordinateRegion(center: center, span: span)
    }
}

struct LocationsDebugView: View {
    @ObservedObject var viewModel: LocationViewModel = LocationViewModel()
    @State private var timer: Timer? // Declare timer as a state variable
    var locationManager = LocationManager.shared
    var body: some View {
        VStack{
            Text(LocationManager.shared.currentState == .moving ? "Moving \( String(format: "%.0f",viewModel.timeLeft))s" : "Stationary \( secondsToHhMm(viewModel.timeAtLocation)) \( String(format: "%.0f",viewModel.lastDistance))m \(locationManager.rejectedLocations.count) ")
            // put center and span here if not null or initialize default values
            Map(coordinateRegion: $viewModel.region, annotationItems: viewModel.locations) { identifiableLocation in
                MapPin(coordinate: identifiableLocation.location.coordinate, tint: identifiableLocation.color)
            }
        }.onAppear {
            // Code to execute when the view appears
            print("View appeared")
            viewModel.update()
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
                viewModel.update(recalculateCenter: false)
            }
        }.onDisappear {
            // Code to execute when the view disappears
            print("View disappeared")
            timer?.invalidate() // Invalidate the timer when the view disappears
            timer = nil // Set the timer to nil to release its reference
        }
    }
    
    func secondsToHhMm(_ seconds: Double) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        return String(format: "%02d:%02d", hours, minutes)
    }
}
