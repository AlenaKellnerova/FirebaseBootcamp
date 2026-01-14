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
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case price
        case discountPrecentage
        case rating
        case stock
        case brand
        case category
        case thumbnail
        case images
    }
}

@MainActor
final class ProductsViewModel: ObservableObject {
    
//    @Published var products: [Product] = []
    @Published private(set) var products: [Product] = []
    @Published var selectedSortOption: SortOption? = nil
    @Published var selectedCategoryOption: CategoryOption? = nil
    
//    func getAllProducts() async throws {
//        self.products = try await ProductsManager.shared.getAllProducts()
//    }
    
    enum SortOption: String, CaseIterable {
        case all
        case priceHigh
        case priceLow
        
        var priceDescending: Bool? {
            switch self {
            case .priceHigh:
                return true
            case .priceLow:
                return false
            default:
                return nil
            }
        }
    }
    
    enum CategoryOption: String, CaseIterable {
        case noCategory
        case fragrances
        case furniture
        case beauty
        
        var categoryKey: String? {
            switch self {
            case .noCategory:
                return nil
            default:
                return rawValue
            }
        }
    }
    
    func getProducts() {
        Task {
            self.products = try await ProductsManager.shared.getAllRequestedProducts(descending: selectedSortOption?.priceDescending, category: selectedCategoryOption?.categoryKey)
        }
    }
    
    
    func sortSelected(option: SortOption) async throws {
//        switch option {
//        case .all:
//            self.products = try await ProductsManager.shared.getAllRequestedProducts(descending: nil, category: nil)
//        case .priceLow:
//            // query
//            // ui
//            // set filter to price hig
//            self.products = try await ProductsManager.shared.getAllRequestedProducts(descending: false, category: selectedCategoryOption?.rawValue)
//        case .priceHigh:
//            self.products = try await ProductsManager.shared.getAllRequestedProducts(descending: true, category: selectedCategoryOption?.rawValue)
//        }
        self.selectedSortOption = option
        self.getProducts()
    }
    
    func filterByCategory(option: CategoryOption) async throws {
//        switch option {
//        case .noCategory:
//            self.products = try await ProductsManager.shared.getAllRequestedProducts(descending: nil, category: selectedCategoryOption?.rawValue)
//        case .fragrances, .furniture, .beauty:
//            self.products = try await ProductsManager.shared.getAllRequestedProducts(descending: nil, category: selectedCategoryOption?.rawValue)
//        }
 
        self.selectedCategoryOption = option
        getProducts()
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
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarLeading) {
                Menu("Sorty By:\(viewModel.selectedSortOption?.rawValue ?? "NONE")") {
                    ForEach(ProductsViewModel.SortOption.allCases, id: \.self) { option in
                        Button(option.rawValue) {
                            Task {
                                try? await viewModel.sortSelected(option: option)
                            }
                        }
                    }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu("Category: \(viewModel.selectedCategoryOption?.rawValue ?? "NONE")") {
                    ForEach(ProductsViewModel.CategoryOption.allCases, id: \.self) { option in
                        Button(option.rawValue) {
                            Task {
                                try? await viewModel.filterByCategory(option: option)
                            }
                        }
                    }
                }
            }
        })
        .onAppear {
            viewModel.getProducts()
        }
    }
}

#Preview {
    NavigationStack {
        ProductsView()
    }
}
