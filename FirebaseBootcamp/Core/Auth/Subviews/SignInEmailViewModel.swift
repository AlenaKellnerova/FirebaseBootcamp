//
//  SignInEmailViewModel.swift
//  FirebaseBootcamp
//
//  Created by Heimdal Data on 21.10.2025.
//

import Foundation
import FirebaseCore

@MainActor
final class SignInEmailViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
    
    func signUp() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            return
        }
        
        let authDataResult = try await AuthenticationManager.shared.createUser(email: email, password: password)
        let user = DBUser(auth: authDataResult)
        try UserManager.shared.createUser(user: user)
    }
    
    func signIn() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            return
        }
        
        try await AuthenticationManager.shared.signInUser(email: email, password: password)
    }

    
    
}
