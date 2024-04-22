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

