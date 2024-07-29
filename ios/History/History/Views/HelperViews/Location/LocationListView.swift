//import SwiftUI
//
//
//
//struct LocationsListView: View {
//    @State var locations: [LocationModel] = []
//    
//    var body: some View {
//        List(locations, id: \.id) { location in
//            NavigationLink(destination: LocationDetailView(location: location)) {
//                Text(location.name ?? "Unknown")
//            }
//        }
//        .navigationTitle("User Locations")
//        .onAppear {
//            Task {
//                let resp = try await LocationsController.fetchLocations(userId: auth.userId!)
//                DispatchQueue.main.async {
//                    locations = resp
//                }
//            }
//        }
//    }
//}
//
//struct LocationsDebugView: View {
//    
//    var body: some View {
//        List {
//            let list = LocationManager.shared.receivedLocations
//            ForEach(list, id: \.0) { location in
//                let loc: LocationModel = LocationModel.fromCLLocation(
//                    name: location.1 ? "Foreground" : "Background",
//                    location: location.0)
//                NavigationLink(destination: LocationDetailView(location: loc)) {
//                    Text("\(location.1 ? "Foreground" : "Background") \(location.0.timestamp)")
//                }
//            }
//            
//        }
//        .navigationTitle("User Locations")
//    }
//}
//
