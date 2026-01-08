//
//  SettingsViewModel.swift
//  FirebaseBootcamp
//
//  Created by Heimdal Data on 21.10.2025.
//

import Foundation

final class SettingsViewModel: ObservableObject {
    
    @Published var authProviders: [AuthProviderId] = []
    @Published var authUser: AuthDataResultModel? = nil
    
    func loadAuthProviders() {
        if let providers = try? AuthenticationManager.shared.getProviders() {
            authProviders = providers
        }
    }
    
    func loadAuthUser() {
        self.authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
    }
    
    func signOut() throws {
        try AuthenticationManager.shared.signOut()
    }
    
    func resetPassword() async throws {
        let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
        guard let email = authUser.email else {
            throw URLError(.fileDoesNotExist)
        }
        try await AuthenticationManager.shared.resetPassword(email: email)
    }
    
    func updatePassword(password: String) async throws {
        try await AuthenticationManager.shared.updatePassword(password: password)
    }
    
    func updateEmail(email: String) async throws {
        try await AuthenticationManager.shared.updateEmail(email: email)
    }
    
    func linkGoogleAccount() async throws {
        let helper = await SignInGoogleHelper()
        let result = try await helper.signInGoogle()
        self.authUser = try await AuthenticationManager.shared.linkGoogle(result: result)
    }
    
    func linkAppeAccount() async throws {
        let helper = await SignInAppleHelper()
        let result = try await helper.startSignInWithAppleFlow()
        self.authUser = try await AuthenticationManager.shared.linkApple(result: result)
    }
    
    func linkEmailAccount() async throws {
        let email = "abcd@abcd.com"
        let password = "password123"
        self.authUser = try await AuthenticationManager.shared.linkEmail(email: email, password: password)
    }
    
    func deleteUser() async throws {
        try await AuthenticationManager.shared.deleteUser()
    }
}
