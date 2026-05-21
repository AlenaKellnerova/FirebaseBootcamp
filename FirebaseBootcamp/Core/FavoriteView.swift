//
//  FavoriteView.swift
//  FirebaseBootcamp
//
//  Created by Heimdal Data on 19.01.2026.
//

import SwiftUI

@MainActor
final class FavouriteViewModel: ObservableObject {
    
    @Published private(set) var favProducts: [UserFavoriteProduct] = []
    
    func getFavorites() {
        Task {
            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
            self.favProducts = try await UserManager.shared.getAllUserFavoriteProducts(userId: authDataResult.uid)
        }
    }
    
    func removeFromFavorites(favProductId: String) {
        Task {
            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
            try await UserManager.shared.removeUserFavoriteProduct(userId: authDataResult.uid, favoriteProductId: favProductId)
            getFavorites()
        }
    }
    
}

struct FavoriteView: View {
    
    @StateObject private var viewModel = FavouriteViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.favProducts, id: \.id) { favProduct in
                ProductCellViewBuilder(productId: String(favProduct.productId)) // lazily loads
                    .contextMenu {
                        Button("Remove from Favorites") {
                            viewModel.removeFromFavorites(favProductId: favProduct.id)
                        }
                    }
            }
        }
        .navigationTitle("Favorites")
        .onAppear {
            viewModel.getFavorites()
        }
    }
}

#Preview {
    NavigationStack {
        FavoriteView()        
    }
}
