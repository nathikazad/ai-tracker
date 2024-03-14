import UIKit
import Flutter
import flutter_local_notifications


extension Notification.Name {
    static let triggerLogBreakMethod = Notification.Name("triggerLogBreakMethod")
}

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    var channel: FlutterMethodChannel?
    
    private func registerCustomMethodChannel(with controller: FlutterViewController) {
        BreakLoggerShortcuts.updateAppShortcutParameters()
        channel = FlutterMethodChannel(name: "com.improve/intents",
                                           binaryMessenger: controller.binaryMessenger)
        channel?.setMethodCallHandler { [weak self] (call, result) in
          print("Received on swift side, sending back")

          self?.channel?.invokeMethod("logBreak", arguments: nil) { (response) in
              print(response as? String ?? "No response from Flutter")
          }
          guard call.method == "logBreak" else {
              result(FlutterMethodNotImplemented)
              return
          }
          result(nil)
        }
          
      }
    
    private func setupNotificationListener() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleLogBreakNotification), name: .triggerLogBreakMethod, object: nil)
    }
    
    @objc func handleLogBreakNotification(_ notification: Notification) {
         if let userInfo = notification.userInfo, let text = userInfo["text"] as? String {
             channel?.invokeMethod("sendMessageToAi", arguments: text) { (response) in
                 print(response as? String ?? "No response from Flutter")
             }
         }
     }

    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
        //   GeneratedPluginRegistrant.register(with: registry)
        // }
        let controller = window?.rootViewController as! FlutterViewController
        registerCustomMethodChannel(with: controller)
        setupNotificationListener()
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}


import AppIntents

struct LogBreakIntent: AppIntent {
  @Parameter(title: "Message")
  var text: String
  static let title: LocalizedStringResource = "Message"

  
  func perform() async throws -> some ProvidesDialog {
    print("Perform")
      let userInfo = ["text": self.text]
      NotificationCenter.default.post(name: .triggerLogBreakMethod, object: nil, userInfo: userInfo)
    return .result(dialog: "You said: \(self.text)")
  }
}

struct BreakLoggerShortcuts: AppShortcutsProvider {
  static var appShortcuts: [AppShortcut] {
    AppShortcut(
        
      intent: LogBreakIntent(),
      phrases: [
        "Send to tracker",
        "Record in \(.applicationName)",
//        "Start a \(\.$breakIncrement) break with \(.applicationName)"
      ]
    )
  }
}
