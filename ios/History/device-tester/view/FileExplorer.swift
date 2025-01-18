//
//  FileExplorer.swift
//  device-tester
//
//  Created by Nathik Azad on 1/1/25.
//

import SwiftUI
// MARK: - File Explorer View
// Update FileExplorerView to load files
// Create a date selector view
struct DateSelectorView: View {
    @Binding var selectedDate: Date
    
    var body: some View {
        HStack {
            
            Text(selectedDate.formatted(date: .abbreviated, time: .omitted))
                .foregroundColor(.primary)

            
            Spacer()
            
            Menu {
                Button("Today") {
                    selectedDate = Date()
                }
                
                Button("Yesterday") {
                    selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
                }
                
                Button("Select Date...") {
                    // This will be handled by the date picker sheet
                    showDatePicker = true
                }
            } label: {
                Image(systemName: "calendar")
                    .foregroundColor(.accentColor)
            }
        }
        .padding(.horizontal)
        .sheet(isPresented: $showDatePicker) {
            DatePickerSheet(selectedDate: $selectedDate, isPresented: $showDatePicker)
        }
    }
    
    @State private var showDatePicker = false
}

// Create a custom date picker sheet
struct DatePickerSheet: View {
    @Binding var selectedDate: Date
    @Binding var isPresented: Bool
    @State private var tempDate = Date()
    
    var body: some View {
        NavigationView {
            DatePicker(
                "Select Date",
                selection: $tempDate,
                displayedComponents: [.date]
            )
            .datePickerStyle(.graphical)
            .navigationTitle("Choose Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        selectedDate = tempDate
                        isPresented = false
                    }
                }
            }
        }
    }
}

// MARK: - Timeline Explorer View
struct TimelineExplorerView: View {
    @State private var files: [ReceivedFile] = []
    @State private var selectedIndex: Int = 0
    @State private var selectedDate: Date = Date()
    @State private var currentTime: Double = 0
    @State private var isZoomed: Bool = false
    @State private var isLiveMode: Bool = false
    
    private var selectedFiles: [ReceivedFile] {
        files.filter { Calendar.current.isDate($0.dateReceived, inSameDayAs: selectedDate) }
            .sorted(by: { $0.dateReceived < $1.dateReceived })
    }
    
    // Group files by their prefix timestamp and ensure uniqueness
    private var sortedTimestamps: [(timestamp: Double, imageFile: ReceivedFile?, audioFile: ReceivedFile?)] {
        let groupedFiles = Dictionary(grouping: selectedFiles) { file -> String in
            // Extract prefix before the period
            String(file.url?.lastPathComponent.split(separator: ".").first ?? "")
        }
        
        return groupedFiles.map { prefix, files in
            let imageFile = files.first { $0.fileType == .jpg }
            let audioFile = files.first { $0.fileType == .wav }
            // Use the timestamp from any file in the group since they share the same prefix
            let timestamp = (imageFile ?? audioFile)?.dateReceived.timeIntervalSince1970 ?? 0
            return (timestamp: timestamp, imageFile: imageFile, audioFile: audioFile)
        }.sorted { $0.timestamp < $1.timestamp }
    }
    
    private var timeRange: ClosedRange<Double> {
        if isZoomed {
            let zoomStart = max(minTime, currentTime - 3600) // -60 minutes
            let zoomEnd = min(maxTime, currentTime + 3600)   // +60 minutes
            return zoomStart...zoomEnd
        } else {
            return minTime...maxTime
        }
    }
    
    private var minTime: Double { sortedTimestamps.first?.timestamp ?? 0 }
    private var maxTime: Double { sortedTimestamps.last?.timestamp ?? 0 }
    
    private var currentTimeFiles: (imageFile: ReceivedFile?, audioFile: ReceivedFile?)? {
        sortedTimestamps.last { $0.timestamp <= currentTime }
            .map { (imageFile: $0.imageFile, audioFile: $0.audioFile) }
    }
    
