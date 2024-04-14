//
//  WatchToiOS.swift
//  MiniHistory Watch App
//
//  Created by Nathik Azad on 3/17/24.
//

import WatchConnectivity
import Foundation


class PhoneCommunicator: NSObject, WCSessionDelegate, ObservableObject {
    static let shared = PhoneCommunicator()
    var session: WCSession
    
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        self.session.delegate = self
        self.session.activate()
        print("PhoneCommunicator activated")
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WC Session activation failed with error: \(error.localizedDescription)")
            return
        }
        print("WC Session activated with state: \(activationState.rawValue)")
    }
    
    func sendDataToiOS(data: String) {
        if session.isReachable {
            let dict: [String: Any] = ["data": data]
            session.sendMessage(dict, replyHandler: { response in
                print("Received reply from iOS: \(response)")
            }, errorHandler: { error in
                print("Error sending message: \(error.localizedDescription)")
            })
        } else {
            print("Session is not reachable.")
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            // Update UI or process data here
            print("Received message: \(message)")
            
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
