//
//  HistoryApp.swift
//  History
//
//  Created by Nathik Azad on 3/17/24.
//

import SwiftUI

@main
struct HistoryApp: App {
    @StateObject var watchConnector = iOSToWatch()
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
