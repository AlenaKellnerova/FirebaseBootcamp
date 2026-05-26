//
//  FavoriteView.swift
//  FirebaseBootcamp
//
//  Created by Heimdal Data on 19.01.2026.
//

import SwiftUI
import Combine

@MainActor
final class FavouriteViewModel: ObservableObject {
    
    @Published private(set) var favProducts: [UserFavoriteProduct] = []
    private var cancellables = Set<AnyCancellable>()
    
    func addListenerForFavorites() {
        guard let authDataResult = try? AuthenticationManager.shared.getAuthenticatedUser() else { return }
        
        UserManager.shared.addListenerForAllUserFavoriteProducts(userId: authDataResult.uid)
            .sink { completion in
                
            } receiveValue: { [weak self] products in
                self?.favProducts = products
            }
            .store(in: &cancellables)

    }
    
    func removeFromFavorites(favProductId: String) {
        Task {
            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
            try await UserManager.shared.removeUserFavoriteProduct(userId: authDataResult.uid, favoriteProductId: favProductId)
//            getFavorites()
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
        .onFirstAppear {
            viewModel.addListenerForFavorites()
        }
    }
}

#Preview {
    NavigationStack {
        FavoriteView()        
    }
}

struct OnFirstAppearViewModifier: ViewModifier {
    
    @State private var didAppear = false
    let perform: (() -> Void)?
    
    func body(content: Content) -> some View { // = modifier on the existing view which has some content
        content
            .onAppear {
                if !didAppear {
                    perform?()
                    didAppear = true
                }
            }
    }
}

extension View {
    
    func onFirstAppear(perform: (() -> Void)?) -> some View {
        modifier(OnFirstAppearViewModifier(perform: perform))
    }
}
