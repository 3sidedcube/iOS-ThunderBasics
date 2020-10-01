//
//  CAGradientLayer+AutoGradient.swift
//  ThunderBasics
//
//  Created by Simon Mitchell on 05/11/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import UIKit

public extension CAGradientLayer {
    
    /// Creates a `CAGradientLayer` transitioning from one color to another.
    /// A transparent color can be parsed to create dark to translucent gradients.
    ///
    /// - Parameters:
    ///   - topColor: The gradients top color represented as a `UIColor`. Starts at location 0.0
    ///   - bottomColor: The gradients bottom color represented as a `UIColor`. Starts at location 1.0
    convenience init(topColor: UIColor, bottomColor: UIColor) {
        self.init()
        colors = [topColor.cgColor, bottomColor.cgColor]
        locations = [0.0, 1.0].map({ NSNumber(value: $0) })
    }
}
