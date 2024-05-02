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
    @State private var selectedTab: Int = 1
    
    
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
                    selectedTab = (events.count > 1) ? 1 :0
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
        VStack {
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
                if(location.id != nil) {
                    if(events.count > 2) {
                        HStack {
                            Button(action: {
                                selectedTab = 0
                            }) {
                                Text("Graph")
                                    .foregroundColor(selectedTab == 0 ? .gray : .white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(selectedTab == 0 ? Color.white : Color.gray)
                                    .cornerRadius(5)
                            }
                            .disabled(selectedTab == 0)
                            
                            Button(action: {
                                selectedTab = 1
                            }) {
                                Text("Check ins")
                                    .foregroundColor(selectedTab == 1 ? .gray : .white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(selectedTab == 1 ? Color.white : Color.gray)
                                    .cornerRadius(5)
                            }
                            .disabled(selectedTab == 1)
                        }
                    }
                    
                    if selectedTab == 0 {
                        CheckInsView(events: events)
                    } else {
                        ScrollView {
                            VStack {
                                SliderView(selectedDays: $selectedDays, maxDays: $maxDays)
                                CandleView(title: "Time", candles: events.dailyTimes(days: Int(selectedDays)).map { Candle(date: $0, start: $1, end: $2 ) })
                                    .padding(.bottom)
                                BarView(title: "Total Hours per day", data: events.dailyTotals( days: Int(selectedDays)))
                                    .padding(.bottom)
                                ScatterView(title: "Start time",  data: events.startTimes(days: Int(selectedDays), unique: true))
                                ScatterView(title: "End time", data: events.endTimes(days: Int(selectedDays), unique: true))
                                    .padding(.bottom)
                                
                                
        //                        ScatterViewDoubles(title: "Correlation", data: Array(zip(sleepTimes, wakeTimes)))
        //                            .padding(.bottom)
                            }
                        }
                    }
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
    
    struct CheckInsView: View {
        var events: [EventModel] // Assume Event is the type of the events array
        
        var body: some View {
            Section(header: Text("Check-ins")) {
                ForEach(events, id: \.id) { event in
                    Text(event.formattedTimeWithDate)
                        .font(.subheadline)
                }
            }
        }
    }
    
    struct GraphView: View {
        @Binding var selectedDays: Double
        var events: [EventModel]
        var maxDays: Double
        var locationName: String
        var body: some View {
            Section(header: Text("Graph")) {
                HStack {
                    Slider(value: $selectedDays, in: 1...max(maxDays, 1), step: 1)
                        .accentColor(.gray)
                    Text("\(Int(selectedDays))")
                        .foregroundColor(.gray)
                }
                .padding()
                CandleView(title: "Times at \(locationName)", candles: events.dailyTimes(days: Int(selectedDays)).map { Candle(date: $0, start: $1, end: $2 ) })
                .padding(.bottom, 50)
//                .frame(height: 200)
                BarView(title: "Hours at \(locationName) per day", data: events.dailyTotals(days: Int(selectedDays)))
                .padding(.bottom)
//                .frame(height: 200)
            }
        }
    }
}
