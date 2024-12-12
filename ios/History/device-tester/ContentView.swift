//
//  ContentView.swift
//  ble-test-2
//
//  Created by Nathik Azad on 12/11/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    var body: some View {
        BLECameraView()
    }
}

struct BLECameraView: View {
    @StateObject private var ble = BLEHandler()
    
    var body: some View {
        ZStack {
            if let image = ble.currentImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                VStack {
                    if ble.isScanning {
                        ProgressView()
                        Text("Scanning for camera...")
                    } else if !ble.isConnected {
                        Text("No device connected")
                        Button("Scan") {
                            ble.startScanning()
                        }
                    } else {
                        Text("Waiting for image...")
                    }
                }
            }
        }
    }
}
