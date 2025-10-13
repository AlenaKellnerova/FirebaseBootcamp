//
//  Utilities.swift
//  FirebaseBootcamp
//
//  Created by Heimdal Data on 09.10.2025.
//

import Foundation
import UIKit

final class Utilities {
    
    static let shared = Utilities()
    private init() { }
    
    @MainActor
    func topViewController(viewController: UIViewController? = nil) -> UIViewController? {
        
        let viewController = viewController ?? UIApplication.shared.windows.first?.rootViewController
        
        if let navigationController = viewController as? UINavigationController {
            return topViewController(viewController: navigationController.visibleViewController)
        }
        
        if let tabBarController = viewController as? UITabBarController {
            return topViewController(viewController: tabBarController.selectedViewController)
        }
        
        if let presented = viewController?.presentedViewController {
            return topViewController(viewController: presented)
        }
        
        return viewController
    }
    
    
}
