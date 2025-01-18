import SwiftUI
import Combine

// Notification name for transcript updates
extension Notification.Name {
    static let transcriptDidUpdate = Notification.Name("transcriptDidUpdate")
}

// Notification user info keys
enum TranscriptNotification {
    static let filePathKey = "filePath"
}

// Preference key for tracking content height
struct ContentHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct TranscriptMessage: Identifiable, Equatable {
    let id = UUID()
    let speaker: String
    let epochTime: TimeInterval
    let text: String
    
    var formattedTime: String {
        let date = Date(timeIntervalSince1970: epochTime)
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mma"
        return formatter.string(from: date).lowercased()
    }
}

struct MessageGroup: Identifiable {
    let id = UUID()
    let speaker: String
    let messages: [TranscriptMessage]
}

class TranscriptViewModel: ObservableObject {
    @Published var messageGroups: [MessageGroup] = []
    @Published var currentFocusedTime: TimeInterval?
    @Published var currentImage: UIImage?
    private let folderPath: String
    
    init(folderName: String) {
        self.folderPath = folderName
        setupNotificationObserver()
        readTranscript()
    }
    
    private func updateCurrentImage() {
        guard let currentTime = currentFocusedTime else {
            currentImage = nil
            return
        }
        
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let folderURL = documentsPath.appendingPathComponent("ReceivedFiles").appendingPathComponent(folderPath)
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil)
            
            let imageURLs = fileURLs.filter { $0.pathExtension.lowercased() == "jpg" }
//            print(imageURLs)
            // Extract timestamps from filenames and find the closest previous one
            let timestamps = imageURLs.compactMap { url -> (TimeInterval, URL)? in
                let filename = url.deletingPathExtension().lastPathComponent
                guard let timestamp = TimeInterval(filename) else { return nil }
                return (timestamp, url)
            }.sorted { $0.0 < $1.0 }
            
            let closestPrevious = timestamps.last { $0.0 <= currentTime }
            
            if let (_, imageURL) = closestPrevious,
               let imageData = try? Data(contentsOf: imageURL),
               let image = UIImage(data: imageData) {
                DispatchQueue.main.async {
                    print("Assigning image \(image)")
                    self.currentImage = image
                }
            } else {
                DispatchQueue.main.async {
                    print("Assigning image to nil")
                    if(self.currentImage == nil && !imageURLs.isEmpty) {
                        if let imageData = try? Data(contentsOf: imageURLs[0]),
                           let image = UIImage(data: imageData) {
                            print("Assigning image \(image)")
                            self.currentImage = image
                        }
                    }
                }
            }
        } catch {
            print("Error accessing directory: \(error)")
            DispatchQueue.main.async {
                self.currentImage = nil
            }
        }
    }
    
    @objc private func handleTranscriptUpdate(_ notification: Notification) {
        print("handleTranscriptUpdate \(notification.userInfo?[TranscriptNotification.filePathKey] as? String)")
        guard let notificationFilePath = notification.userInfo?[TranscriptNotification.filePathKey] as? String,
              notificationFilePath == folderPath else {
            return
        }
        readTranscript()
    }
    
    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTranscriptUpdate),
            name: .transcriptDidUpdate,
            object: nil
        )
    }
    
    
    private func parseTranscript(_ content: String) -> [MessageGroup] {
        let lines = content.components(separatedBy: .newlines)
        var messages: [TranscriptMessage] = []
        
        for line in lines {
            let components = line.components(separatedBy: ":")
            guard components.count >= 3 else { continue }
            
            let speaker = components[0]
            guard let epochTime = TimeInterval(components[1]) else { continue }
            let text = components[2...].joined(separator: ":")
            
            let message = TranscriptMessage(speaker: speaker, epochTime: epochTime, text: text)
            messages.append(message)
        }
        
        // Group messages by speaker
        var groups: [MessageGroup] = []
        var currentSpeaker = ""
        var currentMessages: [TranscriptMessage] = []
        
        for message in messages {
            if message.speaker != currentSpeaker {
                if !currentMessages.isEmpty {
                    groups.append(MessageGroup(speaker: currentSpeaker, messages: currentMessages))
                }
                currentSpeaker = message.speaker
                currentMessages = [message]
            } else {
                currentMessages.append(message)
            }
        }
        
        if !currentMessages.isEmpty {
            groups.append(MessageGroup(speaker: currentSpeaker, messages: currentMessages))
        }
        
        return groups
    }
    
    private func readTranscript() {
        guard let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?
            .appendingPathComponent("ReceivedFiles").appendingPathComponent(folderPath).appendingPathComponent("transcript.txt").path else { return }
        
        do {
            let content = try String(contentsOfFile: path, encoding: .utf8)
            DispatchQueue.main.async {
                print("Count of messageGroups: \(self.messageGroups.count)")
                self.messageGroups = self.parseTranscript(content)
            }
        } catch {
            print("Error reading file: \(error)")
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setCurrentFocusedTime(_ time: TimeInterval?) {
            currentFocusedTime = time
            print("Calling setCurrentFocusedTime")
            updateCurrentImage()
        }
}

struct TranscriptView: View {
    @StateObject private var viewModel: TranscriptViewModel
    
    init(folderName: String) {
        _viewModel = StateObject(wrappedValue: TranscriptViewModel(folderName: folderName))
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 16) {
                        ForEach(viewModel.messageGroups.flatMap { group -> [(MessageGroup, TranscriptMessage)] in
                            group.messages.map { (group, $0) }
                        }, id: \.1.id) { group, message in
                            if group.messages.first?.id == message.id {
                                // Header for first message in group
                                HStack {
                                    Text(group.speaker)
                                        .font(.headline)
                                        .foregroundColor(.blue)
                                    
                                    Text(message.formattedTime)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                .padding(.bottom, 4)
                                .padding(.horizontal)
                            }
                            
                            Text(message.text)
                                .font(.system(.body, design: .monospaced))
                                .padding(.horizontal)
                                .id(message.id)
                                .onAppear {
                                    print("Message appeared:")
                                    viewModel.setCurrentFocusedTime(message.epochTime)
                                }
                        }
                    }
                    .padding(.vertical)
                }
            }
            
            // Image overlay
            if let image = viewModel.currentImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                            .shadow(radius: 2)
                    )
                    .padding([.top, .trailing], 16)
            }
        }
    }
}
