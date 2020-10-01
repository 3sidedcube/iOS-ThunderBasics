//
//  UILabel+SizeToFit.swift
//  ThunderBasics
//
//  Created by Simon Mitchell on 05/11/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import UIKit

extension UILabel {
    
    /// Sizes the label to fit the given size from `sizeThatFits`
    ///
    /// - Parameter size: The size to fit the label to
    func sizeToFit(_ size: CGSize) {
        let constrainedSize = sizeThatFits(size)
        set(size: constrainedSize)
    }
}
