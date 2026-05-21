//
//  TabbarView.swift
//  FirebaseBootcamp
//
//  Created by Heimdal Data on 19.01.2026.
//

import SwiftUI

struct TabbarView: View {
    
    @Binding var showSignInView: Bool
    
    var body: some View {
        
        TabView {
            NavigationStack {
                ProductsView()
            }
            .tabItem {
                    Image(systemName: "cart")
                    Text("Products")
                }
            NavigationStack {
                FavoriteView()
            }
            .tabItem {
                Image(systemName: "star.fill")
                Text("Favorites")
            }
            NavigationStack {
                ProfileView(showSignInView: $showSignInView)
            }
            .tabItem {
                Image(systemName: "person")
                Text("Profile")
            }
        }
    }
}

#Preview {
    TabbarView(showSignInView: .constant(false))
}
