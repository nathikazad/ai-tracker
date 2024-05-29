import SwiftUI
import MapKit
import Charts

struct LocationDetailView: View {

    @State private var locationName: String = ""
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    @State private var isEditing: Bool = false
    @State var events: [EventModel] = []
    @State private var selectedDays: Double = 7
    @State private var maxDays: Double = 7
    @State private var selectedTab: SelectedTab = .graphs
    @State private var location: LocationModel
    
    init(location: LocationModel) {
        self.location =  location
    }
    
    private func fetchLocationDetails() {
        if(location.id != nil) {
            Task {
                do {
                    let resp = try await LocationsController.fetchLocation(locationId: location.id!)
                    DispatchQueue.main.async {
                        location = resp
                        events = resp.events ?? []
                        maxDays = events.maxDays
                        selectedDays = min(maxDays, 7)
                        selectedTab = (events.count > 1) ? SelectedTab.graphs : SelectedTab.events
                    }
                } catch {
                    
                }
            }
        }
    }
    
    fileprivate func saveLocation() {
        if(location.id == nil) {
            print("Creating Location")
            Task {
                do {
                    let id = try await LocationsController.createLocation(name: locationName, lat: location.latitude, lon: location.longitude)
                    DispatchQueue.main.async {
                        location.id = id
                    }
                } catch {
                    print("LocationDetailView: Save Location Error")
                }
            }
        } else {
            print("Updating Location Name")
            // TODO: Update name in db
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
                        saveLocation()
                        UIApplication.shared.minimizeKeyboard()
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
                if(events.count > 1) {
                    TabBar(selectedTab: $selectedTab)
                }
                EventsListView(events: $events)
            } else {
                VStack {
                    if(location.id != nil) {
                        TabBar(selectedTab: $selectedTab)
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
