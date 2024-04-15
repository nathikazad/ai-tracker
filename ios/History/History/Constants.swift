//
//  Constants.swift
//  History
//
//  Created by Nathik Azad on 4/11/24.
//

import Foundation
let ServerAddress = "https://ai-tracker-server-613e3dd103bb.herokuapp.com"
let HasuraAddress = "ai-tracker-hasura-a1071aad7764.herokuapp.com"
// Function to append path to the base URL
func fullURL(for path: String) -> String {
    return "\(ServerAddress)/\(path)"
}

// Example usage of the function
let parseAudioEndpoint = fullURL(for: "parseUserRequestFromAudio")
let parseTextEndpoint = fullURL(for: "parseUserRequestFromText")
let getJwtEndpoint = fullURL(for: "hasuraJWT")
let updateMovementEndpoint = fullURL(for: "updateMovement")
