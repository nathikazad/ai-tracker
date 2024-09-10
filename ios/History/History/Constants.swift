//
//  Constants.swift
//  History
//
//  Created by Nathik Azad on 4/11/24.
//

import Foundation
// Server Addresses
let ServerAddress = "https://ai-tracker-server-613e3dd103bb.herokuapp.com"
let HasuraAddress = "ai-tracker-hasura-a1071aad7764.herokuapp.com"
func fullURL(for path: String) -> String {
    return "\(ServerAddress)/\(path)"
}
let pingEndpoint = fullURL(for: "ping")
let parseAudioEndpoint = fullURL(for: "parseUserRequestFromAudio")
let parseTextEndpoint = fullURL(for: "parseUserRequestFromText")
let getJwtEndpoint = fullURL(for: "hasuraJWT")
let getDeleteUserEndpoint = fullURL(for: "deleteUser")
let updateMovementEndpoint = fullURL(for: "updateMovement")
let updateLocationEndpoint = fullURL(for: "updateLocation")
let uploadSleepEndpoint = fullURL(for: "uploadSleep")
let createLocationEndpoint = fullURL(for: "createLocation")


// Constants
let microphoneTimeout = 300.0 // seconds

let supabaseUrl = "https://sycpmqwjdcbdbsoqowaj.supabase.co";
let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN5Y3BtcXdqZGNiZGJzb3Fvd2FqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjU5MjkyMDksImV4cCI6MjA0MTUwNTIwOX0.ZkxKGOlzV6Ut1zPyGGjKHA2Nd16uPWCty-Cf8y26dCU";


