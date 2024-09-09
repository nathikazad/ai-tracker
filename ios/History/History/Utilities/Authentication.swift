//
//  User.swift
//  History
//
//  Created by Nathik Azad on 4/5/24.
//

import Foundation
import AuthenticationServices


var auth: Authentication {
    return Authentication.shared
}

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
    
    var isAdmin: Bool {
        return userId == 1
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
        } 
//         else {
//             print("jwt not expired")
//         }
    }
    
    func signInCallback() {
        hasura.setup()
#if os(iOS)
        watch.sync()
#endif
        Task {
            user = try await UserController.fetchUser()
            await UserController.ensureUserTimezone()
            
        }
        
    }
    
    func signOutCallback() {
        UserDefaults.standard.removeObject(forKey: hasuraJwtKey)
        UserDefaults.standard.removeObject(forKey: appleJwtKey)
#if os(iOS)
        watch.sync()
#endif
        hasura.closeConnection()
    }
}


func handleSignIn(result: Result<ASAuthorization, any Error>) async -> Bool {
    switch result {
    case .success(let authResults):
        print("Authorisation successful")
        guard let credentials = authResults.credential as? ASAuthorizationAppleIDCredential, let identityToken = credentials.identityToken, let identityTokenString = String(data: identityToken, encoding: .utf8) else {
            return false
        }
        var username: String?
        if let fullName = credentials.fullName {
            username = [
                fullName.givenName,
                fullName.familyName
            ].compactMap { $0 }.joined(separator: " ")
            print("User Name: \(username!)")
        }
        let userLanguage = Locale(identifier:Locale.preferredLanguages.first ?? "en").language.languageCode?.identifier ?? "en"
        print("User Language: \(userLanguage)")
        auth.appleJwt = identityTokenString
        let jwt = await fetchHasuraJwt(appleKey: identityTokenString, username: username, userLanguage: userLanguage)
        if(jwt != nil) {
            auth.hasuraJwt = jwt
            auth.signInCallback()
            return true
        } else {
            return false
        }
    case .failure(let error):
        print("Authorisation failed: \(error.localizedDescription)")
        return false
    }
}



private func fetchHasuraJwt(appleKey: String, username: String? = nil, userLanguage: String? = nil) async -> String? {
    let jwtEndpoint = getJwtEndpoint
    var body: [String: Any] = ["appleKey": appleKey]
    if let username = username {
        if(username.count > 0) {
            body["username"] = username
        }
    }
    if let userLanguage = userLanguage {
        body["language"] = userLanguage
    }
    do {
        guard let data = try await ServerCommunicator.sendPostRequestAsync(to: jwtEndpoint, body: body, token: nil, waitAndSendIfServerUnreachable: false) else {
            print("Failed to receive data")
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
    var userId: Int //change to let later
    
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
