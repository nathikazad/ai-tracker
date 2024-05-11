import SwiftUI



struct LocationsListView: View {
    @StateObject var locationsController = LocationsController()
    
    var body: some View {
        List(locationsController.locations, id: \.id) { location in
            NavigationLink(destination: LocationDetailView(location: location)) {
                Text(location.name ?? "Unknown")
            }
        }
        .navigationTitle("User Locations")
        .onAppear {
            locationsController.fetchLocations(userId: Authentication.shared.userId!)
        }
    }
}

struct LocationsDebugView: View {
    
    var body: some View {
        List {
            let list = LocationManager.shared.sentLocations
            ForEach(list, id: \.0) { location in
                let loc: LocationModel = LocationModel.fromCLLocation(
                    name: location.1 ? "Foreground" : "Background",
                    location: location.0)
                NavigationLink(destination: LocationDetailView(location: loc)) {
                    Text("\(location.1 ? "Foreground" : "Background") \(location.0.timestamp)")
                }
            }
            
        }
        .navigationTitle("User Locations")
    }
}

