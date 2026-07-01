//
//  CrashView.swift
//  FirebaseBootcamp
//
//  Created by Heimdal Data on 15.06.2026.
//

import SwiftUI
import FirebaseCrashlytics

final class CrashManager {
    
    static let shared = CrashManager()
    private init() {}
    
    func setUserId(userId: String) {
        Crashlytics.crashlytics().setUserID(userId)
    }
    
    func setValue(value: String, key: String) {
        Crashlytics.crashlytics().setCustomValue(value, forKey: key)
    }
    
    func setIsPremiumValue(isPremium: Bool) {
        setValue(value: isPremium.description.lowercased(), key: "user_is_premium")
    }
    
    func addLog(message: String) {
        Crashlytics.crashlytics().log(message)
    }
    
    func sendNonFatal(error: Error) {
        Crashlytics.crashlytics().record(error: error)
    }
}

struct CrashView: View {
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.3).ignoresSafeArea()
            
            VStack(spacing: 40) {
                
                Button("Click me 1") {
                    CrashManager.shared.addLog(message: "Button 1 clicked")
                    let myString: String? = nil
                    guard let myString else {
                        CrashManager.shared.sendNonFatal(error: URLError(.dataNotAllowed))
                        return
                    }
                }
                
                
                Button("Click me 2") {
                    CrashManager.shared.addLog(message: "Button 2 clicked")
                    fatalError("Fatal crash.")
                }
                
                Button("Click me 3") {
                    CrashManager.shared.addLog(message: "Button 3 clicked")
                    let array: [String] = []
                    let item = array[0]
                }
                
            }
        }
        .onAppear {
            CrashManager.shared.setUserId(userId: "123alena")
            CrashManager.shared.setIsPremiumValue(isPremium: false)
            CrashManager.shared.addLog(message: "crash view appeared")
        }
    }
}

#Preview {
    CrashView()
}
