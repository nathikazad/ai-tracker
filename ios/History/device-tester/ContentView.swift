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

// MARK: - Models
struct ReceivedFile: Identifiable, Codable {
    let id: UUID
    let filepath: String
    let dateReceived: Date
    let fileType: FileType
    
    var url: URL? {
        FileManager.receivedFilesDirectory?.appendingPathComponent(filepath)
    }
    
    enum FileType: String, Codable {
        case wav
        case jpg
        
        var icon: String {
            switch self {
            case .wav: return "waveform"
            case .jpg: return "photo"
            }
        }
    }
    
    static func getFileType(from filename: String) -> FileType {
        if filename.lowercased().hasSuffix(".wav") {
            return .wav
        }
        return .jpg
    }
}

// MARK: - File Explorer View
// Update FileExplorerView to load files
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
            if let url = file.url {
                if  file.fileType == .jpg {
                    ImagePreviewView(file: file)
                } else if  file.fileType == .wav {
                    AudioPlayerView(url: url)
                }
            }
        }
        .onAppear {
            loadFiles()
        }
        .onReceive(NotificationCenter.default.publisher(for: .newFileReceived)) { _ in
            loadFiles()
        }
    }
    
    private func loadFiles() {
        files = BLEManager.loadFileMetadata().sorted(by: { $0.dateReceived > $1.dateReceived })
    }
}

struct FileRow: View {
    let file: ReceivedFile
    
    var body: some View {
        HStack {
            Image(systemName: file.fileType.icon)
            VStack(alignment: .leading) {
                Text(file.url!.lastPathComponent)
                HStack {
                    Text(file.dateReceived, format: .dateTime.day().month().year())
                    Text(file.dateReceived, format: .dateTime.hour().minute().second())
                }
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
struct ImagePreviewView: View {
    let file: ReceivedFile
    
    var body: some View {
        Group {
            if let url = file.url, let image = UIImage(contentsOfFile: url.path) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        }
    }
}
