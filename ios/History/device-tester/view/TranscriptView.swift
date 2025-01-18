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

class TranscriptViewModel: ObservableObject {
    @Published var transcript: String = ""
    private let filePath: String
    
    init(filePath: String) {
        self.filePath = filePath
        setupNotificationObserver()
        readTranscript() // Initial read
    }
    
    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTranscriptUpdate),
            name: .transcriptDidUpdate,
            object: nil
        )
    }
    
    @objc private func handleTranscriptUpdate(_ notification: Notification) {
        guard let notificationFilePath = notification.userInfo?[TranscriptNotification.filePathKey] as? String,
              notificationFilePath == filePath else {
            return // Skip if filename doesn't match
        }
        
        readTranscript()
    }
    
    private func readTranscript() {
        guard let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?
            .appendingPathComponent("ReceivedFiles").appendingPathComponent(filePath).path else { return }
        
        do {
            let content = try String(contentsOfFile: path, encoding: .utf8)
            DispatchQueue.main.async {
                self.transcript = content
            }
        } catch {
            print("Error reading file: \(error)")
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

struct TranscriptView: View {
    @StateObject private var viewModel: TranscriptViewModel
    @State private var scrollProxy: ScrollViewProxy?
    @State private var lastContentHeight: CGFloat = 0
    
    init(filePath: String) {
        _viewModel = StateObject(wrappedValue: TranscriptViewModel(filePath: filePath))
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                Text(viewModel.transcript)
                    .font(.system(.body, design: .monospaced))
                    .padding()
                    .id("transcriptText")
                    .background(
                        GeometryReader { geometry in
                            Color.clear.preference(
                                key: ContentHeightPreferenceKey.self,
                                value: geometry.size.height
                            )
                        }
                    )
            }
            .onPreferenceChange(ContentHeightPreferenceKey.self) { height in
                if lastContentHeight > 0 {
                    // Only maintain scroll position if content was already present
                    let difference = height - lastContentHeight
                    if difference > 0 {
                        withAnimation {
                            proxy.scrollTo("transcriptText", anchor: .bottom)
                        }
                    }
                }
                lastContentHeight = height
            }
            .onAppear {
                scrollProxy = proxy
            }
        }
    }
}
