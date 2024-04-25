import SwiftUI
import MapKit
import Charts

struct LocationDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var locationName: String = ""
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    @State private var isEditing: Bool = false
    @State var events: [EventModel] = []
    @State private var selectedDays: Double = 7
    @State private var maxDays: Double = 7
    
    
    var location: LocationModel
    
    
    var dailyTotals: [(String, Double)] {
        EventsController.dailyTotals(events: events, days: Int(selectedDays))
    }
    
    private func fetchLocationDetails() {
        if(location.id != nil) {
            Task {
                let userId: Int? = Authentication.shared.userId
                let resp = await EventsController.fetchEvents(userId: userId!, eventType: "stay", locationId: location.id!, order: "desc")
                DispatchQueue.main.async {
                    events = resp
                    maxDays = EventsController.maxDays(events: resp)
                    selectedDays = min(maxDays, 7)
                }
            }
        }
    }
    
    
    
    private func saveLocationName() {
        print("Saving location \(locationName)")
        LocationsController.createLocation(name: locationName, lat: location.latitude, lon: location.longitude)
//        LocationsController.editLocationName(id: location.id!, name: locationName)

    }
    
    var body: some View {
        Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: [location]) { l in
            MapPin(coordinate: CLLocationCoordinate2D(latitude: l.latitude, longitude: l.longitude), tint: .red)
        }
        .frame(height: 200)
        .onAppear {
            updateRegionFromLocation()
        }
        List {
            Section(header: Text("Location Name")) {
                HStack {
                    TextField("Enter Location Name", text: $locationName, onEditingChanged: { editing in
                        isEditing = editing
                    })
                    if isEditing {
                        Button(action: {
                            saveLocationName()
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }, label: {
                            Text("Save")
                        })
                    }
                }
            }
            
            Section(header: Text("Check-ins")) {
                ForEach(events, id: \.id) { event in
                    Text(event.formattedTimeWithDate)
                        .font(.subheadline)
                }
            }
            if(events.count > 1) {
                Section(header: Text("Graph")) {
                    HStack {
                        Slider(value: $selectedDays, in: 1...max(maxDays, 1), step: 1)
                            .accentColor(.gray)
                        Text("\(Int(selectedDays))")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    Chart {
                        ForEach(dailyTotals, id: \.0) { day, hours in
                            BarMark(
                                x: .value("Day", day),
                                y: .value("Hours", hours)
                            )
                            .foregroundStyle(Color.gray)
                        }
                    }
                    .frame(height: 200)
                }
            }
        }
    }
    
    private func updateRegionFromLocation() {
        region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude), span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
        locationName = location.name ?? ""
        if(locationName == "Unknown location"){
            locationName = ""
        }
        fetchLocationDetails()
    }
}
