import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  private func registerCustomMethodChannel(with controller: FlutterViewController) {
    BreakLoggerShortcuts.updateAppShortcutParameters()
    let channel = FlutterMethodChannel(name: "com.improve/intents",
                                       binaryMessenger: controller.binaryMessenger)
    channel.setMethodCallHandler { [weak self] (call, result) in
      print("Received on swift side, sending back")

      channel.invokeMethod("logBreak", arguments: nil) { (response) in
          print(response as? String ?? "No response from Flutter")
      }
      guard call.method == "logBreak" else {
        result(FlutterMethodNotImplemented)
        return
      }
//      self?.logBreak() // Call your intent here
      result(nil)
    }
      
  }

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window.rootViewController as! FlutterViewController
    registerCustomMethodChannel(with: controller)
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}



import AppIntents

struct LogBreakIntent: AppIntent {
    static let title: LocalizedStringResource = "Log Media File Size"

    
    func perform() async throws -> some ProvidesDialog {
        return .result(dialog: "Magic Text")
    }
}

struct BreakLoggerShortcuts: AppShortcutsProvider {
  static var appShortcuts: [AppShortcut] {
    AppShortcut(
      intent: LogBreakIntent(),
      phrases: [
        "Log a break",
        "Log a \(.applicationName) breaks",
//        "Start a \(\.$breakIncrement) break with \(.applicationName)"
      ]
    )
  }
}
