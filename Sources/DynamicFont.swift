//
//  DynamicFont.swift
//  ThunderBasics
//
//  Created by Simon Mitchell on 08/11/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

#if canImport(UIKit)
import UIKit

public extension UIFont {
    
    /// Returns the system font for a particular size scaled according to text style provided at a certain font weight
    ///
    /// - Parameters:
    ///   - size: The size of the font before scaling
    ///   - textStyle: The text style of the font (Used to determine how it scales)
    ///   - weight: The weight of the required font
    /// - Returns: A system font matching the above criteria
    @available(iOS 11.0, *)
    static func dynamicSystemFont(ofSize size: CGFloat, withTextStyle textStyle: UIFont.TextStyle, weight: UIFont.Weight = .regular) -> UIFont {
        
        let baseFont = UIFont.systemFont(ofSize: size, weight: weight)
        let fontMetrics = UIFontMetrics(forTextStyle: textStyle)
        return fontMetrics.scaledFont(for: baseFont)
    }
    
    /// Returns a dynamically scaled version of the font using the scaling of a particular font style
    ///
    /// This allows for scaling non-system fonts and customising the base font size for text styles
    ///
    /// - Parameter textStyle: The text style to use to scale the returned font
    @available(iOS 11.0, *)
    func dynamic(with textStyle: UIFont.TextStyle) -> UIFont {
        let fontMetrics = UIFontMetrics(forTextStyle: textStyle)
        return fontMetrics.scaledFont(for: self)
    }
	
	/// Creates a font for a defined text style with the font size scaled by a proportion and with given symbolic traits applied
	///
	/// - Parameters:
	///   - style: The style of font, see `UIFontTextStyle`
	///   - scale: The scale to increase the font size by (1 would result in the exact same font)
	///   - symbolicTraits: Symbolic constraints to apply to the default font
	///   - traitCollection: The trait collection the font should be for
	/// - Returns: A font converted given the above parameters
    @available (iOS, introduced: 10.0, deprecated: 11.0, obsoleted: 13.0, message: "This will be removed when iOS 13 is released; please use dynamicSystemFont(size:textStyle:weight) instead")
    class func preferredFont(forTextStyle style: UIFont.TextStyle, scaledBy scale: CGFloat, withSymbolicTraits symbolicTraits: UIFontDescriptor.SymbolicTraits? = nil, attributes: [UIFontDescriptor.AttributeName: Any]? = nil, compatibleWith traitCollection: UITraitCollection? = nil) -> UIFont {
		
		var descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style, compatibleWith: traitCollection)
		
		if let attributes = attributes {
			descriptor = descriptor.addingAttributes(attributes)
		}
		
		if let symbolicTraits = symbolicTraits {
			descriptor = descriptor.withSymbolicTraits(symbolicTraits) ?? descriptor
		}
		
		let pointSize = descriptor.pointSize * scale
		
