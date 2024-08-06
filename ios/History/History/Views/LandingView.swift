//
//  LandingView.swift
//  History
//
//  Created by Nathik Azad on 8/5/24.
//

import Foundation

import SwiftUI
import AuthenticationServices

struct LandingPageView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Welcome to Aspire")
                .font(.title2)
                .padding(.horizontal)
            Text("We help you use the power of data to understand yourself, set goals and track your progress.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.bottom, 20)
            
            SignInWithAppleButton(.signIn, onRequest: { request in
                request.requestedScopes = [.fullName]
            }, onCompletion: { result in
                Task {
                    await handleSignIn(result: result)
                    AppState.shared.hideChat()
                }
            })
            .frame(width: 280, height: 45)
            .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemBackground))
    }
}
