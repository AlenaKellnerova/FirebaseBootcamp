//
//  SignInGoogleHelper.swift
//  FirebaseBootcamp
//
//  Created by Heimdal Data on 10.10.2025.
//

import Foundation
import GoogleSignIn
import GoogleSignInSwift

struct GoogleSignInResultModel {
    let idToken: String
    let accessToken: String
    let name: String?
    let email: String?
}

@MainActor
final class SignInGoogleHelper {
    
    
    func signInGoogle() async throws -> GoogleSignInResultModel {
        
        // 1. Get top VC
        guard let topVC = Utilities.shared.topViewController() else {
            throw URLError(.cannotFindHost)
        }
        // 2. Sign In to Google
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC) // Presents modal
        guard let idToken = result.user.idToken?.tokenString else {
            throw URLError(.badServerResponse)
        }
        let user = result.user
        let accessToken = user.accessToken.tokenString
        let name = user.profile?.name
        let email = user.profile?.email
        return GoogleSignInResultModel(idToken: idToken, accessToken: accessToken, name: name, email: email)

    }
    
}
