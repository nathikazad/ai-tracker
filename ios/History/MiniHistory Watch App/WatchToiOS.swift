//
//  WatchToiOS.swift
//  MiniHistory Watch App
//
//  Created by Nathik Azad on 3/17/24.
//

import Foundation
import WatchConnectivity

class WatchToiOS: NSObject, WCSessionDelegate, ObservableObject {
    var session: WCSession
    
    init(session:WCSession = .default) {
        self.session = session
        super.init()
        session.delegate = self
        session.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func sendDataToiOS(data: String) {
        print("sending data")
        if session.isReachable {
            let dict: [String: Any] = [
                "data": data
            ]
            session.sendMessage(dict, replyHandler: nil)
        } else {
            print("session is not reachable")
        }
    }
}
