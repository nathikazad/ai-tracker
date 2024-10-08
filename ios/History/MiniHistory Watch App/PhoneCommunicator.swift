//
//  WatchToiOS.swift
//  MiniHistory Watch App
//
//  Created by Nathik Azad on 3/17/24.
//

import WatchConnectivity
import Foundation


class PhoneCommunicator: NSObject, WCSessionDelegate, ObservableObject {
    var session: WCSession
    
    override init() {
        print("PhoneCommunicator init")
        self.session = WCSession.default
        super.init()
        if WCSession.isSupported() {
            self.session = WCSession.default
            self.session.delegate = self
            self.session.activate()
        } else {
            print("PhoneCommunicator not supported")
        }
    }
    
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        switch activationState {
        case .activated:
            if session.isReachable {
                print("Phone is reachable.")
            } else {
                print("Phone is not reachable, but session is activated.")
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
    
    
    func sendDataToiOS() {
        
        if(session.isReachable && Authentication.shared.hasuraJwt == nil) {
            print("sending data to iOS")
            let dict: [String: Any] = ["data": "send me jwt"]
            session.sendMessage(dict, replyHandler: nil, errorHandler: { error in
                print("Error sending message: \(error.localizedDescription)")
            })
        }
        
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        if session.isReachable {
            print("Phone became reachable.")
            sendDataToiOS()
        } else {
            print("Phone became unreachable.")
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            // Update UI or process data here
            print("Received message from phone")
            
            // Extract jwtToken handling string "nil"
            if let jwt = message["hasuraJwt"] as? String, jwt != "nil" {
                Authentication.shared.hasuraJwt =  jwt
            } else {
                Authentication.shared.hasuraJwt =  nil
            }
            
            // Extract userId handling string "nil" and converting to Int
            if let userIdString = message["userId"] as? String, userIdString != "nil", let userId = Int(userIdString) {
                Authentication.shared.userId = userId
            } else {
                Authentication.shared.userId = nil
            }

        }
    }
}
