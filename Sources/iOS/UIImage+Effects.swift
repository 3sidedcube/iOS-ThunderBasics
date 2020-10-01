//
//  UIImage+Effects.swift
//  ThunderBasics
//
//  Created by Simon Mitchell on 02/11/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import UIKit
import os.log
import Accelerate

fileprivate let imageEffectsLog = OSLog(subsystem: "com.threesidedcube.ThunderCloud", category: "UIImage+ImageEffects")

public extension UIImage {
    
    //MARK: - Blurring! -
    
    /// Adds a blur effect to a frame within the image
    ///
    /// - Parameter style: The style of the blur to apply
    /// - Parameter inFrame: The frame over which to apply the blur
    /// - Returns: The blurred image if sucessful
    func applyingBlur(style: UIBlurEffect.Style, in frame: CGRect? = nil) -> UIImage? {
        
        let tintColor: UIColor?
        var radius: CGFloat = 20.0
        
        switch style {
        case .light:
            tintColor = UIColor(white: 1.0, alpha: 0.3)
            radius = 30.0
        case .extraLight:
            tintColor = UIColor(white: 0.97, alpha: 0.82)
        case .dark:
            tintColor = UIColor(white: 0.11, alpha: 0.73)
        default:
            tintColor = nil
        }
        
        guard let frame = frame, frame.size != size || frame.origin != .zero else {
            return applyingBlurWith(radius: radius, tintColor: tintColor, saturationDeltaFactor: 1.8, maskImage: nil)
        }
        
        guard let blurredCroppedImage = cropped(to: frame)?.applyingBlur(style: style) else { return nil }
        return adding(image: blurredCroppedImage, at: frame.origin)
    }
    
    /// Adds a tint effect to a frame within the image
    ///
    /// - Parameters:
    ///   - color: The color to tint the are of the image with
    ///   - frame: The frame over which to apply the tint
    /// - Returns: The tinted and blurred image if sucessful
    func applyingTint(_ color: UIColor, in frame: CGRect? = nil) -> UIImage? {
        
        guard let frame = frame, frame.size != size || frame.origin != .zero else {
            return applyingBlurWith(radius: 10, tintColor: color, saturationDeltaFactor: 1.8, maskImage: nil)
        }
        
        guard let blurredCroppedImage = cropped(to: frame)?.applyingBlurWith(radius: 10, tintColor: color, saturationDeltaFactor: 1.8, maskImage: nil) else { return nil }
        return adding(image: blurredCroppedImage, at: frame.origin)
    }
    
