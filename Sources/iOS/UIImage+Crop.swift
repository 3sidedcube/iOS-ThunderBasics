//
//  UIImage+Crop.swift
//  ThunderBasics
//
//  Created by Simon Mitchell on 02/11/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import UIKit

public extension UIImage {
    
    /// A square crop (centered) of the current image
    var croppedToSquare: UIImage? {
        
        let smallestSide = min(size.width, size.height)
        let remainingWidth = size.width - smallestSide
        let remainingHeight = size.height - smallestSide
        
        let xOffset = floor(remainingWidth / 2)
        let yOffset = floor(remainingHeight / 2)
        
        let cropRect = CGRect(x: xOffset, y: yOffset, width: smallestSide, height: smallestSide)
        return cropped(to: cropRect)
    }
    
    /// Crops the image to a particular frame
    ///
    /// - Parameter frame: The frame
    /// - Returns: The cropped part of the image
    func cropped(to frame: CGRect) -> UIImage? {
        
        var cropRect = frame
        if scale > 1.0 {
            cropRect = CGRect(
                x: cropRect.minX * scale,
                y: cropRect.minY * scale,
                width: cropRect.width * scale,
                height: cropRect.height * scale
            )
        }
        
        guard let imageRef = cgImage?.cropping(to: cropRect) else { return nil }
        return UIImage(cgImage: imageRef, scale: scale, orientation: imageOrientation)
    }
    
    /// Draws an image on-top of the current image at a particular point
    ///
    /// - Parameters:
    ///   - image: The image to overlay
    ///   - point: The point at which to overlay the image
    /// - Returns: The combined image
    func adding(image: UIImage, at point: CGPoint) -> UIImage? {
        
        UIGraphicsBeginImageContext(size)
        draw(at: .zero)
        
        image.draw(at: point)
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return result
    }
}
