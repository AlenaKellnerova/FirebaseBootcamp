//
//  ProductCellView.swift
//  FirebaseBootcamp
//
//  Created by Heimdal Data on 12.01.2026.
//

import SwiftUI

struct ProductCellView: View {
    
    let product: Product
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: product.thumbnail ?? "")) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 45, height: 45)
                    .cornerRadius(10)
            } placeholder: {
                ProgressView()
            }
            .frame(width: 75, height: 75)
            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)

            VStack(alignment: .leading){
                Text(product.title ?? "n/a")
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text("Price: $" + String(product.price ?? 0))
                Text("Rating: " + String(product.rating ?? 0))
                Text("Category: " + (product.category ?? "n/a"))
                Text("Brand: " + (product.brand ?? "n/a"))
            }
            .font(.callout)
            .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    ProductCellView(product: Product(id: 1, title: "tite", description: "desc", price: 11, discountPrecentage: 11, rating: 123, stock: 123, brand: "Lacoste", category: "cat", thumbnail: "", images: nil))
}
