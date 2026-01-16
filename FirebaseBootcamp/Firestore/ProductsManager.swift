//
//  ProductsManager.swift
//  FirebaseBootcamp
//
//  Created by Heimdal Data on 12.01.2026.
//

import Foundation
import FirebaseFirestore

final class ProductsManager {
    
    
    static let shared = ProductsManager()
    
    private init() {}
    
    private let productsCollection = Firestore.firestore().collection("products")
    
    private func getProductDocument(productId: String) -> DocumentReference {
        productsCollection.document(productId)
    }
    
    func uploadProduct(product: Product) async throws {
        try getProductDocument(productId: String(product.id)).setData(from: product, merge: false)
    }
    
    func getProduct(productId: String) async throws -> Product {
        try await getProductDocument(productId: productId).getDocument(as: Product.self)
    }
    
//    private func getAllProducts() async throws -> [Product] {
//        try await productsCollection
//            .getDocuments(as: Product.self)
//    }
//    
//    private func getAllProductsSortedByPrice(descending: Bool) async throws -> [Product] {
//        try await productsCollection
//            .order(by: Product.CodingKeys.price.rawValue, descending: descending)
//            .getDocuments(as: Product.self)
//    }
//    
//    private func getAllProductsForCategory(category: String) async throws -> [Product] {
//        try await productsCollection
//            .whereField(Product.CodingKeys.category.rawValue, isEqualTo: category)
//            .getDocuments(as: Product.self)
//    }
//    
//    private func getAllProductsSortedByPriceAndCategory(descending: Bool, category: String) async throws -> [Product] {
//        try await productsCollection
//            .whereField(Product.CodingKeys.category.rawValue, isEqualTo: category)
//            .order(by: Product.CodingKeys.price.rawValue, descending: descending)
//            .getDocuments(as: Product.self)
//    }
    
    private func getAllProductsQuery() -> Query {
        productsCollection
    }
    
    private func getAllProductsSortedByPriceQuery(descending: Bool) -> Query {
        productsCollection
            .order(by: Product.CodingKeys.price.rawValue, descending: descending)
    }
    
    private func getAllProductsForCategoryQuery(category: String) -> Query {
        productsCollection
            .whereField(Product.CodingKeys.category.rawValue, isEqualTo: category)
    }
    
    private func getAllProductsSortedByPriceAndCategoryQuery(descending: Bool, category: String) -> Query {
        productsCollection
            .whereField(Product.CodingKeys.category.rawValue, isEqualTo: category)
            .order(by: Product.CodingKeys.price.rawValue, descending: descending)
    }
    
    func getAllRequestedProducts(descending: Bool?, category: String?, count: Int, lastDocument: DocumentSnapshot?) async throws -> ([Product], DocumentSnapshot?) {
        var query: Query = getAllProductsQuery()
        
        if let descending, let category {
            query = getAllProductsSortedByPriceAndCategoryQuery(descending: descending, category: category)
        } else if let descending {
            query = getAllProductsSortedByPriceQuery(descending: descending)
        } else if let category {
            query = getAllProductsForCategoryQuery(category: category)
        }
        if let lastDocument {
            return try await query
                .limit(to: count)
                .start(atDocument: lastDocument)
                .getDocumentsWithSnapshot(as: Product.self)
        } else {
            return try await query
                .limit(to: count)
                .getDocumentsWithSnapshot(as: Product.self)
        }
       
    }
    
    func getProductsByRating(count: Int, lastRating: Double?) async throws -> [Product] {
        try await productsCollection
            .order(by: Product.CodingKeys.rating.rawValue, descending: true)
            .limit(to: count)
            .start(after: [lastRating ?? 9999999])
            .getDocuments(as: Product.self)
    }
    
    func getProductsByRating(count: Int, lastDocument: DocumentSnapshot?) async throws -> ([Product], DocumentSnapshot?) {
        if let lastDocument {
            try await productsCollection
                .order(by: Product.CodingKeys.rating.rawValue, descending: true)
                .limit(to: count)
                .start(afterDocument: lastDocument)
                .getDocumentsWithSnapshot(as: Product.self)
        } else {
            try await productsCollection
                .order(by: Product.CodingKeys.rating.rawValue, descending: true)
                .limit(to: count)
                .getDocumentsWithSnapshot(as: Product.self)
        }
    }
    
    
}

extension Query {
    
    func getDocuments<T>(as type: T.Type) async throws -> [T] where T : Decodable {
        let snapshot = try await self.getDocuments()
        return try snapshot.documents.map { document in
             try document.data(as: T.self)
        }
    }
    
    func getDocumentsWithSnapshot<T>(as type: T.Type) async throws -> ([T], DocumentSnapshot?) where T : Decodable {
        let snapshot = try await self.getDocuments()
        let products = try snapshot.documents.map { document in
             try document.data(as: T.self)
        }
        return (products, snapshot.documents.last)
    }
    
}
