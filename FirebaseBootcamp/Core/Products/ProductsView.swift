//
//  ProductsView.swift
//  FirebaseBootcamp
//
//  Created by Heimdal Data on 08.01.2026.
//

import SwiftUI

struct ProductArray: Codable {
    let products: [Product]
    let total, skip, limit: Int
}

struct Product: Identifiable, Codable {
    let id: Int
    let title: String?
    let description: String?
    let price: Double?
    let discountPrecentage: Double?
    let rating: Double?
    let stock: Int?
    let brand, category: String?
    let thumbnail: String?
    let images: [String]?
}

@MainActor
final class ProductsViewModel: ObservableObject {
    
//    @Published var products: [Product] = []
    @Published private(set) var products: [Product] = []
    
    func getAllProducts() async throws {
        self.products = try await ProductsManager.shared.getAllProducts()
    }
    
//    func downloadProductsAndUploadToFirebase() {
//        guard let url = URL(string: "https://dummyjson.com/products") else { return }
//        
//        Task {
//            do {
//                let (data, response) = try await URLSession.shared.data(from: url)
//                let products = try JSONDecoder().decode(ProductArray.self, from: data)
//                let productArray = products.products
//                
//                for product in productArray {
//                    try? await ProductsManager.shared.uploadProduct(product: product)
//                }
//                
//                print("Success!")
//                print(products.products.count)
//            } catch {
//                print(error)
//            }
//        }
//    }
}

struct ProductsView: View {
    
    @StateObject private var viewModel = ProductsViewModel()
    
    var body: some View {
        
        List {
            ForEach(viewModel.products) { product in
                ProductCellView(product: product)
            }
        }
        .onAppear {
//            viewModel.downloadProductsAndUploadToFirebase()
        }
        .navigationTitle("Products")
        .task {
            try? await viewModel.getAllProducts()
        }
    }
}

#Preview {
    NavigationStack {
        ProductsView()
    }
}
