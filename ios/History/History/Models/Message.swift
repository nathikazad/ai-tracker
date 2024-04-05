//
//  Message.swift
//  History
//
//  Created by Nathik Azad on 4/5/24.
//

import Foundation

struct Message: Decodable, Identifiable {
    var id = UUID()
    let userUid: String
    let text: String
    let photoURL: String
    let createdAt: Date
    
    func isFromCurrentUser() -> Bool {
        return false
    }
}
