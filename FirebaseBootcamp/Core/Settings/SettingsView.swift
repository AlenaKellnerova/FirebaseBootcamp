//
//  SettingsView.swift
//  FirebaseBootcamp
//
//  Created by Heimdal Data on 08.10.2025.
//

import SwiftUI

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
