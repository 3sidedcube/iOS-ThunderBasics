//
//  AccessibleButton.swift
//  ThunderBasics-iOS
//
//  Created by Simon Mitchell on 05/09/2019.
//  Copyright © 2019 threesidedcube. All rights reserved.
//

#if canImport(UIKit)
import UIKit

/// A subclass of `TSCButton` which enables automatic font adjustments, and allows for multi-line text
open class AccessibleButton: TSCButton {
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        titleLabel?.numberOfLines = 0
        titleLabel?.lineBreakMode = .byWordWrapping
        titleLabel?.adjustsFontForContentSizeCategory = true
        titleLabel?.textAlignment = .center
    }
    
    override open var intrinsicContentSize: CGSize {
        
        guard let titleLabel = titleLabel else {
            return super.intrinsicContentSize
        }
        
        let intrinsicSize = titleLabel.intrinsicContentSize
        
        return CGSize(width: intrinsicSize.width, height: intrinsicSize.height + titleEdgeInsets.top + titleEdgeInsets.bottom)
    }
    
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        
        guard let titleLabel = titleLabel else {
            return super.sizeThatFits(size)
        }
        
        let contentWidth = bounds.width - contentEdgeInsets.left - contentEdgeInsets.right
        let imageWidth = imageView?.bounds.width ?? 0 + imageEdgeInsets.left + imageEdgeInsets.right
        let titleMaxWidth = contentWidth - imageWidth - titleEdgeInsets.left - titleEdgeInsets.right
        
        let titleSize = titleLabel.sizeThatFits(CGSize(width: titleMaxWidth, height: size.height))
        
        return CGSize(width: titleSize.width, height: titleSize.height + titleEdgeInsets.top + titleEdgeInsets.bottom)
    }
    
    override open func layoutSubviews() {
        let contentWidth = bounds.width - contentEdgeInsets.left - contentEdgeInsets.right
        let imageWidth = imageView?.bounds.width ?? 0 + imageEdgeInsets.left + imageEdgeInsets.right
        let titleMaxWidth = contentWidth - imageWidth - titleEdgeInsets.left - titleEdgeInsets.right
        
        titleLabel?.preferredMaxLayoutWidth = titleMaxWidth
        super.layoutSubviews()
    }
}
#endif