    private var visibleMarks: [Double] {
        if isZoomed {
            return sortedTimestamps
                .map { $0.timestamp }
                .filter { $0 >= timeRange.lowerBound && $0 <= timeRange.upperBound }
        } else {
            return sortedTimestamps.map { $0.timestamp }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            DateSelectorView(selectedDate: $selectedDate)
                .padding(.vertical, 8)
            
            if !selectedFiles.isEmpty {
                GeometryReader { geometry in
                    VStack {
                        // Media Display Area
                        if let current = currentTimeFiles {
                            VStack {
                                if let audioFile = current.audioFile,
                                   let url = audioFile.url {
                                    AudioPlayerView(url: url)
                                        .id(url.absoluteString)
                                        .frame(height: current.imageFile != nil ?
                                            geometry.size.height * 0.4 : geometry.size.height * 0.8)
                                }
                                
                                if let imageFile = current.imageFile {
                                    ImagePreviewView(file: imageFile)
                                        .frame(height: current.audioFile != nil ?
                                            geometry.size.height * 0.4 : geometry.size.height * 0.8)
                                }
                            }
                        } else {
                            Text("No media selected")
                                .foregroundColor(.secondary)
                                .frame(height: geometry.size.height * 0.8)
                        }
                        
                        // Timeline Control
                        VStack {
                            TimelineSlider(value: $currentTime,
                                         in: timeRange,
                                         step: 1,
                                         marks: visibleMarks)
                                .onChange(of: currentTime) {
                                    if let index = sortedTimestamps.firstIndex(where: { $0.timestamp <= currentTime }) {
                                        selectedIndex = index
                                    }
                                }
                            
                            // Navigation Controls
                            HStack {
                                Button(action: {
                                    if let prevIndex = sortedTimestamps.lastIndex(where: { $0.timestamp < currentTime }) {
                                        currentTime = sortedTimestamps[prevIndex].timestamp
                                    }
                                }) {
                                    Image(systemName: "chevron.left")
                                        .imageScale(.large)
                                }
                                .disabled(currentTime <= minTime)
                                
                                Spacer()
                                
                                // Zoom Controls
                                Button(action: {
                                    withAnimation {
                                        isZoomed.toggle()
                                    }
                                }) {
                                    Image(systemName: isZoomed ? "minus.magnifyingglass" : "plus.magnifyingglass")
                                        .imageScale(.large)
                                }
                                .disabled(sortedTimestamps.count < 2)
                                
                                // Live Mode Button
                                Button(action: {
                                    withAnimation {
                                        isLiveMode.toggle()
                                        if isLiveMode {
                                            // Jump to latest content
                                            if let lastTimestamp = sortedTimestamps.last?.timestamp {
                                                currentTime = lastTimestamp
                                            }
                                        }
                                    }
                                }) {
                                    Image(systemName: "dot.radiowaves.left.and.right")
                                        .imageScale(.large)
                                        .foregroundColor(isLiveMode ? .red : .primary)
                                }
                                
                                Spacer()
                                
                                // Timestamp Display
                                if let current = currentTimeFiles {
                                    Text((current.imageFile ?? current.audioFile)?.dateReceived ?? Date(),
                                         format: .dateTime.hour().minute().second())
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    if let nextIndex = sortedTimestamps.firstIndex(where: { $0.timestamp > currentTime }) {
                                        currentTime = sortedTimestamps[nextIndex].timestamp
                                    }
                                }) {
                                    Image(systemName: "chevron.right")
                                        .imageScale(.large)
                                }
                                .disabled(currentTime >= maxTime)// || isLiveMode)
                            }
                            .padding(.horizontal)
                            
                            // File counter
                            Text("\(selectedIndex + 1) of \(sortedTimestamps.count)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    }
                }
            } else {
                Text("No files available for selected date")
                    .foregroundColor(.secondary)
                    .frame(maxHeight: .infinity)
            }
        }
        .onAppear {
            loadFiles()
            if let firstTimestamp = sortedTimestamps.first?.timestamp {
                currentTime = firstTimestamp
            }
        }
        .onChange(of: selectedDate) {
            loadFiles()
            selectedIndex = 0
            if let firstTimestamp = sortedTimestamps.first?.timestamp {
                currentTime = firstTimestamp
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .newFileReceived)) { _ in
            loadFiles()
            if isLiveMode {
                if let lastTimestamp = sortedTimestamps.last?.timestamp {
                    currentTime = lastTimestamp
                }
            }
        }
    }
    
    private func loadFiles() {
        files = BLEManager.loadFileMetadata(for: selectedDate)
    }
}
struct TimelineSlider: View {
    @Binding var value: Double
    let bounds: ClosedRange<Double>
    let step: Double
    let marks: [Double]
    
    init(value: Binding<Double>, in bounds: ClosedRange<Double>, step: Double, marks: [Double]) {
        self._value = value
        self.bounds = bounds
        self.step = step
        self.marks = marks
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 4)
                
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: self.getThumbPosition(in: geometry), height: 4)
                
                ForEach(marks, id: \.self) { mark in
                    Rectangle()
                        .fill(Color.black)
                        .frame(width: 2, height: 10)
                        .position(x: self.getMarkPosition(for: mark, in: geometry), y: 2)
                }
                
                Circle()
                    .fill(Color.gray)
                    .frame(width: 20, height: 20)
                    .position(x: self.getThumbPosition(in: geometry), y: 2)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { gesture in
                                let newValue = self.getValue(from: gesture.location.x, in: geometry)
                                self.value = min(max(newValue, self.bounds.lowerBound), self.bounds.upperBound)
                            }
                    )
            }
        }
        .frame(height: 20)
    }
    
    private func getThumbPosition(in geometry: GeometryProxy) -> CGFloat {
        let range = bounds.upperBound - bounds.lowerBound
        let percentage = (value - bounds.lowerBound) / range
        return geometry.size.width * CGFloat(percentage)
    }
    
    private func getMarkPosition(for mark: Double, in geometry: GeometryProxy) -> CGFloat {
        let range = bounds.upperBound - bounds.lowerBound
        let percentage = (mark - bounds.lowerBound) / range
        return geometry.size.width * CGFloat(percentage)
    }
    
    private func getValue(from position: CGFloat, in geometry: GeometryProxy) -> Double {
        let percentage = Double(position / geometry.size.width)
        let range = bounds.upperBound - bounds.lowerBound
        return bounds.lowerBound + range * percentage
    }
}

