//
//  AuthenticationViewModel.swift
//  FirebaseBootcamp
//
//  Created by Heimdal Data on 21.10.2025.
//

import Foundation
import FirebaseCore

@MainActor
final class AuthenticationViewModel: ObservableObject {
    
//    @Published var didSignInWithApple: Bool = false
//    let signInAppleHelper = SignInAppleHelper()
    
    func signInGoogle() async throws {
        let signInGoogleHelper = SignInGoogleHelper()
        let resultModel = try await signInGoogleHelper.signInGoogle() // Sign In to Google
        let authDataResult = try await AuthenticationManager.shared.signInWithGoogle(result: resultModel) // Sign In to Firebase
        let user = DBUser(auth: authDataResult)
        try UserManager.shared.createUser(user: user)    }
    
    func signInApple() async throws {
        
        let helper = SignInAppleHelper()
        let result = try await helper.startSignInWithAppleFlow()
        let authDataResult = try await AuthenticationManager.shared.signInApple(result: result)
        let user = DBUser(auth: authDataResult)
        try UserManager.shared.createUser(user: user)
//        signInAppleHelper.startSignInWithAppleFlow { result in
//            switch result {
//            case.success(let signInAppleResult):
//                Task {
//                    do {
//                        try await AuthenticationManager.shared.signInApple(result: signInAppleResult)
//                        self.didSignInWithApple = true
//                    } catch {
//
//                    }
//                }
//            case.failure(let error):
//                print(error)
//            }
//        }
    }
    
    func signInAnonymous() async throws{
        let authDataResult = try await AuthenticationManager.shared.signInAnonymous()
        let user = DBUser(auth: authDataResult)
        try UserManager.shared.createUser(user: user)
//        UserManager.shared.createUser(auth: authDataResult)
    }
    
}
