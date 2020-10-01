//
//  UITabBarController+EasyInit.swift
//  ThunderBasics
//
//  Created by Simon Mitchell on 06/11/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import UIKit

extension UITabBarController {
    
    /// Initializes a `UITabBarController` with an array of `UIViewController`s.
    ///
    /// - Parameters:
    ///   - viewControllers: The view controllers to be displayed in the `UITabBarController`
    ///   - nestInsideNavigationControllers: Whether each view controller should be nested in `UINavigationController` instances or not
    public convenience init(viewControllers: [UIViewController], nestInsideNavigationControllers: Bool = false) {
        
        self.init()
        
        guard nestInsideNavigationControllers else {
            self.viewControllers = viewControllers
            return
        }
        
        self.viewControllers = viewControllers.map({ UINavigationController(rootViewController: $0) })
    }
}
