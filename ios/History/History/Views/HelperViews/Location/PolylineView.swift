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

func generateSamplePolyline() -> [MapCoordinate] {
    // Generating a sample polyline for demonstration
    let point1 = MapCoordinate(coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194))
    let point2 = MapCoordinate(coordinate: CLLocationCoordinate2D(latitude: 37.8044, longitude: -122.2711))
    let point3 = MapCoordinate(coordinate: CLLocationCoordinate2D(latitude: 37.8716, longitude: -122.2727))
    let point4 = MapCoordinate(coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194))
    return [point1, point2, point3, point4]
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
