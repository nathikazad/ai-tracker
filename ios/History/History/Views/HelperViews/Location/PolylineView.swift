import SwiftUI
import MapKit
import CoreLocation

struct PolylineView: View {
    var encodedPolyline: String
    
    @State private var polyline: [MapCoordinate] = []
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    var body: some View {
        Map(coordinateRegion: $region, annotationItems: polyline) { coordinate in
            MapPin(coordinate: coordinate.coordinate, tint: .blue)
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            if let decodedPolyline = decodePolyline(encodedPolyline) {
                self.polyline = decodedPolyline
                
                // Calculate bounding box for polyline
                var minLatitude = Double.greatestFiniteMagnitude
                var maxLatitude = -Double.greatestFiniteMagnitude
                var minLongitude = Double.greatestFiniteMagnitude
                var maxLongitude = -Double.greatestFiniteMagnitude
                
                for coordinate in decodedPolyline {
                    let lat = coordinate.coordinate.latitude
                    let lon = coordinate.coordinate.longitude
                    minLatitude = min(minLatitude, lat)
                    maxLatitude = max(maxLatitude, lat)
                    minLongitude = min(minLongitude, lon)
                    maxLongitude = max(maxLongitude, lon)
                }
                let paddingFactor = 1.5 // 20% padding
                let paddedLatitudeDelta = (maxLatitude - minLatitude) * paddingFactor
                let paddedLongitudeDelta = (maxLongitude - minLongitude) * paddingFactor
                
                let center = CLLocationCoordinate2D(latitude: (minLatitude + maxLatitude) / 2, longitude: (minLongitude + maxLongitude) / 2)
                let span = MKCoordinateSpan(latitudeDelta: paddedLatitudeDelta, longitudeDelta: paddedLongitudeDelta)
                self.region = MKCoordinateRegion(center: center, span: span)
            }
        }
    }
}

struct MapCoordinate: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}


func decodePolyline(_ encodedPolyline: String) -> [MapCoordinate]? {
    var index = encodedPolyline.startIndex
    let endIndex = encodedPolyline.endIndex
    var decodedCoordinates: [MapCoordinate] = []
    var lat = 0.0
    var lon = 0.0
    
    while index < endIndex {
        var byte: Int = 0
        var res: Int = 0
        var shift: Int = 0
        
        repeat {
            guard index < endIndex else { break }
            let char = encodedPolyline[index]
            index = encodedPolyline.index(after: index)
            byte = Int(char.asciiValue!) - 63
            res |= (byte & 0x1F) << shift
            shift += 5
        } while byte >= 0x20
        
        let deltaLat = ((res & 1) != 0x0 ? ~(res >> 1) : (res >> 1))
        lat += Double(deltaLat)
        
        shift = 0
        res = 0
        
        repeat {
            guard index < endIndex else { break }
            let char = encodedPolyline[index]
            index = encodedPolyline.index(after: index)
            byte = Int(char.asciiValue!) - 63
            res |= (byte & 0x1F) << shift
            shift += 5
        } while byte >= 0x20
        
        let deltaLon = ((res & 1) != 0x0 ? ~(res >> 1) : (res >> 1))
        lon += Double(deltaLon)
        
        let coordinate = MapCoordinate(coordinate: CLLocationCoordinate2D(latitude: lat * 1e-5, longitude: lon * 1e-5))
        decodedCoordinates.append(coordinate)
    }
    
    return decodedCoordinates
}


//struct PolylineView: UIViewRepresentable {
//    var encodedPolyline: String
//    
//    func makeUIView(context: Context) -> MKMapView {
//        let mapView = MKMapView()
//        mapView.delegate = context.coordinator
//        
//        if let decodedPolyline = decodePolyline(encodedPolyline) {
//            let polyline = MKPolyline(coordinates: decodedPolyline, count: decodedPolyline.count)
//            mapView.addOverlay(polyline)
//            
//            // Adjust map region to fit polyline
//            let polylineBoundingRect = polyline.boundingMapRect
//            let edgeInsets = UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50)
//            mapView.setVisibleMapRect(polylineBoundingRect, edgePadding: edgeInsets, animated: true)
//        }
//        
//        return mapView
//    }
//    
//    func updateUIView(_ mapView: MKMapView, context: Context) {
//        // Update the view
//    }
//    
//    func makeCoordinator() -> Coordinator {
//        Coordinator()
//    }
//    
//    class Coordinator: NSObject, MKMapViewDelegate {
//        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
//            if let polyline = overlay as? MKPolyline {
//                let renderer = MKPolylineRenderer(polyline: polyline)
//                renderer.strokeColor = .blue
//                renderer.lineWidth = 3
//                return renderer
//            }
//            return MKOverlayRenderer()
//        }
//    }
//}
