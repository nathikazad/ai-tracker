import SwiftUI
import MapKit

struct LocationDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var locationName: String = ""
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    @State private var isEditing: Bool = false
    @State var events: [EventModel] = []
    var location: LocationModel
    
    private func fetchLocationDetails() {
        if(location.id != nil) {
            Task {
                let userId: Int? = Authentication.shared.userId
                let resp = await EventsController.fetchEvents(userId: userId!, eventType: "stay", locationId: location.id!, order: "desc")
                DispatchQueue.main.async {
                    events = resp
                }
            }
        }
    }
    
    private func saveLocationName() {
        print(location.id)
//        if(location.id != nil) {
//            LocationsController.editLocationName(id: location.id!, name: locationName)
//            print("Location name saved: \(locationName)")
//        } else {
            LocationsController.createLocation(name: locationName, lat: location.latitude, lon: location.longitude)
//        }
    }
    
    
    var body: some View {
        VStack {
            HStack {
                TextField("Enter Location Name", text: $locationName, onEditingChanged: { editing in
                    isEditing = editing
                })
                .padding()
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
            
            Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: [location]) { l in
                MapPin(coordinate: CLLocationCoordinate2D(latitude: l.latitude, longitude: l.longitude), tint: .red)
            }
            .frame(height: 200)
            .onAppear {
                region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude), span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
                locationName = location.name ?? ""
                if(locationName == "Unknown location"){
                    locationName = ""
                }
                fetchLocationDetails()
            }
            
            List {
                ForEach(events, id: \.id) { event in
                    HStack {
                        Text(event.formattedTimeWithDate)
                            .font(.subheadline)
                            .frame(alignment: .leading)
                    }
                }
            }
        }
    }
}


//                if(location.id != nil) {
//                    Button(action: {
//                        Task {
//                            await LocationsController.deleteLocation(id: location.id!)
//                            presentationMode.wrappedValue.dismiss()
//                        }
//                    }, label: {
//                        Text("Delete")
//                    })
//                    .padding()
//                }
