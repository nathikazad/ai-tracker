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
    
    private var sortedTimestamps: [(file: ReceivedFile, timestamp: Double)] {
        selectedFiles.map { file in
            (file, file.dateReceived.timeIntervalSince1970)
        }
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
    
    private var currentTimeFile: ReceivedFile? {
        sortedTimestamps.last { $0.timestamp <= currentTime }?.file
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
                        let currentAudio = sortedTimestamps.first { file in
                            guard file.file.fileType == .wav else { return false }
                            let audioEndTime = file.timestamp + 20 // 20 seconds duration
                            return currentTime >= file.timestamp && currentTime <= audioEndTime
                        }

                        let currentImage = sortedTimestamps.last { file in
                            guard file.file.fileType == .jpg else { return false }
                            return file.timestamp <= currentTime
                        }

                        VStack {
                            if let audioFile = currentAudio?.file,
                               let url = audioFile.url {
                                AudioPlayerView(url: url)
                                    .frame(height: currentImage != nil ? geometry.size.height * 0.4 : geometry.size.height * 0.8)
                            }
                            
                            if let imageFile = currentImage?.file {
                                ImagePreviewView(file: imageFile)
                                    .frame(height: currentAudio != nil ? geometry.size.height * 0.4 : geometry.size.height * 0.8)
                            }
                            
                            if currentAudio == nil && currentImage == nil {
                                Text("No media selected")
                                    .foregroundColor(.secondary)
                                    .frame(height: geometry.size.height * 0.8)
                            }
                        }
                        
                        // Timeline Control
                        VStack {
                            TimelineSlider(value: $currentTime,
                                         in: timeRange,
                                         step: 1,
                                         marks: visibleMarks)
                                .onChange(of: currentTime) {
                                    if let file = currentTimeFile {
                                        selectedIndex = selectedFiles.firstIndex(where: {
                                            $0.dateReceived == file.dateReceived &&
                                            $0.url == file.url &&
                                            $0.fileType == file.fileType
                                        }) ?? 0
                                    }
                                }
                            
                            // Navigation Controls
                            // Navigation Controls
                            HStack {
                                Button(action: {
                                    if let prevTimestamp = sortedTimestamps.last(where: { $0.timestamp < currentTime }) {
                                        currentTime = prevTimestamp.timestamp
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
                                .disabled(selectedFiles.count < 2)
                                
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
                                if let currentFile = currentTimeFile {
                                    Text(currentFile.dateReceived, format: .dateTime.hour().minute().second())
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    if let nextTimestamp = sortedTimestamps.first(where: { $0.timestamp > currentTime }) {
                                        currentTime = nextTimestamp.timestamp
                                    }
                                }) {
                                    Image(systemName: "chevron.right")
                                        .imageScale(.large)
                                }
                                .disabled(currentTime >= maxTime || isLiveMode)
                            }
                            .padding(.horizontal)
                            
                            // File counter
                            Text("\(selectedIndex + 1) of \(selectedFiles.count)")
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
