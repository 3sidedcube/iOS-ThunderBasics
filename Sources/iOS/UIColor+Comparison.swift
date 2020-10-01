//
//  UIColor+Comparison.swift
//  ThunderBasics
//
//  Created by Simon Mitchell on 02/11/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import UIKit

// MARK: - A set of helpful extensions to UIColor for comparison
extension UIColor {
    
    /// Returns whether the colour is distinct from another colour by a particular threshold
    ///
    /// - Parameter color: The color to compare with
    /// - Parameter threshold: The threshold to check
    /// - Returns: Whether the colours are distinct from each other
    public func isDistinctFrom(color: UIColor, threshold: CGFloat = 0.25) -> Bool {
        
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        var red1: CGFloat = 0.0
        var green1: CGFloat = 0.0
        var blue1: CGFloat = 0.0
        var alpha1: CGFloat = 0.0
        
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        color.getRed(&red1, green: &green1, blue: &blue1, alpha: &alpha1)
        
        let diffs = [
            abs(red - red1),
            abs(green - green1),
            abs(blue - blue1),
            abs(alpha - alpha1)
        ]
        
        guard diffs.contains(where: { $0 > threshold }) else {
            return false
        }
        
        // Check for grays, prevent multiple gray colors
        if abs(red - green) < 0.03 && abs(red - blue) < 0.03 &&
            abs(red1 - green1) < 0.03 && abs(red1 - blue1) < 0.03 {
            return false
        }
        
        return true
    }
    
    /// Returns whether the colour is "dark"
    public var isDark: Bool {
        return luminance < 0.5
    }
    
    /// Returns the luminance of the colour
    public var luminance: CGFloat {
        
        // https://www.w3.org/TR/WCAG20-TECHS/G18.html#G18-tests
        let ciColor = CIColor(color: self)
        
        func adjust(colorComponent: CGFloat) -> CGFloat {
            return (colorComponent < 0.03928) ? (colorComponent / 12.92) : pow((colorComponent + 0.055) / 1.055, 2.4)
        }
        
        return 0.2126 * adjust(colorComponent: ciColor.red) + 0.7152 * adjust(colorComponent: ciColor.green) + 0.0722 * adjust(colorComponent: ciColor.blue)
    }
    
    /// Returns whether the colour is near enough to black or white
    /// to be considered so
    public var isNearBlackOrWhite: Bool {
        return isNearBlackOrWhite(threshold: 0.09)
    }
    
    /// Returns whether the colour is near enough to black or white to be considered so
    /// - Parameter threshold: The threshold to use when performing the calculation
    public func isNearBlackOrWhite(threshold: CGFloat) -> Bool {
        
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        getRed(&red, green: &green, blue: &blue, alpha: nil)
        
        let values = [red, green, blue]
        return values.allSatisfy({ $0 > (1.0 - threshold) }) || values.allSatisfy({ $0 < threshold })
    }
    
    /// Returns the contrast ratio between two colours
    ///
    /// - Parameters:
    ///   - color: The color to return the contrast ratio between
    /// - Returns: The constrast ratio between the two colours
    public func contrastRatioWith(_ color: UIColor) -> CGFloat {
        
        let luminance1 = luminance
        let luminance2 = color.luminance
        
        let luminanceDarker = min(luminance1, luminance2)
        let luminanceLighter = max(luminance1, luminance2)
        
        return (luminanceLighter + 0.05) / (luminanceDarker + 0.05)
    }
    
    /// Returns whether the colour contrasts enough with another colour
    ///
    /// - Parameters:
    ///   - color: The colour to compare contrasts with
    ///   - ratio: The ratio limit we need to hit
    /// - Returns: Whether the colours contrast by the provided ratio
    func doesContrastWith(color: UIColor, by ratio: CGFloat = 1.6) -> Bool {
        return contrastRatioWith(color) > ratio
    }
    
    /// Returns the same colour but with saturation bumped to meet the minimum value provided
    ///
    /// - Parameter minimumSaturation: The minimum saturation required
    /// - Returns: The original colour with the saturation bumped to at least `minimumSaturation`
    func with(minimumSaturation: CGFloat) -> UIColor {
        
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        guard saturation < minimumSaturation else {
            return self
        }
        
        return UIColor(hue: hue, saturation: minimumSaturation, brightness: brightness, alpha: alpha)
    }
}
