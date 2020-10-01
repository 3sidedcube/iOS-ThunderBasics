//
//  UIViewController+DismissAnimated.swift
//  ThunderBasics
//
//  Created by Simon Mitchell on 06/11/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import UIKit

extension UIViewController {
    /// Dismissed the view controller in an animated fashion
    @objc open func dismissAnimated() {
        dismiss(animated: true, completion: nil)
    }
}
