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
    @State private var selectedTab: SelectedTab = .graphs
    
    
    var location: LocationModel
    
    private func fetchLocationDetails() {
        if(location.id != nil) {
            Task {
                let userId: Int? = Authentication.shared.userId
                let resp = await EventsController.fetchEvents(userId: userId!, eventType: "stay", locationId: location.id!, order: "desc")
                DispatchQueue.main.async {
                    events = resp
                    maxDays = resp.maxDays
                    selectedDays = min(maxDays, 7)
                    selectedTab = (events.count > 1) ? SelectedTab.graphs : SelectedTab.events
                }
            }
        }
    }
    
    fileprivate func LocationName() -> Section<Text, HStack<TupleView<(TextField<Text>, Button<Text>?)>>, EmptyView> {
        return Section(header: Text("Location Name")) {
            HStack {
                TextField("Enter Location Name", text: $locationName, onEditingChanged: { editing in
                    isEditing = editing
                })
                if isEditing {
                    Button(action: {
                        print("Saving location \(locationName)")
                        LocationsController.createLocation(name: locationName, lat: location.latitude, lon: location.longitude)
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }, label: {
                        Text("Save")
                    })
                }
            }
        }
    }
    
    
    var body: some View {
        List {
            Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: [location]) { l in
                MapPin(coordinate: CLLocationCoordinate2D(latitude: l.latitude, longitude: l.longitude), tint: .red)
            }
            .frame(height: 200)
            LocationName()
            if selectedTab == .events {
                TabBar(selectedTab: $selectedTab)
                EventsListView(events: $events)
            } else {
                VStack {
                    if(location.id != nil) {
                        if(events.count > 2) {
                            TabBar(selectedTab: $selectedTab)
                        }
                        SliderView(selectedDays: $selectedDays, maxDays: $maxDays)
                        CountView(selectedDays: $selectedDays, maxDays: $maxDays, events:$events)
                        GraphView(selectedDays: $selectedDays, events:$events, offsetHours: locationName == "Home" ? 5 : 0)
                    }
                }
            }
        }
        .onAppear {
            updateRegionFromLocation()
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
