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
        FileReceiverView()
        
    }
}

import SwiftUI

import AVKit

// MARK: - Models
struct ReceivedFile: Identifiable {
    let id = UUID()
    let url: URL
    let dateReceived: Date
    let fileType: FileType
    
    enum FileType {
        case wav
        case jpg
        
        var icon: String {
            switch self {
            case .wav: return "waveform"
            case .jpg: return "photo"
            }
        }
    }
}

// MARK: - File Explorer View
struct FileExplorerView: View {
    @State private var files: [ReceivedFile] = []
    @State private var selectedFile: ReceivedFile?
    
    var body: some View {
        List(files) { file in
            FileRow(file: file)
                .onTapGesture {
                    selectedFile = file
                }
        }
        .sheet(item: $selectedFile) { file in
            FilePreviewView(file: file)
        }
        .onAppear {
            loadFiles()
        }
    }
    
    private func loadFiles() {
        // Implement file loading logic here
    }
}

struct FileRow: View {
    let file: ReceivedFile
    
    var body: some View {
        HStack {
            Image(systemName: file.fileType.icon)
            VStack(alignment: .leading) {
                Text(file.url.lastPathComponent)
                Text(file.dateReceived, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Bluetooth Console View
struct BluetoothConsoleView: View {
    @ObservedObject var bleManager: BLEManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: bleManager.isConnected ? "bluetooth.connected" : "bluetooth")
                Text(bleManager.isConnected ? "Connected" : "Disconnected")
            }
            
            if bleManager.isReceiving {
                VStack(alignment: .leading) {
                    Text("Receiving file...")
                    ProgressView(value: bleManager.progressPercentage, total: 100)
                    Text("\(bleManager.receivedPackets)/\(bleManager.totalPackets) packets")
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

// MARK: - Main View
struct FileReceiverView: View {
    @StateObject private var bleManager = BLEManager()
    
    var body: some View {
        VStack {
            FileExplorerView()
                .frame(maxHeight: .infinity)
            
            Divider()
            
            BluetoothConsoleView(bleManager: bleManager)
                .frame(height: 200)
        }
        .padding()
    }
}

// MARK: - File Preview View
struct FilePreviewView: View {
    let file: ReceivedFile
    
    var body: some View {
        Group {
            switch file.fileType {
            case .jpg:
                if let image = UIImage(contentsOfFile: file.url.path) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            case .wav:
                AudioPlayerView(url: file.url)
            }
        }
    }
}

struct AudioPlayerView: View {
    let url: URL
    @State private var player: AVPlayer?
    
    var body: some View {
        VStack {
            if let player = player {
                VideoPlayer(player: player)
                    .frame(height: 50)
            }
        }
        .onAppear {
            player = AVPlayer(url: url)
        }
        .onDisappear {
            player?.pause()
            player = nil
        }
    }
}

