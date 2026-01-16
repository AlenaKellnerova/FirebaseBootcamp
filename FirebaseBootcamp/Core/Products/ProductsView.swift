//
//  ProductsView.swift
//  FirebaseBootcamp
//
//  Created by Heimdal Data on 08.01.2026.
//

import SwiftUI
import FirebaseFirestore

struct ProductArray: Codable {
    let products: [Product]
    let total, skip, limit: Int
}

struct Product: Identifiable, Codable, Equatable {
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
    
    static func ==(lhs: Product, rhs: Product) -> Bool {
        return lhs.id == rhs.id
    }
}

@MainActor
final class ProductsViewModel: ObservableObject {
    
//    @Published var products: [Product] = []
    @Published private(set) var products: [Product] = []
    @Published var selectedSortOption: SortOption? = nil
    @Published var selectedCategoryOption: CategoryOption? = nil
    private var lastDocument: DocumentSnapshot? = nil
    
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
            let (newProducts, lastDocument) = try await ProductsManager.shared.getAllRequestedProducts(descending: selectedSortOption?.priceDescending, category: selectedCategoryOption?.categoryKey, count: 6, lastDocument: lastDocument)
            self.products.append(contentsOf: newProducts)
            if let lastDocument {
                self.lastDocument = lastDocument                
            }
        }
    }
    
    
    func sortSelected(option: SortOption) async throws {
        self.selectedSortOption = option
        self.products = []
        self.lastDocument = nil
        self.getProducts()
    }
    
    func filterByCategory(option: CategoryOption) async throws {
        self.selectedCategoryOption = option
        self.products = []
        self.lastDocument = nil
        getProducts()
    }
    
    func getProductsByRating() {
        Task {
//            let newProducts = try await ProductsManager.shared.getProductsByRating(count: 3, lastRating: self.products.last?.rating)
            let (newProducts, lastDocument) = try await ProductsManager.shared.getProductsByRating(count: 3, lastDocument: lastDocument)
            self.products.append(contentsOf: newProducts)
            self.lastDocument = lastDocument
        }
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
        
//        Button("Fetch more objects") {
//            viewModel.getProductsByRating()
//        }
        
        List {
            ForEach(viewModel.products) { product in
                ProductCellView(product: product)
                
                if product == viewModel.products.last {
                    ProgressView()
                        .onAppear {
                            print("Progress view appeared")
                            viewModel.getProducts()
                        }
                }
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
