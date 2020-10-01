//
//  CALayer+Shadow.swift
//  ShadowView
//
//  Created by Simon Mitchell on 23/07/2020.
//  Copyright © 2020 3 Sided Cube. All rights reserved.
//

import UIKit

extension CALayer {
    
    /// A variable that allows you to set the shadow of a layer simply using `ShadowComponents`
    var shadow: ShadowComponents? {
        set {
            guard let newValue = newValue else {
                shadowColor = UIColor.black.cgColor
                shadowOpacity = 0
                shadowOffset = CGSize(width: 0, height: -3)
                shadowRadius = 3
                return
            }
            shadowRadius = newValue.radius
            shadowOpacity = newValue.opacity
            shadowColor = newValue.color.cgColor
            shadowOffset = newValue.offset
        }
        get {
            guard let shadowColor = shadowColor else {
                return nil
            }
            let color = UIColor(cgColor: shadowColor)
            return ShadowComponents(
                radius: shadowRadius,
                opacity: shadowOpacity,
                color: color,
                offset: shadowOffset
            )
        }
    }
}
