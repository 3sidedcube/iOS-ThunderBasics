//
//  UIColor+HexString.swift
//  ThunderBasics
//
//  Created by Simon Mitchell on 05/11/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

#if os(iOS)
import UIKit
public typealias Color = UIColor
#elseif os(macOS)
import AppKit
public typealias Color = NSColor
#endif


extension String {
    fileprivate func hexFloatAt(_ startIndex: Int, length: Int) -> CGFloat? {
        
        let beginningIndex = self.index(self.startIndex, offsetBy: startIndex)
        let endIndex = self.index(beginningIndex, offsetBy: length)
        let range: Range<String.Index> = Range(uncheckedBounds: (lower: max(self.startIndex, beginningIndex), upper: min(self.endIndex, endIndex)))
        let substring = String(self[range])
        let length = self.distance(from: range.lowerBound, to: range.upperBound)
        let hexString = length == 2 ? substring : "\(substring)\(substring)"
        let hexScanner = Scanner(string: hexString)
        var int: UInt64 = 0
        let result = hexScanner.scanHexInt64(&int)
        return result ? CGFloat(int) : nil
    }
}

extension Color {
    
    /// Allocates a UIColor from a given hex string.
    ///
    /// - Parameter hexString: The hex string to return a `UIColor` for
    public convenience init?(hexString: String) {

        let trimmedString = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        
        let alpha: CGFloat?
        let red: CGFloat?
        let blue: CGFloat?
        let green: CGFloat?

        switch trimmedString.count {
        case 3: // #RGB
            alpha = 255.0
            red = trimmedString.hexFloatAt(0, length: 1)
            green = trimmedString.hexFloatAt(1, length: 1)
            blue = trimmedString.hexFloatAt(2, length: 1)
        case 4: //#ARGB
            alpha = trimmedString.hexFloatAt(0, length: 1)
            red = trimmedString.hexFloatAt(1, length: 1)
            green = trimmedString.hexFloatAt(2, length: 1)
            blue = trimmedString.hexFloatAt(3, length: 1)
        case 6: //#RRGGBB
            alpha = 255.0
            red = trimmedString.hexFloatAt(0, length: 2)
            green = trimmedString.hexFloatAt(2, length: 2)
            blue = trimmedString.hexFloatAt(4, length: 2)
        case 8: //#AARRGGBB
            alpha = trimmedString.hexFloatAt(0, length: 2)
            red = trimmedString.hexFloatAt(2, length: 2)
            green = trimmedString.hexFloatAt(4, length: 2)
            blue = trimmedString.hexFloatAt(6, length: 2)
        default:
            return nil
        }
        
        guard let _red = red, let _green = green, let _blue = blue, let _alpha = alpha else {
            return nil
        }
        
        self.init(red: _red/255.0, green: _green/255.0, blue: _blue/255.0, alpha: _alpha/255.0)
    }
}
