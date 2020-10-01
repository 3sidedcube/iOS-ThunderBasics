//
//  UIImage+RoundedCorners.swift
//  ThunderBasics
//
//  Created by Simon Mitchell on 05/11/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import UIKit

extension UIImage {
    
    /// Rounds the given corners of the image
    ///
    /// - Parameters:
    ///   - corners: The corners to round
    ///   - radius: The radius to round those corners to
    ///   - size: The size to resize the image to
    /// - Returns: The image with rounded corners
    public func roundingCorners(_ corners: UIRectCorner, radius: CGFloat, size outputSize: CGSize? = nil) -> UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(outputSize ?? size, false, UIScreen.main.scale)
        let rect = CGRect(origin: .zero, size: outputSize ?? size)
        
        UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius)).addClip()
        
        draw(in: rect)
        
        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return roundedImage
    }
    
    /// Rounds all corners of the image to a given radius and size
    ///
    /// - Parameter radius: The corner radius to use
    /// - Returns: The image with rounded corners
    public func roundingCorners(radius: CGFloat) -> UIImage? {
        return roundingCorners(.allCorners, radius: radius)
    }
}
