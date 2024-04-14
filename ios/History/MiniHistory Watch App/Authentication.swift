//
//  Authentication.swift
//  MiniHistory Watch App
//
//  Created by Nathik Azad on 4/13/24.
//

import Foundation
class Authentication {
    static let shared = Authentication()
    
    private let hasuraJwtKey = "hasuraJWTKey"
    private let userIdKey = "userIdKey"
    
    var hasuraJwt: String? {
        get {
            UserDefaults.standard.string(forKey: hasuraJwtKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: hasuraJwtKey)
        }
    }
    
    var userId: Int? {
        get {
            UserDefaults.standard.integer(forKey: userIdKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: userIdKey)
        }
    }
}
