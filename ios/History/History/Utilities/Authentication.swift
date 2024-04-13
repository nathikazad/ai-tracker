//
//  User.swift
//  History
//
//  Created by Nathik Azad on 4/5/24.
//

import Foundation
import AuthenticationServices

class Authentication {
    static let shared = Authentication()
    
    private let hasuraJwtKey = "hasuraJWTKey"
    private let appleJwtKey = "appleJWTKey"
    var hasuraJWTObject: HasuraJWTObject?
    var user: UserModel?
    
    init() {
        if(areJwtSet) {
            hasuraJWTObject = HasuraJWTObject(jwt: hasuraJwt!)
            signInCallback()
        } else {
            signOutCallback()
        }
    }
    
    var areJwtSet: Bool {
        return appleJwt != nil && hasuraJwt != nil
    }
    
    var userId: Int? {
        return hasuraJWTObject?.userId
    }
    
    var hasuraJwt: String? {
        get {
            UserDefaults.standard.string(forKey: hasuraJwtKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: hasuraJwtKey)
            if(newValue != nil) {
                hasuraJWTObject = HasuraJWTObject(jwt: newValue!)
            }
            // TODO: send to apple watch
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
    
    func checkAndReloadHasuraJwt() async {
        if(hasuraJWTObject?.isExpired ?? true){
            hasuraJwt = await fetchHasuraJwt(appleKey: appleJwt!)
        } else {
            print("jwt not expired")
        }
    }
    
    func signInCallback() {
        Hasura.shared.setup()
        Task {
            user = try await UserController.fetchUser()
            await UserController.ensureUserTimezone()
        }
    }
    
    func signOutCallback() {
        UserDefaults.standard.removeObject(forKey: hasuraJwtKey)
        UserDefaults.standard.removeObject(forKey: appleJwtKey)
        Hasura.shared.closeConnection()
    }
}


func handleSignIn(result: Result<ASAuthorization, any Error>) async -> Bool {
    switch result {
    case .success(let authResults):
        print("Authorisation successful")
        guard let credentials = authResults.credential as? ASAuthorizationAppleIDCredential, let identityToken = credentials.identityToken, let identityTokenString = String(data: identityToken, encoding: .utf8) else {
            return false
        }
        Authentication.shared.appleJwt = identityTokenString
        let jwt = await fetchHasuraJwt(appleKey: identityTokenString)
        Authentication.shared.hasuraJwt = jwt
        Authentication.shared.signInCallback()
        return jwt != nil
    case .failure(let error):
        print("Authorisation failed: \(error.localizedDescription)")
        return false
    }
}



private func fetchHasuraJwt(appleKey: String) async -> String? {
    guard let url = URL(string: "https://ai-tracker-server-613e3dd103bb.herokuapp.com/hasuraJWT") else {
        return nil
    }
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let body: [String: Any] = ["appleKey": appleKey]
    request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
    do {
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            return nil
        }
        if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let jwt = jsonResponse["jwt"] as? String {
            return jwt
        } else {
            print("Invalid response received from the server")
            return nil
        }
    } catch {
        print("Error sending apple key to server or parsing server response: \(error.localizedDescription)")
        return nil
    }
}




struct HasuraJWTObject {
    let exp: TimeInterval
    let userId: Int
    
    init(jwt: String) {
        let parts = jwt.components(separatedBy: ".")
        let payloadData = base64UrlDecodedData(base64Url: parts[1])!
        let payloadDict = try! JSONSerialization.jsonObject(with: payloadData, options: []) as! [String: Any]
        let exp = payloadDict["exp"] as! TimeInterval
        let claims = payloadDict["https://hasura.io/jwt/claims"] as! [String: Any]
        let userId = Int(claims["x-hasura-user-id"] as! String)
        
        self.exp = exp
        self.userId = userId!
    }
    
    var isExpired: Bool {
        let expirationDate = Date(timeIntervalSince1970: exp)
        let sixHoursBeforeExpiration = expirationDate.addingTimeInterval(-6 * 3600)
        return sixHoursBeforeExpiration <= Date()
    }
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
