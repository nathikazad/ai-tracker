import AppIntents

struct ConfigurationAppIntent: AppIntent {
    static let title: LocalizedStringResource = "Get Address"
    init() {
        print("init")
        NotificationCenter.default.post(name: .startListeningNotification, object: nil)
    }
    func perform()  async throws -> some IntentResult {
        print("perform")
        
        return .result()
    }
}

extension Notification.Name {
    static let startListeningNotification = Notification.Name("startListeningNotification")
}
