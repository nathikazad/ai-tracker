import SwiftUI
import MapKit

struct LocationDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var locationName: String = "Unknown"
    @State private var checkInOutTimes: [String] = []
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    @State private var isEditing: Bool = false
    
    var location: LocationModel
    
    var body: some View {
        VStack {
            TextField("Enter Location Name", text: $locationName, onEditingChanged: { editing in
                            isEditing = editing
                        })
                .padding()
            
            Button(action: {
                Task {
                    await LocationsController.deleteLocation(id: location.id)
                    presentationMode.wrappedValue.dismiss()
                }
            }, label: {
                Text("Delete")
            })
            .padding()
            
            Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: [location]) { l in
                MapPin(coordinate: CLLocationCoordinate2D(latitude: l.latitude, longitude: l.longitude), tint: .red)
            }
            .frame(height: 200)
            .onAppear {
                fetchLocationDetails()
            }
            
            List {
                ForEach(checkInOutTimes, id: \.self) { time in
                    Text(time)
                }
            }
            if isEditing {
                Button(action: {
                    saveLocationName()
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }, label: {
                    Text("Save")
                })
                .padding()
            }
        }
    }
    
    private func fetchLocationDetails() {
        
        
        region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude), span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
        locationName = location.name ?? "Unknown"
        // Use the location data to populate checkInOutTimes if needed
        checkInOutTimes = ["08:00 AM", "12:00 PM", "04:00 PM", "08:00 AM", "12:00 PM", "04:00 PM", "08:00 AM", "12:00 PM", "04:00 PM", "08:00 AM", "12:00 PM", "04:00 PM"]
        
    }
    
    private func saveLocationName() {
        LocationsController.editLocationName(id: location.id, name: locationName)
        print("Location name saved: \(locationName)")
    }
}
