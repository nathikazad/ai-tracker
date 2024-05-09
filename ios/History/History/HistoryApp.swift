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
    private var locationManager = LocationManager.shared
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
            if(Authentication.shared.areJwtSet) {
                Task {
                    await Authentication.shared.checkAndReloadHasuraJwt()
                    // print("calling setup from foreground observer")
                    Hasura.shared.setup()
                    await ServerCommunicator.processPendingRequests()
                    LocationManager.shared.forceUpdateLocation()
                    print("Health kit enabled: \(HealthKitManager.shared.authorized)")
                }
            }
            
        }
        backgroundObserver = NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) { _ in
            print("entered background")
            Hasura.shared.pause()
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
}


