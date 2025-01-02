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

// Updated FileExplorerView
struct FileExplorerView: View {
    @State private var files: [ReceivedFile] = []
    @State private var selectedFile: ReceivedFile?
    @State private var selectedDate: Date = Date()
    
    var body: some View {
        VStack(spacing: 0) {
            DateSelectorView(selectedDate: $selectedDate)
                .padding(.vertical, 8)
            
            List(files) { file in
                FileRow(file: file)
                    .onTapGesture {
                        selectedFile = file
                    }
            }
        }
        .sheet(item: $selectedFile) { file in
            if let url = file.url {
                if file.fileType == .jpg {
                    ImagePreviewView(file: file)
                } else if file.fileType == .wav {
                    AudioPlayerView(url: url)
                }
            }
        }
        .onAppear {
            loadFiles()
        }
        .onChange(of: selectedDate) { 
            loadFiles()
        }
        .onReceive(NotificationCenter.default.publisher(for: .newFileReceived)) { _ in
            loadFiles()
        }
    }
    
    private func loadFiles() {
        files = BLEManager.loadFileMetadata(for: selectedDate)
            .sorted(by: { $0.dateReceived > $1.dateReceived })
    }
};

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
