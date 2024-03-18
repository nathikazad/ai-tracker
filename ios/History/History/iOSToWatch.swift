//
//  iOSToWatch.swift
//  History
//
//  Created by Nathik Azad on 3/17/24.
//

import Foundation
import WatchConnectivity

class iOSToWatch: NSObject, WCSessionDelegate, ObservableObject {
    var session: WCSession
    
    init(session:WCSession = .default) {
        self.session = session
        super.init()
        session.delegate = self
        session.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print(message)
    }
    

}

