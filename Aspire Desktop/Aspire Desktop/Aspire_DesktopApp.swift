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
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
