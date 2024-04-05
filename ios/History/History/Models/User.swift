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
    
    private let hasuraJwtKey = "hasuraJWTKey"
    private let appleJwtKey = "appleJWTKey"
    
    private init() {
        
        
    }
    
    var hasuraJwt: String? {
        get {
            var jwt = UserDefaults.standard.string(forKey: hasuraJwtKey)
            if(UserDefaults.standard.string(forKey: hasuraJwtKey) != nil && UserDefaults.standard.string(forKey: appleJwtKey) != nil) {
                checkAndReloadHasuraJwt(jwt: jwt!)
            }
            return jwt
        }
        set {
            UserDefaults.standard.set(newValue, forKey: hasuraJwtKey)
        }
    }
    
    var appleJwt: String? {
        get {
            UserDefaults.standard.string(forKey: appleJwtKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: appleJwtKey)
        }
    }
    
    func checkAndReloadHasuraJwt(jwt: String) {
        if(isJwtExpired(jwt: jwt)){
            Task {
                await fetchHasuraJwt(appleJwt: appleJwt!)
            }
        }
    }

    
    func clearJWT() {
        UserDefaults.standard.removeObject(forKey: hasuraJwtKey)
        UserDefaults.standard.removeObject(forKey: appleJwtKey)
    }
}

func isJwtExpired(jwt: String?) -> Bool {
    guard let jwt = jwt else { return true }
    
    let parts = jwt.components(separatedBy: ".")
    guard parts.count > 1 else { return true }
    
    let payload = parts[1]
    guard let payloadData = base64UrlDecodedData(base64Url: payload) else { return true }
    
    do {
        if let payloadDict = try JSONSerialization.jsonObject(with: payloadData, options: []) as? [String: Any],
           let exp = payloadDict["exp"] as? TimeInterval {
            // Create a date for the current time plus one hour (3600 seconds).
            let oneHourAhead = Date().addingTimeInterval(3600)
            let expirationDate = Date(timeIntervalSince1970: exp)
            // Consider the token expired if the expiration date is less than one hour ahead.
            return expirationDate <= oneHourAhead
        }
    } catch {
        print("Error decoding JWT: \(error.localizedDescription)")
    }
    
    return true
}

private func base64UrlDecodedData(base64Url: String) -> Data? {
    var base64 = base64Url
        .replacingOccurrences(of: "-", with: "+")
        .replacingOccurrences(of: "_", with: "/")
    
    while base64.count % 4 != 0 {
        base64.append("=")
    }
    
    return Data(base64Encoded: base64)
}

func handleSignIn(result: Result<ASAuthorization, any Error>, completion: @escaping (Bool) -> Void) {
   switch result {
       case .success(let authResults):
           print("Authorisation successful")
            guard let credentials = authResults.credential as? ASAuthorizationAppleIDCredential, let identityToken = credentials.identityToken, let identityTokenString = String(data: identityToken, encoding: .utf8) else {
               completion(false)
               return
            }
            User.shared.hasuraJwt = identityTokenString
            getHasuraJwt(appleJwt: identityTokenString) { isSuccess in
               completion(isSuccess)
            }
        case .failure(let error):
            print("Authorisation failed: \(error.localizedDescription)")
            completion(false)
        
   }
}

private func getHasuraJwt(appleJwt: String, completion: @escaping (Bool) -> Void) {
    Task {
        let success = await fetchHasuraJwt(appleJwt: appleJwt)
        completion(success)
    }
}

private func fetchHasuraJwt(appleJwt: String) async -> Bool {
    guard let url = URL(string: "https://ai-tracker-server-613e3dd103bb.herokuapp.com/hasuraJWT") else {
        return false
    }
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let body: [String: Any] = ["appleKey": appleJwt]
    request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
    
    do {
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            return false
        }
        
        if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let jwt = jsonResponse["jwt"] as? String {
            User.shared.hasuraJwt = jwt
            print("JWT: \(jwt)")
            return true
        } else {
            print("Invalid response received from the server")
            return false
        }
    } catch {
        print("Error sending apple key to server or parsing server response: \(error.localizedDescription)")
        return false
    }
}



// User.shared.setJWTKey("your_jwt_token_here")
// if let jwtKey = User.shared.getJWTKey {
