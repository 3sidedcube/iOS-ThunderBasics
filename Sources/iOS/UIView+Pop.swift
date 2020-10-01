//
//  UIView+Pop.swift
//  ThunderBasics
//
//  Created by Simon Mitchell on 05/11/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import UIKit

extension UIView {
    
    /// Pops a view inwards, the view will contract inwards then expand back to its original size
    public func popIn() {
        
        let animation = CAKeyframeAnimation(keyPath: "transform")
        let transform1 = CATransform3DMakeScale(0.1, 0.1, 1)
        let transform2 = CATransform3DMakeScale(1.1, 1.1, 1)
        let transform3 = CATransform3DMakeScale(0.95, 0.95, 1)
        let transform4 = CATransform3DMakeScale(1.0, 1.0, 1)
        
        animation.values = [
            transform1, transform2, transform3, transform4
        ]
        
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        animation.duration = 0.9
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        
        layer.add(animation, forKey: nil)
    }
    
    /// Pops a view outwards, the view will expand outwards then contract back to it's original size
    public func popOut() {
        
        let animation = CAKeyframeAnimation(keyPath: "transform")
        let transform1 = CATransform3DMakeScale(1.0, 1.0, 1)
        let transform2 = CATransform3DMakeScale(0.01, 0.01, 1)
        animation.values = [
            transform1, transform2
        ]
        
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        animation.duration = 0.2
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        
        layer.add(animation, forKey: nil)
    }
}
