//
//  SettingsView.swift
//  FirebaseBootcamp
//
//  Created by Heimdal Data on 08.10.2025.
//

import SwiftUI

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

struct SettingsView: View {
    
    @StateObject private var viewModel = SettingsViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        List {
            logOutButton
            
            deleteAccountButton
            
            if viewModel.authProviders.contains(.email) {
                emailSection
            }
            
            if viewModel.authUser?.isAnomymous == true {
                anonymousSection
            }
        }
        .onAppear {
            viewModel.loadAuthProviders()
            viewModel.loadAuthUser()
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    NavigationStack {
        SettingsView(showSignInView: .constant(false))
    }
}

extension SettingsView {

    private var emailSection: some View {
        Section {
            Button {
                Task {
                    do {
                        try await viewModel.resetPassword()
                        print("password reset")
                    } catch {
                        print(error)
                    }
                }
            } label: {
                Text("Reset Password")
            }
            
            Button {
                Task {
                    do {
                        try await viewModel.updatePassword(password: "password123")
                        print("password updated")
                    } catch {
                        print(error)
                    }
                }
            } label: {
                Text("Update Password")
            }
            
            Button {
                Task {
                    do {
                        try await viewModel.updateEmail(email: "abc@abc.com")
                        print("Email Updated")
                    } catch {
                        print(error)
                    }
                }
            } label: {
                Text("Update Email")
            }
            
        } header: {
            Text("Email functions")
        }
    }
    
    private var anonymousSection: some View {
        Section {
            Button {
                Task {
                    do {
                        try await viewModel.linkGoogleAccount()
                        print("Google linked")
                    } catch {
                        print(error)
                    }
                }
            } label: {
                Text("Link Google Account")
            }
            
            Button {
                Task {
                    do {
                        try await viewModel.linkAppeAccount()
                        print("Apple linked")
                    } catch {
                        print(error)
                    }
                }
            } label: {
                Text("Link Apple Account")
            }
            
            Button {
                Task {
                    do {
                        try await viewModel.linkEmailAccount()
                        print("Email linked")
                    } catch {
                        print(error)
                    }
                }
            } label: {
                Text("Link Email Account")
            }
        } header: {
            Text("Create Account")
        }

    }
    
    private var logOutButton: some View {
        Button {
            Task {
                do {
                    try viewModel.signOut()
                    showSignInView = true
                } catch {
                    print("Error: \(error.localizedDescription)")
                }
            }
        } label: {
            Text("Log out")
                .foregroundStyle(.red)
        }
    }
    
    private var deleteAccountButton: some View {
        Button(role: .destructive) {
            Task {
                do {
                    try await viewModel.deleteUser()
                    showSignInView = true
                    print("User deleted")
                } catch {
                    print(error)
                }
            }
        } label: {
            Text("Delete Account")
        }
    }
}
