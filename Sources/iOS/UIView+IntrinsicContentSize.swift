//
//  UIView+IntrinsicContentSize.swift
//  ThunderBasics-iOS
//
//  Created by Simon Mitchell on 22/08/2019.
//  Copyright © 2019 threesidedcube. All rights reserved.
//

import Foundation
import UIKit

public extension UIView {
    
    /// Returns the intrinsic content size an auto-layout based view will occupy when constrained
    /// to the given size and allowed to resize in the given axis.
    ///
    /// - Parameters:
    ///   - constrainedTo: The size the view is allowed to occupy.
    ///   - resizableAxis: The axis the view is allowed to resize in.
    /// - Returns: The size the view will occupy
    /// - Important: This will only behave nicely on views layed out using layout constraints as it essentialy adds a width or height constraint and calls `layoutSubviews()`. It must also therefore be run on the main thread!
    /// - Note: The returned size's width/height can be returned as smaller than the relative `constrainedSize` property if the content fits easily within the constrained width.
    func intrinsicContentSize(constrainedTo constrainedSize: CGSize, resizableAxis: NSLayoutConstraint.Axis = .vertical) -> CGSize {
        
        let size: CGSize
        
        // Keep track of these so we can re-set them after we're done calculating
        let translates = translatesAutoresizingMaskIntoConstraints
        translatesAutoresizingMaskIntoConstraints = false
                    
        let constrainingName = resizableAxis == .vertical ? "width" : "height"
        let cgConstraintValue = resizableAxis == .vertical ? constrainedSize.width : constrainedSize.height
        let constraintValue = NSNumber(value: Float(cgConstraintValue))
        let temporaryConstraint = NSLayoutConstraint.constraints(
            withVisualFormat: "[view(\(constrainingName))]",
            options: [],
            metrics: [constrainingName : constraintValue],
            views: ["view": self]
        )
        addConstraints(temporaryConstraint)
        
        setNeedsUpdateConstraints()
        setNeedsLayout()
        
        // Force the view to layout itself and any children
        updateConstraintsIfNeeded()
        layoutIfNeeded()
        
        let horizontalPriority: UILayoutPriority = resizableAxis == .vertical ? .fittingSizeLevel : .defaultLow
        let verticalPriority: UILayoutPriority = resizableAxis == .vertical ? .defaultLow : .fittingSizeLevel
        size = systemLayoutSizeFitting(UIView.layoutFittingCompressedSize, withHorizontalFittingPriority: horizontalPriority, verticalFittingPriority: verticalPriority)
        removeConstraints(temporaryConstraint)
        
        translatesAutoresizingMaskIntoConstraints = translates
        
        return size
    }
}
