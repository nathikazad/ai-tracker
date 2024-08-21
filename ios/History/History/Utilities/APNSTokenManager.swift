//
//  APNSTokenManager.swift
//  History
//
//  Created by Nathik Azad on 8/21/24.
//

import Foundation
import UIKit
class APNSTokenManager {
    static let shared = APNSTokenManager()
    private var tokenCompletion: ((Result<String, Error>) -> Void)?
    private var timeoutWork: DispatchWorkItem?
    
    private init() {}
    
    func getAPNSToken() async throws -> String {
        if let token = UserDefaults.standard.string(forKey: "APNSToken") {
            return token
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            self.tokenCompletion = { result in
                self.timeoutWork?.cancel()
                self.timeoutWork = nil
                continuation.resume(with: result)
                self.tokenCompletion = nil
            }
            
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
            
            // Set a timeout
            let timeoutWork = DispatchWorkItem {
                self.tokenCompletion?(.failure(NSError(domain: "APNSTokenError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Timeout while waiting for APNS token"])))
                self.tokenCompletion = nil
            }
            self.timeoutWork = timeoutWork
            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0, execute: timeoutWork)
        }
    }
    
    func didRegisterForRemoteNotifications(withDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        
        UserDefaults.standard.set(token, forKey: "APNSToken")
        
        self.tokenCompletion?(.success(token))
        self.tokenCompletion = nil
        self.timeoutWork?.cancel()
        self.timeoutWork = nil
    }
    
    func didFailToRegisterForRemoteNotifications(withError error: Error) {
        self.tokenCompletion?(.failure(error))
        self.tokenCompletion = nil
        self.timeoutWork?.cancel()
        self.timeoutWork = nil
    }
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                print("Permission granted: \(granted)")
                guard granted else { return }
                Task {
                    do {
                        let token = try await self.getAPNSToken()
                        print("token \(token)")
                        await UserController.updateUserAPNSToken(token: token)
                        auth.user?.deviceToken = token
                    } catch {
                        print("token retrieval error")
                    }
                }
            }
    }
    
    func unregisterForPushNotifications() {
        DispatchQueue.main.async {
            UIApplication.shared.unregisterForRemoteNotifications()
        }
        Task {
            await UserController.updateUserAPNSToken(token: nil)
            auth.user?.deviceToken = nil
        }
    }
    
    func getNotificationSettings(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            let isAuthorized = settings.authorizationStatus == .authorized
            completion(isAuthorized)
        }
    }
}
