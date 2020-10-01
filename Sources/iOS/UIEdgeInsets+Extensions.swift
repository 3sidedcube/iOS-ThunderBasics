//
//  UIEdgeInsets+Extensions.swift
//  ThunderBasics-iOS
//
//  Created by Ben Shutt on 23/01/2020.
//  Copyright © 2020 threesidedcube. All rights reserved.
//

import UIKit

public extension UIEdgeInsets {
    
    /// Set all properties:
    /// `top`, `left`, `bottom`, `right`
    /// to the same given value
    /// - Parameter value: Fixed value for all properties
    init (value: CGFloat) {
        self.init(top: value, left: value, bottom: value, right: value)
    }

    /// Sum `left` and `right`
    var horizontalSum: CGFloat {
        return left + right
    }

    /// Sum `top` and `bottom`
    var verticalSum: CGFloat {
        return top + bottom
    }
}
