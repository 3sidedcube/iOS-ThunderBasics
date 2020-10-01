//
//  UIWindow+VisibleViewController.swift
//  ThunderBasics
//
//  Created by Simon Mitchell on 06/11/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import UIKit

extension UIWindow {
    
    /// Returns the topmost view controller (i.e. the one visible to the user)
    public var visibleViewController: UIViewController? {
        
        guard let rootViewController = rootViewController else {
            return nil
        }
        
        guard let splitViewController = rootViewController.splitViewController else {
            return visibleViewController(in: rootViewController)
        }
        
        // If none of the split view controller's view controllers are presenting
        guard let presentedViewController = splitViewController.viewControllers.first(where: { $0.presentedViewController != nil })?.presentedViewController else {
            guard let lastViewController = splitViewController.viewControllers.last else {
                return nil
            }
            return visibleViewController(in: lastViewController)
        }
        
        // If any of the split view controller's viewControllers are presenting, work up their heirarchy
        return visibleViewController(in: presentedViewController)
    }
    
    private func visibleViewController(in viewController: UIViewController) -> UIViewController? {
        
        // Work up the view hierarchy if presenting
        if let presentedViewController = viewController.presentedViewController {
            return visibleViewController(in: presentedViewController)
        }
        
        switch viewController {
        case let navigationController as UINavigationController:
            guard let lastViewController = navigationController.viewControllers.last else {
                return navigationController
            }
            return visibleViewController(in: lastViewController)
        case let tabBarController as UITabBarController:
            guard let selectedViewController = tabBarController.selectedViewController else {
                return tabBarController
            }
            return visibleViewController(in: selectedViewController)
        default:
            return viewController
        }
    }
}
