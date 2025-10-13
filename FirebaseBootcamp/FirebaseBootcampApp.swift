//
//  FirebaseBootcampApp.swift
//  FirebaseBootcamp
//
//  Created by Heimdal Data on 08.10.2025.
//

import SwiftUI
import Firebase
import GoogleSignIn

@main
struct FirebaseBootcampApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate // Register app delegate for Firebase setup
    
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
    
    // When user dismiss the Google Sign In Modal -> we can automatically handle the URL -> not going to use it
//    func application(_ app: UIApplication,
//                     open url: URL,
//                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
//      return GIDSignIn.sharedInstance.handle(url)
//    }
}
