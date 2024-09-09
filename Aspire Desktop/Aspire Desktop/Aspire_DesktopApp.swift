//
//  Aspire_DesktopApp.swift
//  Aspire Desktop
//
//  Created by Nathik Azad on 9/7/24.
//
import SwiftUI
import SwiftData
import AVFoundation

@main
struct Aspire_DesktopApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            ScreenshotSettings.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
        
        // Add this to hide the main window
        Settings {
            EmptyView()
        }
    }
}
