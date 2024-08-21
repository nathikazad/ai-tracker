//
//  HistoryApp.swift
//  History
//
//  Created by Nathik Azad on 3/17/24.
//

import SwiftUI


@main
struct HistoryApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
//    private var locationManager = LocationManager.shared
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    var foregroundObserver: NSObjectProtocol?
    var backgroundObserver: NSObjectProtocol?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        foregroundObserver = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { _ in
            print("entered foreground")
            if(auth.areJwtSet) {
                Task {
                    await auth.checkAndReloadHasuraJwt()
                    // print("calling setup from foreground observer")
                    Hasura.shared.setup()
                    await ServerCommunicator.processPendingRequests()
//                    LocationManager.shared.forceUpdateLocation()
                    state.inForeground = true
//                    print("Health kit enabled: \(HealthKitManager.shared.authorized)")
                }
            }
            
        }
        backgroundObserver = NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) { _ in
            print("entered background")
            state.inForeground = false
            Hasura.shared.pause()
        }
        
        // Check if launched from notification
        let notificationOption = launchOptions?[.remoteNotification]
        if
          let notification = notificationOption as? [String: AnyObject],
          let aps = notification["aps"] as? [String: AnyObject] {
            print("new notification")
            print(aps)
        }

        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        if let observerf = foregroundObserver {
            NotificationCenter.default.removeObserver(observerf)
            foregroundObserver = nil
        }
        if let observerb = backgroundObserver {
            NotificationCenter.default.removeObserver(observerb)
            backgroundObserver = nil
        }
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        Task {
            await UserController.updateUserAPNSToken(token: token)
            auth.user?.deviceToken = token
        }
        auth.user?.deviceToken = token
        print("Device Token: \(token)")
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("Failed to register: \(error)")
    }
    
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler:
        @escaping (UIBackgroundFetchResult) -> Void
    ) {
        guard let aps = userInfo["aps"] as? [String: AnyObject] else {
            completionHandler(.failed)
            return
        }
        print("New notification foreground/background")
    }
}