		return UIFont(descriptor: descriptor, size: pointSize)
	}
	
	/// Adapts the font with the font family and face provided
	///
	/// This is useful if you're using dynamic font sizing with a custom font
	///
	/// - Parameters:
	///   - family: The font family to convert this font to
	///   - face: The font face to convert this font to
    @available (iOS, introduced: 10.0, deprecated: 11.0, obsoleted: 13.0, message: "This will be removed when iOS 13 is released; please use dynamic(with textStyle:) instead")
    func withFontFamily(_ family: String, face: String? = nil) -> UIFont {
		
		var traits: [UIFontDescriptor.TraitKey : Any] = [:]
		
		// Make sure we only take known keys otherwise changes to family and face will be overwritten by preferredStyle
		if let existingTraits = fontDescriptor.object(forKey: UIFontDescriptor.AttributeName.traits) as? [UIFontDescriptor.TraitKey : Any] {
			traits[UIFontDescriptor.TraitKey.weight] = existingTraits[UIFontDescriptor.TraitKey.weight]
			traits[UIFontDescriptor.TraitKey.slant] = existingTraits[UIFontDescriptor.TraitKey.slant]
			traits[UIFontDescriptor.TraitKey.width] = existingTraits[UIFontDescriptor.TraitKey.width]
		}
		
		var attributes = fontDescriptor.fontAttributes
		// Have to remove text style otherwise can't change weight
		attributes[UIFontDescriptor.AttributeName.textStyle] = nil
		// Create a new font traits dictionary
		attributes[UIFontDescriptor.AttributeName.traits] = traits
		
		var descriptor = UIFontDescriptor(name: fontName, size: pointSize).withFamily(family).addingAttributes(attributes)
		
		if let face = face {
			descriptor = descriptor.withFace(face)
		}
		
		return UIFont(descriptor: descriptor, size: descriptor.pointSize)
	}
	
	/// Adapts the font with the font family and weight provided
	///
	/// This is useful if you're using dynamic font sizing with a custom font, and should be used in place of
	/// calling `withFontFamily:face` and then `withWeight` because that combination of calls breaks your font
	///
	/// - Parameters:
	///   - family: The font family to convert this font to
	///   - weight: The font weight to convert this font to
	///
    @available (iOS, introduced: 10.0, deprecated: 11.0, obsoleted: 13.0, message: "This will be removed when iOS 13 is released; please use dynamic(with textStyle:) instead")
    func withFontFamily(_ family: String, weight: UIFont.Weight) -> UIFont {
		
		var traits: [UIFontDescriptor.TraitKey : Any] = [:]
		
		// Make sure we only take known keys otherwise changes to family and face will be overwritten by preferredStyle
		if let existingTraits = fontDescriptor.object(forKey: UIFontDescriptor.AttributeName.traits) as? [UIFontDescriptor.TraitKey : Any] {
			traits[UIFontDescriptor.TraitKey.weight] = existingTraits[UIFontDescriptor.TraitKey.weight]
			traits[UIFontDescriptor.TraitKey.slant] = existingTraits[UIFontDescriptor.TraitKey.slant]
			traits[UIFontDescriptor.TraitKey.width] = existingTraits[UIFontDescriptor.TraitKey.width]
		}
		
		traits[UIFontDescriptor.TraitKey.weight] = weight
		
		var attributes = fontDescriptor.fontAttributes
		// Have to remove text style otherwise can't change weight
		attributes[UIFontDescriptor.AttributeName.textStyle] = nil
		// Create a new font traits dictionary
		attributes[UIFontDescriptor.AttributeName.traits] = traits
		
		let descriptor = UIFontDescriptor(name: fontName, size: pointSize).withFamily(family).addingAttributes(attributes)
		return UIFont(descriptor: descriptor, size: descriptor.pointSize)
	}
	
	/// Adapts the font with the font weight provided
	///
	/// This is useful if you're using dynamic font sizing with a custom weight
	///
	/// - Parameters:
	///   - weight: The font weight to convert this font to
    func withWeight(_ weight: UIFont.Weight) -> UIFont {
		
		var traits: [UIFontDescriptor.TraitKey : Any] = [:]
		
		// Make sure we only take known keys otherwise changes to family and face will be overwritten by preferredStyle
		if let existingTraits = fontDescriptor.object(forKey: UIFontDescriptor.AttributeName.traits) as? [UIFontDescriptor.TraitKey : Any] {
			traits[UIFontDescriptor.TraitKey.weight] = existingTraits[UIFontDescriptor.TraitKey.weight]
			traits[UIFontDescriptor.TraitKey.slant] = existingTraits[UIFontDescriptor.TraitKey.slant]
			traits[UIFontDescriptor.TraitKey.width] = existingTraits[UIFontDescriptor.TraitKey.width]
		}
		
		// Set the weight
		traits[UIFontDescriptor.TraitKey.weight] = weight

		var attributes = fontDescriptor.fontAttributes
		// Have to remove text style otherwise can't change weight
		attributes[UIFontDescriptor.AttributeName.textStyle] = nil
		// Create a new font traits dictionary
		attributes[UIFontDescriptor.AttributeName.traits] = traits
		
		var descriptor = fontDescriptor
		descriptor = descriptor.addingAttributes(attributes)
		return UIFont(descriptor: descriptor, size: descriptor.pointSize)
	}
}
#endif
