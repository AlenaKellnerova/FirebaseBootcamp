//
//  SignInAppleHelper.swift
//  FirebaseBootcamp
//
//  Created by Heimdal Data on 10.10.2025.
//

import Foundation
import SwiftUI
import AuthenticationServices
import CryptoKit

struct SignInAppleResult {
    let token: String
    let nonce: String
    let fullName: PersonNameComponents
    let name: String?
    let email: String?
}

struct SignInWithAppleButtonViewRepresentable: UIViewRepresentable {
    
    let type: ASAuthorizationAppleIDButton.ButtonType
    let style: ASAuthorizationAppleIDButton.Style
    
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        ASAuthorizationAppleIDButton(type: type, style: style)
    }
    
    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {
        
    }
}

@MainActor
final class SignInAppleHelper: NSObject, ASAuthorizationControllerPresentationContextProviding {
    
    private var currentNonce: String?
    private var completionHandler: ((Result<SignInAppleResult, Error>) -> Void)? = nil
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else {
            fatalError("No window found")
        }
        return window
    }
    
    func startSignInWithAppleFlow() async throws -> SignInAppleResult {
        try await withCheckedThrowingContinuation { continuation in
            self.startSignInWithAppleFlow { result in
                switch result {
                case .success(let signInAppleResult):
                    continuation.resume(returning: signInAppleResult)
                    return
                case .failure(let error):
                    continuation.resume(throwing: error)
                    return
                }
            }
        }
    }
    
    func startSignInWithAppleFlow(completion: @escaping(Result<SignInAppleResult, Error>) -> Void) {
        
//        guard let topVC = Utilities.shared.topViewController() else {
//            completion(.failure(URLError(.badURL)))
//            return
//        }
        
        let nonce = randomNonceString()
        currentNonce = nonce
        completionHandler = completion
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError(
                "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
        }
        
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            // Pick a random character from the set, wrapping around if needed.
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
}

extension SignInAppleHelper: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) async throws {
        
        guard
            let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
            let nonce = currentNonce,
            let appleIDToken = appleIDCredential.identityToken,
            let idTokenString = String(data: appleIDToken, encoding: .utf8),
            let fullName = appleIDCredential.fullName
        else {
            completionHandler?(.failure(URLError(.badServerResponse)))
            return
        }
        let name = appleIDCredential.fullName?.givenName
        let email = appleIDCredential.email
            
        let result = SignInAppleResult(token: idTokenString, nonce: nonce, fullName: fullName, name: name, email: email)
        completionHandler?(.success(result))
    }

  func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    // Handle error.
    print("Sign in with Apple errored: \(error)")
      completionHandler?(.failure(URLError(.badServerResponse)))
  }

}
