//
//  UIImage+Resize.swift
//  ThunderBasics
//
//  Created by Simon Mitchell on 05/11/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import UIKit

extension UIImage {
    
    /// Returns a copy of the image squared to the thumbnail size
    ///
    /// - Parameters:
    ///   - size: The size of the thumbnail to return
    ///   - transparentBorderSize: The width of the transparent border to add. (Adding a transparent border of at least one pixel in size has the side-effect of antialiasing the edges of the image when rotating it using Core Animation.)
    ///   - cornerRadius: The corner radius to round the image corners to
    ///   - quality: The interpolation quality to apply when resizing
    /// - Returns: The thumbnailed image
    public func thumbnail(size thumbnailSize: CGFloat, transparentBorderSize: CGFloat = 0.0, cornerRadius: CGFloat = 0.0, quality: CGInterpolationQuality = .high) -> UIImage? {
        
        let ratio: CGFloat
        if size.width > size.height {
            ratio = thumbnailSize/size.height
        } else {
            ratio = thumbnailSize/size.width
        }
        
        guard let resizedImage = resizedTo(CGSize(width: size.width * ratio, height: size.height * ratio), contentMode: .scaleAspectFill, interpolationQuality: quality) else {
            return nil
        }
        
        // Crop out any part of the image that's larger than the thumbnail size
        // The cropped rect must be centered on the resized image
        // Round the origin points so that the size isn't altered when CGRectIntegral is later invoked
        let cropRect = CGRect(origin: .zero, size: CGSize(width: thumbnailSize, height: thumbnailSize))
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: thumbnailSize, height: thumbnailSize), false, UIScreen.main.scale)
        
        // Add a clip before drawing anything, in the shape of a rounded rect
        UIBezierPath(roundedRect: cropRect, cornerRadius: cornerRadius).addClip()
        
        // Draw the image
        resizedImage.draw(in: CGRect(
            origin: CGPoint(
                x: -(resizedImage.size.width - thumbnailSize)/2,
                y: -(resizedImage.size.height - thumbnailSize)/2),
            size: resizedImage.size
        ))
        
        // Get the cropped image
        let croppedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // Let's forget that we were drawing
        UIGraphicsEndImageContext()
        
        return croppedImage
    }
    
    /// Returns a copy of the image that has been resized, and transformed using the transform if provided
    ///
    /// - Parameters:
    ///   - size: The size to transform the image to. This will be integralled upwards
    ///   - interpolationQuality: The interpolation quality to use when resizing
    ///   - transform: The transform to apply, if not provided this will be calculated for you from the images orientation.
    ///   - transpose: Whether to transpose the image when redrawing.
    /// - Returns: The resized version of the image
    public func resizedTo(_ size: CGSize, interpolationQuality: CGInterpolationQuality, transform: CGAffineTransform? = nil, transpose: Bool = false) -> UIImage? {
        
        var drawTransposed = transpose
        let finalTransform: CGAffineTransform = transform ?? orientationFixTransform(size: size)
        
        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            drawTransposed = true
        default:
            break
        }
        
        let scale = max(1.0, self.scale)
        let newRect = CGRect(origin: .zero, size: CGSize(width: size.width * scale, height: size.height * scale)).integral
        let transposedRect = CGRect(origin: .zero, size: CGSize(width: newRect.size.height, height: newRect.size.width))
        
        guard let imageRef = cgImage else { return nil }
        
        // Fix for a colorspace / transparency issue that affects some types of
        // images. See here: http://vocaro.com/trevor/blog/2009/10/12/resize-a-uiimage-the-right-way/comment-page-2/#comment-39951
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(
            data: nil,
            width: Int(newRect.size.width),
            height: Int(newRect.size.height),
            bitsPerComponent: 8,
            bytesPerRow: Int(newRect.size.width * 4),
            space: colorSpace,
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue).rawValue
        ) else { return nil }
        
        // Rotate and/or flip the image if required by it's orientation
        context.concatenate(finalTransform)
        
        // Set quality level to use when rescaling
        context.interpolationQuality = interpolationQuality
        
        // Draw into the context, this scales the image
        context.draw(imageRef, in: drawTransposed ? transposedRect : newRect)
        
        // Get the resized image from the context and a UIImage
        guard let scaledImageRef = context.makeImage() else { return nil }
        return UIImage(cgImage: scaledImageRef, scale: self.scale, orientation: .up)
    }
    
    /// Returns a resized version of the image to a given size using provided content mode and interpolation quality, taking into account the image's orientation
    ///
    /// - Parameters:
    ///   - size: The size of the image to return
    ///   - contentMode: The content mode to use to resize
    ///   - interpolationQuality: The interpolation quality of the returned image
    /// - Returns: The resized image
    public func resizedTo(_ size: CGSize, contentMode: UIView.ContentMode = .scaleAspectFill, interpolationQuality: CGInterpolationQuality = .high) -> UIImage? {
        
        let horizontalRatio = size.width / self.size.width
        let verticalRatio = size.height / self.size.height
        
        let ratio: CGFloat
        
        switch contentMode {
        case .scaleAspectFill:
            ratio = max(horizontalRatio, verticalRatio)
        case .scaleAspectFit:
            ratio = min(horizontalRatio, verticalRatio)
        default:
            fatalError("Unsupported content mode sent to resize method: \(contentMode.rawValue)")
        }
        
        let newSize = CGSize(width: self.size.width * ratio, height: self.size.height * ratio)
        
        return resizedTo(newSize, interpolationQuality: interpolationQuality, transform: nil, transpose: false)
    }
    
    /// Returns an affine transform that takes into account the image orientation when drawing a scaled image
    ///
    /// - Parameter size: The size to resize the image to
    /// - Returns: A transform which can be used to transform the image
    public func orientationFixTransform(size: CGSize) -> CGAffineTransform {
        
        var transform: CGAffineTransform = .identity
        switch imageOrientation {
        case .down, .downMirrored: // EXIF = 3, EXIF = 4
            transform = CGAffineTransform(translationX: size.width, y: size.height)
            transform = transform.rotated(by: .pi)
        case .left, .leftMirrored: // EXIF 6, EXIF 5
            transform = CGAffineTransform(translationX: size.width, y: 0)
            transform = transform.rotated(by: .pi/2)
        case .right, .rightMirrored: //EXIF 8, EXIF 7
            transform = CGAffineTransform(translationX: 0, y: size.height)
            transform = transform.rotated(by: -.pi/2)
        default:
            break
        }
        
        switch imageOrientation {
        case .upMirrored, .downMirrored: // EXIF 2, EXIF 4
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored: // EXIF 5, EXIF 7
            transform = transform.translatedBy(x: size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        default:
            break
        }
        
        return transform
    }
}
