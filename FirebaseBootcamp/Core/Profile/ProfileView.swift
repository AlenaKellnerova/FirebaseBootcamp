//
//  ProfileView.swift
//  FirebaseBootcamp
//
//  Created by Heimdal Data on 21.10.2025.
//

import SwiftUI

@MainActor
final class ProfileViewModel: ObservableObject {
    
    // write from inside read from outside 
    @Published private(set) var user: DBUser? = nil
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    func togglePremiumStatus() {
        guard var user = user else { return }
        let isCurrentlyPremium = user.isPremium ?? false
//        let updatedUser = DBUser(userId: user.userId, isAnonymous: user.isAnonymous, email: user.email, photoUrl: user.photoUrl, dateCreated: user.dateCreated, isPremium: !isCurrentlyPremium)
        
        // Old methods: 
//        let updatedUser = user.togglePremiumStatus()
//        user.isPremium = !isCurrentlyPremium
//        user.togglePremiumStatus()
        
        Task {
//            try await UserManager.shared.updateUserPremiumStatus(user: user)
            try await UserManager.shared.updateUserPremiumStatus(userId: user.userId, isPremium: !isCurrentlyPremium)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
    
}

struct ProfileView: View {
    
    @StateObject private var viewModel = ProfileViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        List {
            if let user = viewModel.user {
                Text("UserId: \(user.userId)")
                
                if let isAnonymous = user.isAnonymous {
                    Text("Is anonymous: \(isAnonymous.description.capitalized)")
                }
                
                Button {
                    viewModel.togglePremiumStatus()
                } label: {
                    Text("User is premium: \((user.isPremium ?? false).description.capitalized)")
                }

            }
        }
        .task {
            try? await viewModel.loadCurrentUser()
        }
        .navigationTitle("Profile")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    SettingsView(showSignInView: $showSignInView)
                } label: {
                    Image(systemName: "gear")
                        .font(.headline)
                }

            }
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView(showSignInView: .constant(false))
    }
}
