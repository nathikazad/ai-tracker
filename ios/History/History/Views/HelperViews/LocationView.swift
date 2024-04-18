//
//  LocationView.swift
//  History
//
//  Created by Nathik Azad on 4/17/24.
//

import SwiftUI
import MapKit

struct IdentifiableLocation: Identifiable {
    let id = UUID()  // Unique identifier for each location
    var location: CLLocation
}


class LocationViewModel: ObservableObject {
    @Published var mapRegion: MKCoordinateRegion
    var locationManager = LocationManager.shared
    var locations: [IdentifiableLocation]
    
    init() {
        if(locationManager.currentState == .stationary) {
            self.locations = locationManager.rejectedLocations.map { IdentifiableLocation(location: $0.location) }
        } else {
            self.locations = locationManager.movementLocations.map { IdentifiableLocation(location: $0.location) }
        }
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
            mapRegion = MKCoordinateRegion(center: center, span: span)
        } else {
            mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), latitudinalMeters: 1000, longitudinalMeters: 1000)
        }
    }
}


struct LocationsView: View {
    @ObservedObject var viewModel: LocationViewModel
    
    var body: some View {
        VStack{
            Text(LocationManager.shared.currentState == .moving ? "Moving" : "Stationary")
            Map(coordinateRegion: $viewModel.mapRegion, annotationItems: viewModel.locations) { identifiableLocation in
                MapPin(coordinate: identifiableLocation.location.coordinate, tint: .blue)
            }
        }
    }
}
