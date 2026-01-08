//
//  ProfileView.swift
//  FirebaseBootcamp
//
//  Created by Heimdal Data on 21.10.2025.
//

import SwiftUI

@MainActor
final class ProfileViewModel: ObservableObject {
    
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
    
    func addUserPreference(preference: String) {
        guard let user else { return }
        Task {
            try await UserManager.shared.addUserPreference(userId: user.userId, preference: preference)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
    
    func removeUserPreference(preference: String) {
        guard let user else { return }
        Task {
            try await UserManager.shared.removeUserPreference(userId: user.userId, preference: preference)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
    
    func addFavoriteMovie() {
        guard let user else { return }
        let movie = Movie(id: "1", title: "African Queen", isPopular: true)
        Task {
            try await UserManager.shared.addFavoriteMovie(userId: user.userId, movie: movie)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
    
    func removeFavoriteMovie() {
        guard let user else { return }
        Task {
            try await UserManager.shared.removeFavoriteMovie(userId: user.userId)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }

}

struct ProfileView: View {
    
    @StateObject private var viewModel = ProfileViewModel()
    @Binding var showSignInView: Bool
    let preferenceOptions: [String] = ["Sports", "Movies", "Books"]
    
    private func preferenceIsSelected(preference: String) -> Bool {
        viewModel.user?.preferences?.contains(preference) == true
    }
    
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
                
                VStack {
                    HStack {
                        ForEach(preferenceOptions, id: \.self) { preference in
                            Button(preference) {
                                if preferenceIsSelected(preference: preference) {
                                    viewModel.removeUserPreference(preference: preference)
                                } else {
                                    viewModel.addUserPreference(preference: preference)
                                }
                            }
                            .font(.headline)
                            .buttonStyle(.borderedProminent)
                            .tint(preferenceIsSelected(preference: preference) ? .green : .blue)
                        }
                    }
                    
                    Text("User preferences: \((user.preferences ?? []).joined(separator: ", "))")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Button {
                    if user.favoriteMovie == nil {
                        viewModel.addFavoriteMovie()
                    } else {
                        viewModel.removeFavoriteMovie()
                    }
                } label: {
                    Text("Favorite movie: \(user.favoriteMovie?.title ?? "")")
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
//    NavigationStack {
//        ProfileView(showSignInView: .constant(false))
//    }
    RootView()
}
