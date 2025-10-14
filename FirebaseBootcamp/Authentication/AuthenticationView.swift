//
//  AuthenticationView.swift
//  FirebaseBootcamp
//
//  Created by Heimdal Data on 08.10.2025.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift
import AuthenticationServices
import CryptoKit
import FirebaseAuth


@MainActor
final class AuthenticationViewModel: ObservableObject {
    
//    @Published var didSignInWithApple: Bool = false
//    let signInAppleHelper = SignInAppleHelper()
    
    func signInGoogle() async throws {
        let signInGoogleHelper = SignInGoogleHelper()
        let resultModel = try await signInGoogleHelper.signInGoogle() // Sign In to Google
        try await AuthenticationManager.shared.signInWithGoogle(result: resultModel) // Sign In to Firebase
    }
    
    func signInApple() async throws {
        
        let helper = SignInAppleHelper()
        let result = try await helper.startSignInWithAppleFlow()
        try await AuthenticationManager.shared.signInApple(result: result)
        
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
        try await AuthenticationManager.shared.signInAnonymous()
    }
    
}


struct AuthenticationView: View {
    
    @StateObject private var viewModel = AuthenticationViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        VStack {
            
            Button {
                Task {
                    do {
                        try await viewModel.signInAnonymous()
                        showSignInView = false
                        print("Sign In anyomously success")
                    } catch {
                        print(error)
                    }
                }
            } label: {
                Text("Sign In Anonymously")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(.orange)
                    .cornerRadius(10)
            }

            
            
            NavigationLink {
                SignInEmailView(showSignInView: $showSignInView)
            } label: {
                Text("Sign in with Email")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(.blue)
                    .cornerRadius(10)
            }
            
            GoogleSignInButton {
                Task {
                    do {
                        try await viewModel.signInGoogle()
                        print("Sign In Google success")
                        showSignInView = false
                    } catch {
                        print("Error signing in Google: \(error.localizedDescription)")
                    }
                }
            }
            
            
            
            Button {
                Task {
                    do {
                        try await viewModel.signInApple()
                        showSignInView = false
                    } catch {
                        print("Error signing in Apple: \(error.localizedDescription)")
                    }
                }
            } label: {
                SignInWithAppleButtonViewRepresentable(type: .default, style: .whiteOutline)
                    .allowsHitTesting(false)
            }
            .frame(height: 55)
//            .onChange(of: viewModel.didSignInWithApple) { newValue in
//                if newValue {
//                    showSignInView = false
//                }
//            }

            Spacer()

        }
        .padding()
        .navigationTitle("Sign In")
    }
}

#Preview {
    NavigationStack {
        AuthenticationView(showSignInView: .constant(true))
    }
}
