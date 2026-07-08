//
//  AnalyticsView.swift
//  FirebaseBootcamp
//
//  Created by Heimdal Data on 03.07.2026.
//

import SwiftUI
import FirebaseAnalytics

final class AnalyticsManager {
    
    static let shared = AnalyticsManager()
    private init() {}
    
    func logEvent(name: String, params: [String:Any]? = nil) {
        Analytics.logEvent(name, parameters: params)
        // AnalyticsEventLogin
    }
    
    func setUserId(userId: String) {
        Analytics.setUserID(userId)
    }
    
    func setUserProperty(value: String?, property: String) { // age, gender, interest => for segmentign the users
        Analytics.setUserProperty(value, forName: property)
    }
    
}

struct AnalyticsView: View {
    var body: some View {
        VStack {
            Button("Click me!") {
                AnalyticsManager.shared.logEvent(name: "AnalyticsView_ButtonCLicked")
            }
            
            Button("Click me too!") {
                AnalyticsManager.shared.logEvent(name: "AnalyticsView_ButtonCLicked_Secondary", params: [
                    "screen title" : "my title"
                ])
            }
        }
        .analyticsScreen(name: "AnalyticsView")
        .onAppear {
            AnalyticsManager.shared.logEvent(name: "AnalyticsView_Appear")
            AnalyticsManager.shared.setUserId(userId: "123")
            AnalyticsManager.shared.setUserProperty(value: true.description, property: "user_is_premium")
        }
        .onDisappear {
            AnalyticsManager.shared.logEvent(name: "AnalyticsView_Disppear")
        }
    }
}

#Preview {
    AnalyticsView()
}
