//
//  ContentView.swift
//  Aspire Desktop
//
//  Created by Nathik Azad on 9/7/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settings: [ScreenshotSettings]
    
    var body: some View {
        VStack {
            Text("Aspire Desktop")
            ScreenshotView()
        }
    }
}