struct ReceivedFoldersView: View {
    @State private var selectedFolder: String?
    @State private var folders: [String] = []
    @State private var filesInSelectedFolder: [String] = []
    
    var body: some View {
        NavigationView {
            List {
                if selectedFolder == nil {
                    // Show folders
                    ForEach(folders, id: \.self) { folder in
                        NavigationLink(destination: TranscriptView(folderName: "\(folder)")) {
                            HStack {
                                Image(systemName: "folder")
                                    .foregroundColor(.blue)
                                Text(folder)
                                Spacer()
//                                Image(systemName: "chevron.right")
//                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 4)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                deleteFolder(folder)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                } else {
                    // Show files in selected folder
                    Button(action: {
                        selectedFolder = nil
                        filesInSelectedFolder = []
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back to Folders")
                        }
                    }
                    
                    ForEach(filesInSelectedFolder, id: \.self) { file in
                        HStack {
                            Image(systemName: "doc")
                                .foregroundColor(.gray)
                            Text(file)
                        }
                    }
                }
            }
            .navigationTitle(selectedFolder == nil ? "Received Files" : selectedFolder!)
            .onAppear {
                loadFolders()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .newFileReceived)) { _ in
            loadFolders()
            if let selectedFolder = selectedFolder {
                loadFilesInFolder(selectedFolder)
            }
//            if isLiveMode {
//                if let lastTimestamp = sortedTimestamps.last?.timestamp {
//                    currentTime = lastTimestamp
//                }
//            }
        }
    }
    
    private func deleteFolder(_ folderName: String) {
        guard let folderURL = FileManager.getDirectory(for: folderName) else {
            return
        }
        
        do {
            try FileManager.default.removeItem(at: folderURL)
            // Remove the folder from the list
            folders.removeAll { $0 == folderName }
        } catch {
            print("Error deleting folder: \(error)")
        }
    }
    
    private func loadFolders() {
        guard let receivedFilesURL = FileManager.receivedFilesDirectory else {
            return
        }
        
        do {
            let contents = try FileManager.default.contentsOfDirectory(
                at: receivedFilesURL,
                includingPropertiesForKeys: nil
            )
            
            folders = contents
                .filter { (try? $0.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true }
                .map { $0.lastPathComponent }
                .sorted(by: >)  // Sort in descending order
            
        } catch {
            print("Error loading folders: \(error)")
        }
    }
    
    private func loadFilesInFolder(_ folderName: String) {
        guard let folderURL = FileManager.getDirectory(for: folderName) else {
            return
        }
        
        do {
            let contents = try FileManager.default.contentsOfDirectory(
                at: folderURL,
                includingPropertiesForKeys: nil
            )
            
            filesInSelectedFolder = contents
                .map { $0.lastPathComponent }
                .sorted()
            
        } catch {
            print("Error loading files: \(error)")
        }
    }
}
