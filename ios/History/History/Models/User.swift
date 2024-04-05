//
//  User.swift
//  History
//
//  Created by Nathik Azad on 4/5/24.
//

import Foundation
import AuthenticationServices
class User {
    static let shared = User()
    
    private let jwtKey = "userJWTKey" // Key for UserDefaults
    
    private init() {
        // Attempt to load the JWT from UserDefaults upon initialization
        self.jwt = UserDefaults.standard.string(forKey: jwtKey)
    }
    
    private var jwt: String? {
        didSet {
            if let jwt = jwt {
                // Save to UserDefaults if jwt is not nil
                UserDefaults.standard.set(jwt, forKey: jwtKey)
            } else {
                // If jwt is nil, remove it from UserDefaults
                UserDefaults.standard.removeObject(forKey: jwtKey)
            }
        }
    }
    
    func setJWT(_ key: String) {
        self.jwt = key
    }
    
    var getJWT: String? {
        return jwt
    }
    
    // Add a method to clear the JWT
    func clearJWT() {
        self.jwt = nil // This will also clear it from UserDefaults
    }
}

func handleSignIn(result: Result<ASAuthorization, any Error>, completion: @escaping (Bool) -> Void) {
   switch result {
       case .success(let authResults):
           print("Authorisation successful")
           guard let credentials = authResults.credential as? ASAuthorizationAppleIDCredential, let identityToken = credentials.identityToken, let identityTokenString = String(data: identityToken, encoding: .utf8) else {
                   completion(false)
                   return
               }
               print(identityTokenString)
               sendAppleKeyToServer(appleKey: identityTokenString) { isSuccess in
                   completion(isSuccess)
               }
        case .failure(let error):
            print("Authorisation failed: \(error.localizedDescription)")
            completion(false)
        
   }
}

private func sendAppleKeyToServer(appleKey: String, completion: @escaping (Bool) -> Void) {
    guard let url = URL(string: "https://ai-tracker-server-613e3dd103bb.herokuapp.com/hasuraJWT") else {
        completion(false)
        return
    }
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let body: [String: Any] = ["appleKey": appleKey]
    request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data = data, error == nil else {
            print("Error sending apple key to server: \(error?.localizedDescription ?? "Unknown error")")
            completion(false)
            return
        }
        
        do {
            if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let jwt = jsonResponse["jwt"] as? String {
                User.shared.setJWT(jwt)
                print("JWT: \(jwt)")
                completion(true)
            } else {
                print("Invalid response received from the server")
                completion(false)
            }
        } catch {
            print("Error parsing server response: \(error.localizedDescription)")
            completion(false)
        }
    }
    task.resume()
}


// User.shared.setJWTKey("your_jwt_token_here")
// if let jwtKey = User.shared.getJWTKey {
