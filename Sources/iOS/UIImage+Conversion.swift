//
//  UIImage+Conversion.swift
//  ThunderBasics
//
//  Created by Simon Mitchell on 05/11/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import UIKit
import CoreGraphics

extension UIImage {
    
    public var convertedToGrayscale: UIImage? {
        
        guard let cgImage = cgImage else { return nil }
        
        let imageRect = CGRect(origin: .zero, size: size)
        let colorSpace = CGColorSpaceCreateDeviceGray()
        
        guard let context = CGContext(
            data: nil,
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue).rawValue
        ) else { return nil }
        
        context.draw(cgImage, in: imageRect)
        
        guard let grayImage = context.makeImage() else { return nil }
        guard let alphaContext = CGContext(
            data: nil,
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.alphaOnly.rawValue).rawValue
        ) else {
            return nil
        }
        
        alphaContext.draw(cgImage, in: imageRect)
        guard let maskImage = context.makeImage() else {
            return nil
        }
        guard let maskedImage = grayImage.masking(maskImage) else {
            return nil
        }
        
        let grayscaleImage = UIImage(cgImage: maskedImage, scale: scale, orientation: imageOrientation)
        return grayscaleImage
    }
    
    /// Allocates a bundled image, tinted to a particular colour
    ///
    /// - Parameters:
    ///   - name: The image name in the bundle
    ///   - bundle: The bundle to look for the image
    ///   - traitCollection: The trait collection this image should be compatible with
    ///   - color: The colour to tint the image with
    public class func image(named name: String, withColor color: UIColor, in bundle: Bundle? = .main, compatibleWith traitCollection: UITraitCollection? = nil) -> UIImage? {
        
        guard var image = UIImage(named: name, in: bundle, compatibleWith: traitCollection) else {
            return nil
        }
        
        image = image.withRenderingMode(.alwaysTemplate)
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        color.set()
        
        image.draw(in: CGRect(origin: .zero, size: image.size))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let _newImage = newImage else { return nil }
        
        return _newImage
    }
}
