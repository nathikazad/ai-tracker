//
//  iOSToWatch.swift
//  History
//
//  Created by Nathik Azad on 3/17/24.
//

import Foundation
import WatchConnectivity

var watch: WatchCommunicator {
    return WatchCommunicator.shared
}

class WatchCommunicator: NSObject, WCSessionDelegate, ObservableObject {
    static let shared = WatchCommunicator()
    var session: WCSession
    
    override init() {
        self.session = WCSession.default
        super.init()
        if WCSession.isSupported() {
            self.session = WCSession.default
            self.session.delegate = self
            self.session.activate()
        } else {
            print("WatchCommunicator not supported")
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        switch activationState {
        case .activated:
            if session.isReachable {
                print("Watch is reachable.")
            } else {
                print("Watch is not reachable, but session is activated.")
            }
        case .inactive, .notActivated:
            print("WCSession failed to activate.")
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        @unknown default:
            fatalError("A new case was added that needs to be handled.")
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        // Handle the received message
        print("received something")
        if let messageContent = message["data"] as? String {
            print("Received message: \(messageContent)")
            sync()
        }
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        if session.isReachable {
            print("Watch became reachable.")
            sync()
        } else {
            print("Watch became unreachable.")
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    
    func sync() {
        print("sending data to watch")
        if session.isReachable {
            print("watch reachable")
            let userId = auth.hasuraJWTObject?.userId
            let message = ["hasuraJwt": auth.hasuraJwt ?? "nil", "userId": (userId != nil) ? String(userId!) : "nil"]
            session.sendMessage(message as [String : Any], replyHandler: nil) { (error) in
                print(error.localizedDescription)
            }
        } else {
            print("watch not reachable")
        }
    }
}

