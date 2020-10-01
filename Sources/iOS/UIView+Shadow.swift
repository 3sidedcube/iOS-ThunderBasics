//
//  UIView+Shadow.swift
//  ThunderBasics-iOS
//
//  Created by Ben Shutt on 23/01/2020.
//  Copyright © 2020 threesidedcube. All rights reserved.
//

import UIKit

/// A pre-defined shadow offset
public enum ShadowDirection {
    
    /// Appears at the top
    case top
    
    /// Appears at the bottom
    case bottom
    
    /// Appears on the left
    case left
    
    /// Appears on the right
    case right
    
    /// Appears about the center
    case center
    
    /// 2D offset based on the `ShadowDirection`.
    ///
    /// - Parameter radius: A shadow radius
    func offset(radius: CGFloat) -> CGSize {
        switch self {
        case .top: return CGSize(width: 0, height: -radius)
        case .bottom: return CGSize(width: 0, height: radius)
        case .left: return CGSize(width: -radius, height: 0)
        case .right: return CGSize(width: radius, height: 0)
        case .center: return CGSize(width: 0, height: 0)
        }
    }
}

public extension UIView {
    
    /// A variable that allows you to set the shadow of a view simply using `ShadowComponents`
    var shadow: ShadowComponents? {
        set {
            layer.shadow = newValue
        }
        get {
            return layer.shadow
        }
    }
    
    /// Add shadow to a `UIView`.
    ///
    /// - Parameters:
    ///   - direction: `ShadowDirection` to define how the shadow should appear on the `UIView`
    ///   - color: `shadowColor` as a `UIColor`
    ///   - opacity: `shadowOpacity`
    ///   - radius: `shadowRadius`
    func addShadow(direction: ShadowDirection,
                   color: UIColor = .lightGray,
                   opacity: Float = 0.5,
                   radius: CGFloat = 1)
    {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = direction.offset(radius: radius)
        layer.shadowRadius = radius
        
        //layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        //layer.shouldRasterize = true
        //layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    
    /// Round a subset of `UIRectCorner`s.
    ///
    /// - Parameters:
    ///   - corners: Which corners to add radius to
    ///   - radius: Radius of the corner
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        if #available(iOS 11, *) {
            self.layer.cornerRadius = radius
            self.layer.maskedCorners = corners.cornerMask
        } else {
            let path = UIBezierPath(
                roundedRect: bounds,
                byRoundingCorners: corners, cornerRadii:
                CGSize(width: radius, height: radius))
            
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            layer.mask = mask
        }
    }
}

public extension UIRectCorner {
    
    /// `UIRectCorner` to `CACornerMask`
    var cornerMask: CACornerMask {
        var cornerMask = CACornerMask()
        
        if (contains(.topLeft)){
            cornerMask.insert(.layerMinXMinYCorner)
        }
        if (contains(.topRight)){
            cornerMask.insert(.layerMaxXMinYCorner)
        }
        if (contains(.bottomLeft)){
            cornerMask.insert(.layerMinXMaxYCorner)
        }
        if (contains(.bottomRight)){
            cornerMask.insert(.layerMaxXMaxYCorner)
        }
        
        return cornerMask
    }
}
