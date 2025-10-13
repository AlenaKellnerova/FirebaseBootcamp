//
//  AuthenticationManager.swift
//  FirebaseBootcamp
//
//  Created by Heimdal Data on 08.10.2025.
//

import Foundation
import FirebaseAuth

struct AuthDataResultModel {
    let uid: String
    let email: String?
    let photoUrl: String?
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
        self.photoUrl = user.photoURL?.absoluteString
    }
}

enum AuthProviderId: String {
    case email = "password"
    case google = "google.com"
    case apple = "apple.com"
}

final class AuthenticationManager {
    
    static let shared = AuthenticationManager()
    private init() { }
    
    // Checks user locally -> gets the value from the local SDK
    func getAuthenticatedUser() throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        return AuthDataResultModel(user: user)
    }
    
    // google.com/ password
    func getProviders() throws -> [AuthProviderId] {
        guard let providerData = Auth.auth().currentUser?.providerData else {
            throw URLError(.badServerResponse)
        }
        
        var providers: [AuthProviderId] = []
        for provider in providerData {
            print(provider.providerID)
            if let providerId = AuthProviderId(rawValue: provider.providerID) {
                providers.append(providerId)
            } else {
                assertionFailure("Provider not found: \(provider.providerID)")
            }
        }
        return providers
    }
    
    // Signs out locally
    func signOut() throws {
        try Auth.auth().signOut()
    }
}

//MARK: - Sign In Email
extension AuthenticationManager {
    
    @discardableResult
    func createUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    @discardableResult
    func signInUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    // Password reset - send to an email
    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    // Update password inside the app
    func updatePassword(password: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        try await user.updatePassword(to: password)
    }
    
    func updateEmail(email: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        try await user.updateEmail(to: email)
    }
}

//MARK: - Sign In SSO (Single Sign-On)
extension AuthenticationManager {
    
    @discardableResult
    func signInWithGoogle(result: GoogleSignInResultModel) async throws -> AuthDataResultModel {
        let credentials = GoogleAuthProvider.credential(withIDToken: result.idToken, accessToken: result.accessToken)
        return try await signIn(credential: credentials)
    }
    
    @discardableResult
    func signInApple(result: SignInAppleResult) async throws -> AuthDataResultModel {
        let credetial = OAuthProvider.appleCredential(
            withIDToken: result.token,
            rawNonce: result.nonce,
            fullName: result.fullName)
        return try await signIn(credential: credetial)
    }
    
    func signIn(credential: AuthCredential) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(with: credential)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
}
