//
//  ProfileView.swift
//  FirebaseBootcamp
//
//  Created by Heimdal Data on 21.10.2025.
//

import SwiftUI
import PhotosUI

@MainActor
final class ProfileViewModel: ObservableObject {
    
    @Published private(set) var user: DBUser? = nil
   
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    func togglePremiumStatus() {
        guard let user = user else { return }
        let isCurrentlyPremium = user.isPremium ?? false
        
        Task {
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
    
    func saveProfileImage(photoPickerItem: PhotosPickerItem) {
        guard let user else { return }
        
        Task {
            guard let data = try await photoPickerItem.loadTransferable(type: Data.self) else { return }
            let (path, name) = try await StorageManager.shared.saveImage(data: data, userId: user.userId)
            print("Success! Path and name:")
            print(path)
            print(name)
            let url = try await StorageManager.shared.getUrlForImage(path: path)
            try await UserManager.shared.updateUserProfileImage(userId: user.userId, path: path, url: url.absoluteString)
        }
    }
    
    func deleteProfileImage() {
        guard let user, let path = user.profileImagePath else { return }
        
        Task {
            try await StorageManager.shared.deleteImage(path: path)
            try await UserManager.shared.updateUserProfileImage(userId: user.userId, path: nil, url: nil)
        }
    }

}

struct ProfileView: View {
    
    @StateObject private var viewModel = ProfileViewModel()
    @Binding var showSignInView: Bool
    let preferenceOptions: [String] = ["Sports", "Movies", "Books"]
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var profileImage: UIImage? = nil
    @State private var url: URL? = nil
    
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
                
                // Profile img picker
                PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                    Text("Select photo")
                }
                
                
                if let urlString = viewModel.user?.profileImagePathUrl, let url = URL(string: urlString) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .cornerRadius(10)
                    } placeholder: {
                        ProgressView()
                            .frame(width: 150, height: 150)
                    }
                }
                
                if let _ = viewModel.user?.profileImagePath {
                    Button("Delete Image") {
                        viewModel.deleteProfileImage()
                    }
                }
               

            }
        }
        .task {
            try? await viewModel.loadCurrentUser()
            if let user = viewModel.user, let path = user.profileImagePath {
                let url = try? await StorageManager.shared.getUrlForImage(path: path)
                self.url = url
            }
        }
        .onChange(of: selectedItem) { _, newValue in
            if let newValue {
                viewModel.saveProfileImage(photoPickerItem: newValue)
            }
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
