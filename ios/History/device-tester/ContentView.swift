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
struct ReceivedFile: Identifiable, Codable, Equatable {
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
    
    static func == (lhs: ReceivedFile, rhs: ReceivedFile) -> Bool {
            // Compare the properties that make a file unique
            return lhs.dateReceived == rhs.dateReceived &&
                   lhs.url == rhs.url &&
                   lhs.fileType == rhs.fileType
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
                Text("\(bleManager.connectionState)")
            }
            
            if bleManager.isReceiving {
                VStack(alignment: .leading) {
                    Text("Receiving file...")
                    ProgressView(value: bleManager.progressPercentage, total: 100)
                    Text("\(bleManager.receivedPackets)/\(bleManager.totalPackets) packets")
                }
            }
            
            if bleManager.lastError != nil {
                Text("Last Error: \(bleManager.lastError!)")
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
//        VStack {
            TimelineExplorerView()
                .frame(maxHeight: .infinity)
            
//            Divider()
//            
//            BluetoothConsoleView(bleManager: bleManager)
//                .frame(height: 100)
//        }
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
