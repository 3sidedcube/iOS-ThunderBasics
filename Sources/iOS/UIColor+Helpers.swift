//
//  UIColor+Helpers.swift
//  ThunderBasics
//
//  Created by Simon Mitchell on 05/11/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import UIKit

extension UIColor {
    
    /// A structual representation of a colour's RGBA components as floats
    /// between 0 and 1
    public struct RGBAComponents: Equatable {
        
        /// Red component of the colour [0, 1]
        public let red: CGFloat
        
        /// Green component of the colour [0, 1]
        public let green: CGFloat
        
        /// Blue component of the colour [0, 1]
        public let blue: CGFloat
        
        /// The alpha component of the colour [0, 1]
        public let alpha: CGFloat
        
        /// Public default memberwise initialiser
        /// - Parameters:
        ///   - red: The red component of the colour
        ///   - green: The green component of the colour
        ///   - blue: The blue component of the colour
        ///   - alpha: The alpha component of the colour
        public init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
            self.red = red
            self.green = green
            self.blue = blue
            self.alpha = alpha
        }
    }
    
    /// Returns a random colour
    public var random: UIColor {
        let red = CGFloat.random(in: 0 ... 1)
        let green = CGFloat.random(in: 0 ... 1)
        let blue = CGFloat.random(in: 0 ... 1)
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    /// The color space model from the color
    public var colorSpaceModel: CGColorSpaceModel? {
        return cgColor.colorSpace?.model
    }
    
    /// Returns the RGBA components of the colour
    public var rgbaComponents: RGBAComponents? {
        
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        
        guard getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return nil
        }
        
        return .init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    /// Returns the HSBA components of the colour
    public var hsbaComponents: (hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat)? {
        
        var hue: CGFloat = 0.0
        var saturation: CGFloat = 0.0
        var brightness: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        
        guard getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) else {
            return nil
        }
        
        return (hue, saturation, brightness, alpha)
    }
    
    /// Returns the grayscale components of the colour
    public var grayscaleComponents: (white: CGFloat, alpha: CGFloat)? {
        
        var white: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        
        guard getWhite(&white, alpha: &alpha) else {
            return nil
        }
        
        return (white, alpha)
    }
    
    /// The hue of the colour
    public var hue: CGFloat? {
        var hue: CGFloat = 0.0
        guard getHue(&hue, saturation: nil, brightness: nil, alpha: nil) else {
            return nil
        }
        return hue
    }
    
    /// The hue of the colour
    public var saturation: CGFloat? {
        var saturation: CGFloat = 0.0
        guard getHue(nil, saturation: &saturation, brightness: nil, alpha: nil) else {
            return nil
        }
        return saturation
    }
    
    /// The brightness of the colour
    public var brightness: CGFloat? {
        var brightness: CGFloat = 0.0
        guard getHue(nil, saturation: nil, brightness: &brightness, alpha: nil) else {
            return nil
        }
        return brightness
    }
    
    /// The alpha component of the colour
    public var alpha: CGFloat {
        return cgColor.alpha
    }
    
    /// Creates a new colour from it's rgb Hex value
    ///
    /// - Parameter hex: The hex value to create the colour from
    public convenience init(rgbHex hex: UInt32) {
        let red = CGFloat((hex >> 16) & 0xFF)
        let green = CGFloat((hex >> 8) & 0xFF)
        let blue = CGFloat((hex) & 0xFF)
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)        
    }
    
    /// The RGB Hex int of the colour
    public var rgbHex: UInt32? {
        
        guard let rgbaComponents = rgbaComponents else { return nil }
        
        let r = Float(min(max(rgbaComponents.red, 0.0), 1.0))
        let g = Float(min(max(rgbaComponents.green, 0.0), 1.0))
        let b = Float(min(max(rgbaComponents.blue, 0.0), 1.0))
        
        return (UInt32(roundf(r * 255.0)) << 16)
            | (UInt32(roundf(g * 255.0)) << 8)
            | (UInt32(roundf(b * 255.0)))
    }
    
    /// Returns a grey-scale representation of the color
    public var luminanceMapped: UIColor {
        return UIColor(white: luminance, alpha: 1.0)
    }
    
    /// Multiples the colour by a set of RGBA components
    ///
    /// - Parameters:
    ///   - red: The red component of the multiple
    ///   - green: The green component of the multiple
    ///   - blue: The blue component of the multiple
    ///   - alpha: The alpha component of the multiple
    /// - Returns: Returns the result of the multiplication
    public func multipliedByRed(_ red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor? {
        
        guard let components = rgbaComponents else { return nil }
        
        return UIColor(
            red: max(0.0, min(1.0, red * components.red)),
            green: max(0.0, min(1.0, green * components.green)),
            blue: max(0.0, min(1.0, blue * components.blue)),
            alpha: max(0.0, min(1.0, alpha * components.alpha))
        )
    }
    
    /// Adds a set of RGBA components to the colour
    ///
    /// - Parameters:
    ///   - red: The red component of the addition
    ///   - green: The green component of the addition
    ///   - blue: The blue component of the addition
    ///   - alpha: The alpha component of the addition
    /// - Returns: Returns the result of the addition
    public func addingRed(_ red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor? {
        
        guard let components = rgbaComponents else { return nil }
        
        return UIColor(
            red: max(0.0, min(1.0, red + components.red)),
            green: max(0.0, min(1.0, green + components.green)),
            blue: max(0.0, min(1.0, blue + components.blue)),
            alpha: max(0.0, min(1.0, alpha + components.alpha))
        )
    }
    
    /// Lightens the colour to the components provided
    ///
    /// This allocates a new colour using max(component, red) on each rgba component
    ///
    /// - Parameters:
    ///   - red: The red component of the lightening
    ///   - green: The green component of the lightening
    ///   - blue: The blue component of the lightening
    ///   - alpha: The alpha component of the lightening
    /// - Returns: Returns the result of the lightening
    public func lightenedToRed(_ red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor? {
        
        guard let rhsRGBA = rgbaComponents else { return nil }

        return UIColor(red: max(red, rhsRGBA.red), green: max(green, rhsRGBA.green), blue: max(blue, rhsRGBA.blue), alpha: max(alpha, rhsRGBA.alpha))
    }
    
    /// Darkens the colour to the components provided
    ///
    /// This allocates a new colour using min(component, red) on each rgba component
    ///
    /// - Parameters:
    ///   - red: The red component of the darkening
    ///   - green: The green component of the darkening
    ///   - blue: The blue component of the darkening
    ///   - alpha: The alpha component of the darkening
    /// - Returns: Returns the result of the darkening
    public func darkenedToRed(_ red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor? {
        
        guard let rhsRGBA = rgbaComponents else { return nil }
        
        return UIColor(red: min(red, rhsRGBA.red), green: min(green, rhsRGBA.green), blue: min(blue, rhsRGBA.blue), alpha: min(alpha, rhsRGBA.alpha))
    }
    
    /// Multiplies each RGBA component by the factor provided
    ///
    /// - Parameter factor: The multiplication factor
    /// - Returns: The result of the multiplication
    public func multipliedBy(_ factor: CGFloat) -> UIColor? {
        return multipliedByRed(factor, green: factor, blue: factor, alpha: 1.0)
    }
    
    /// Adds the provided factor to each RGBA component of the color
    ///
    /// - Parameter factor: The factor to add
    /// - Returns: The result of the addition
    public func adding(_ factor: CGFloat) -> UIColor? {
        return addingRed(factor, green: factor, blue: factor, alpha: 0.0)
    }
    
    /// Lightens the each RGBA component of the colour to the value provided
    ///
    /// - Parameter lightness: The lightness of the color
    /// - Returns: The lightened colour
    public func lightenedTo(_ lightness: CGFloat) -> UIColor? {
        return lightenedToRed(lightness, green: lightness, blue: lightness, alpha: lightness)
    }
    
    /// Darkens the each RGBA component of the colour to the value provided
    ///
    /// - Parameter darkness: The darkness of the color
    /// - Returns: The darkened colour
    public func darkenedTo(_ darkness: CGFloat) -> UIColor? {
        return darkenedToRed(darkness, green: darkness, blue: darkness, alpha: darkness)
    }
    
    /// Multiplies each RGBA component by the color provided
    ///
    /// - Parameter color: The multiplication color
    /// - Returns: The result of the multiplication
    public func multipliedBy(_ color: UIColor) -> UIColor? {
        guard let colorRGBA = color.rgbaComponents else { return nil }
        return multipliedByRed(colorRGBA.red, green: colorRGBA.green, blue: colorRGBA.blue, alpha: 0.0)
    }
    
    /// Adds the provided color to each RGBA component of the color
    ///
    /// - Parameter color: The factor to add
    /// - Returns: The result of the addition
    public func adding(_ color: UIColor) -> UIColor? {
        guard let colorRGBA = color.rgbaComponents else { return nil }
        return addingRed(colorRGBA.red, green: colorRGBA.green, blue: colorRGBA.blue, alpha: 0.0)
    }
    
    /// Lightens the each RGBA component of the colour to the same as the color provided
    ///
    /// - Parameter color: The color to ligten using
    /// - Returns: The lightened colour
    public func lightenedTo(_ color: UIColor) -> UIColor? {
        guard let colorRGBA = color.rgbaComponents else { return nil }
        return lightenedToRed(colorRGBA.red, green: colorRGBA.green, blue: colorRGBA.blue, alpha: 0.0)
    }
    
    /// Darkens the each RGBA component of the colour by the color provided
    ///
    /// - Parameter color: The color to darken by
    /// - Returns: The darkened colour
    public func darkenedTo(_ color: UIColor) -> UIColor? {
        guard let colorRGBA = color.rgbaComponents else { return nil }
        return darkenedToRed(colorRGBA.red, green: colorRGBA.green, blue: colorRGBA.blue, alpha: 0.0)
    }
    
    /// A color that contrasts well with this color
    public var contrasting: UIColor {
        return luminance > 0.5 ? .black : .white
    }
    
    /// The color that is 180 degrees away in hue from this color
    public var complementary: UIColor? {
        
        guard let hsba = hsbaComponents else { return nil }
        var hue = hsba.hue
        
        // Pick color 180 degrees away
        hue += 180.0
        
        if hue > 360.0 {
            hue -= 360.0
        }
        
        return UIColor(hue: hue, saturation: hsba.saturation, brightness: hsba.brightness, alpha: hsba.alpha)
    }
    
    /// Pick two colors such that all three are equidistant on the color wheel
    var triadic: (secondary: UIColor, tertiary: UIColor)? {
        return analogousColorsWith(stepAngle: 120.0, pairCount: 1)?.first
    }
    
    /// Returns n pairs of colors, stepping in increasing steps from this color around the color wheel
    ///
    /// - Parameters:
    ///   - stepAngle: The angle of separation of hue
    ///   - pairs: The number of pairs to return
    /// - Returns: An array of color pairs
    private func analogousColorsWith(stepAngle: CGFloat, pairCount pairs: Int) -> [(secondary: UIColor, tertiary: UIColor)]? {
        
        guard let hsba = hsbaComponents else { return nil }
        
        var angle = stepAngle
        if angle < 0.0 {
            angle *= -1.0
        }
        
        var colors: [(secondary: UIColor, tertiary: UIColor)] = []
        
        for i in 0..<pairs {
            
            let alpha = CGFloat(fmodf(Float(angle) * Float(i), 360.0))
            
            let h1 = CGFloat(fmodf(Float(hsba.hue + hsba.alpha), 360.0))
            let h2 = CGFloat(fmodf(Float(hsba.hue + 360.0 - hsba.alpha), 360.0))
            
            colors.append((
                UIColor(hue: h1, saturation: hsba.saturation, brightness: hsba.brightness, alpha: alpha),
                UIColor(hue: h2, saturation: hsba.saturation, brightness: hsba.brightness, alpha: alpha)
            ))
        }
        
        return colors
    }
    
    /// The hexidecimal string from the color
    public var hexString: String? {
        guard let rgbHex = rgbHex else { return nil }
        return String(format: "#%06x", rgbHex)
    }
}

extension UIColor {
    
    public static func * (lhs: UIColor, rhs: UIColor) -> UIColor {
        guard let rhsRGBA = lhs.rgbaComponents else { return lhs }
        return lhs.multipliedByRed(rhsRGBA.red, green: rhsRGBA.green, blue: rhsRGBA.blue, alpha: rhsRGBA.alpha) ?? lhs
    }
    
    public static func + (lhs: UIColor, rhs: UIColor) -> UIColor {
        guard let rhsRGBA = lhs.rgbaComponents else { return lhs }
        return lhs.addingRed(rhsRGBA.red, green: rhsRGBA.green, blue: rhsRGBA.blue, alpha: rhsRGBA.alpha) ?? lhs
    }
}
