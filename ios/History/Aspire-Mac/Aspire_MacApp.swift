//
//  Aspire_MacApp.swift
//  Aspire-Mac
//
//  Created by Nathik Azad on 9/9/24.
//

import SwiftUI
import SwiftData

@main
struct Aspire_DesktopApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
