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