    /// Applies a blur effect to
    ///
    /// - Parameters:
    ///   - radius: The blur radius to apply
    ///   - tintColor: The tint colour of the blur
    ///   - saturationDeltaFactor: The saturation to apply as well as a blur
    ///   - maskImage: An image to mask the blur using
    /// - Returns: The image blurred and tinted if the operation was sucessful
    func applyingBlurWith(radius blurRadius: CGFloat, tintColor: UIColor? = nil, saturationDeltaFactor: CGFloat = 1.8, maskImage: UIImage? = nil) -> UIImage? {
        
        guard size.width >= 1, size.height >= 1 else {
            os_log("Invalid size: (%{public}.2f x %{public}.2f). Both dimensions must be >= 1: %{public}@", log: imageEffectsLog, type: .error, size.width, size.height, self)
            return nil
        }
        
        guard let cgImage = cgImage else {
            os_log("image must be backed by a CGImage: %{public}@", log: imageEffectsLog, type: .error, self)
            return nil
        }
        
        if let maskImage = maskImage, maskImage.cgImage == nil {
            os_log("maskImage must be backed by a CGImage: %{public}@", log: imageEffectsLog, type: .error, maskImage)
            return nil
        }
        
        let imageRect = CGRect(origin: .zero, size: size)
        var effectImage: UIImage?
        
        let hasBlur = blurRadius > .ulpOfOne
        let hasSaturationChange = abs(saturationDeltaFactor - 1.0) > .ulpOfOne
        
        if hasBlur || hasSaturationChange {
            
            UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
            guard let effectInContext = UIGraphicsGetCurrentContext() else {
                return nil
            }
            
            effectInContext.scaleBy(x: 1.0, y: -1.0)
            effectInContext.translateBy(x: 0, y: -size.height)
            
            effectInContext.draw(cgImage, in: imageRect)
            
            var effectInBuffer =
                vImage_Buffer(
                    data: effectInContext.data,
                    height: vImagePixelCount(effectInContext.height),
                    width: vImagePixelCount(effectInContext.width),
                    rowBytes: effectInContext.bytesPerRow
            )
            
            UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
            
            guard let effectOutContext = UIGraphicsGetCurrentContext() else {
                return nil
            }
            
            var effectOutBuffer =
                vImage_Buffer(
                    data: effectOutContext.data,
                    height: vImagePixelCount(effectOutContext.height),
                    width: vImagePixelCount(effectOutContext.width),
                    rowBytes: effectOutContext.bytesPerRow
            )
            
            if hasBlur {
                
                // A description of how to compute the box kernel width from the Gaussian
                // radius (aka standard deviation) appears in the SVG spec:
                // http://www.w3.org/TR/SVG/filters.html#feGaussianBlurElement
                //
                // For larger values of 's' (s >= 2.0), an approximation can be used: Three
                // successive box-blurs build a piece-wise quadratic convolution kernel, which
                // approximates the Gaussian kernel to within roughly 3%.
                //
                // let d = floor(s * 3*sqrt(2*pi)/4 + 0.5)
                //
                // ... if d is odd, use three box-blurs of size 'd', centered on the output pixel.
                //
                let inputRadius = blurRadius * UIScreen.main.scale
                let sqrt2pi = CGFloat(sqrt(2.0 * .pi))
                var radius = floor(inputRadius * 3.0 * sqrt2pi / 4 + 0.5)
                
                if radius.truncatingRemainder(dividingBy: 2) != 1 {
                    radius += 1 // force radius to be odd so that the three box-blur methodology works.
                }
                
                vImageBoxConvolve_ARGB8888(
                    &effectInBuffer,
                    &effectOutBuffer,
                    nil,
                    0,
                    0,
                    UInt32(radius),
                    UInt32(radius),
                    nil,
                    vImage_Flags(kvImageEdgeExtend)
                )
                
                vImageBoxConvolve_ARGB8888(
                    &effectOutBuffer,
                    &effectInBuffer,
                    nil,
                    0,
                    0,
                    UInt32(radius),
                    UInt32(radius),
                    nil,
                    vImage_Flags(kvImageEdgeExtend)
                )
                
                vImageBoxConvolve_ARGB8888(
                    &effectInBuffer,
                    &effectOutBuffer,
                    nil,
                    0,
                    0,
                    UInt32(radius),
                    UInt32(radius),
                    nil,
                    vImage_Flags(kvImageEdgeExtend)
                )
            }
            
            var effectImageBuffersAreSwapped = false
            
            if hasSaturationChange {
                
                let s = saturationDeltaFactor
                let floatingPointSaturationMatrix: [CGFloat] = [
                    0.0722 + 0.9278 * s, 0.0722 - 0.0722 * s, 0.0722 - 0.0722 * s, 0,
                    0.7152 - 0.7152 * s, 0.7152 + 0.2848 * s, 0.7152 - 0.7152 * s, 0,
                    0.2126 - 0.2126 * s, 0.2126 - 0.2126 * s, 0.2126 + 0.7873 * s, 0,
                    0, 0, 0, 1
                ]

                let divisor: CGFloat = 256
                let matrixSize = MemoryLayout.size(ofValue: floatingPointSaturationMatrix) / MemoryLayout.size(ofValue: floatingPointSaturationMatrix[0])

                var saturationMatrix = [Int16](repeating: 0, count: matrixSize)

                saturationMatrix = floatingPointSaturationMatrix.map({ (saturation) -> Int16 in
                    return Int16(round(saturation * divisor))
                })

                effectImageBuffersAreSwapped = hasBlur

                var srcBuffer = hasBlur ? effectOutBuffer : effectInBuffer
                var destBuffer = hasBlur ? effectInBuffer : effectOutBuffer

                vImageMatrixMultiply_ARGB8888(
                    &srcBuffer,
                    &destBuffer,
                    saturationMatrix,
                    Int32(divisor),
                    nil,
                    nil,
                    vImage_Flags(kvImageNoFlags)
                )
            }
            
            if !effectImageBuffersAreSwapped {
                effectImage = UIGraphicsGetImageFromCurrentImageContext()
            }
            
            UIGraphicsEndImageContext()
            
            if effectImageBuffersAreSwapped {
                effectImage = UIGraphicsGetImageFromCurrentImageContext()
            }
            
            UIGraphicsEndImageContext()
        }
        
        // set up output context
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        guard let outputContext = UIGraphicsGetCurrentContext() else { return nil }
        outputContext.scaleBy(x: 1.0, y: -1.0)
        outputContext.translateBy(x: 0, y: -size.height)
        
        // draw base image
        outputContext.draw(cgImage, in: imageRect)
        
        // draw effect image
        if hasBlur {
            outputContext.saveGState()
            if let maskCGImage = maskImage?.cgImage {
                outputContext.clip(to: imageRect, mask: maskCGImage)
            }
            if let effectCGImage = (effectImage ?? self).cgImage {
                outputContext.draw(effectCGImage, in: imageRect)
            }
            outputContext.restoreGState()
        }
        
        // Add in color tint
        if let tintCGColor = tintColor?.cgColor {
            outputContext.saveGState()
            outputContext.setFillColor(tintCGColor)
            outputContext.fill(imageRect)
            outputContext.restoreGState()
        }
        
        // return image
        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return outputImage
    }
    
    //MARK: - Tinting -
    
    /// Applies a tint effect to the image with an optional blur
    ///
    /// - Parameters:
    ///   - tintColor: The colour of the tint effect to apply
    ///   - blur: Whether to blur the image too (defaults to true)
    /// - Returns: The tinted (and blurred) image if sucessful
    func applyingTintEffectWith(color tintColor: UIColor, blur: Bool = true) -> UIImage? {
        
        let effectColorAlpha: CGFloat = 0.6
        var effectColor = tintColor
        
        if tintColor.cgColor.numberOfComponents == 2 {
            
            var w: CGFloat = 0.0
            if tintColor.getWhite(&w, alpha: nil) {
                effectColor = UIColor(white: w, alpha: effectColorAlpha)
            }
            
        } else {
            
            var r: CGFloat = 0.0
            var g: CGFloat = 0.0
            var b: CGFloat = 0.0
            
            if tintColor.getRed(&r, green: &g, blue: &b, alpha: nil) {
                effectColor = UIColor(red: r, green: g, blue: b, alpha: effectColorAlpha)
            }
        }
        
        let blurRadius: CGFloat = blur ? 10.0 : 0.0
        
        return applyingBlurWith(radius: blurRadius, tintColor: effectColor, saturationDeltaFactor: -1.0, maskImage: nil)
    }
}
