//
//  TSCLoadingButton.swift
//  ThunderBasics
//
//  Created by Simon Mitchell on 14/01/2016.
//  Copyright © 2016 threesidedcube. All rights reserved.
//

#if canImport(UIKit)
import UIKit

/**
 An extension on UIButton which allows replacing the title of the button with a loading indicator
 */
extension UIButton {
    
    override open var frame: CGRect {
        
        didSet {
            
            if let activityView = viewWithTag(456766999) as? UIActivityIndicatorView {
                activityView.center = CGPoint(x: frame.size.width/2,y: frame.size.height/2)
            }
        }
    }
    
    /**
     Replaces the title of a button with a loading indicator of a certain colour
     - Parameters:
        - colour: The colour to tint the loading indicator
     */
	public func startLoading(colour: UIColor?, style: UIActivityIndicatorView.Style = UIActivityIndicatorView.Style.white) {
        
        if let activityView = viewWithTag(456766999) as? UIActivityIndicatorView {
            
            activityView.tintColor = colour
            return
        }
    
        let activityIndicator = UIActivityIndicatorView(style: style)
        
        activityIndicator.tag = 456766999
        if let activityColour = colour {
            activityIndicator.tintColor = activityColour
        }
        
        activityIndicator.alpha = 0.0
        
        UIView.animate(withDuration: 0.3) { () -> Void in
            
            activityIndicator.alpha = 1.0
            
            self.isEnabled = false
            self.titleLabel?.alpha = 0.2
            self.imageView?.alpha = 0.2
        }
        
        activityIndicator.center = CGPoint(x: bounds.size.width/2,y: bounds.size.height/2)
        activityIndicator.startAnimating()
        
        addSubview(activityIndicator)
    }
    
    /**
     Returns the button back to it's original state, removing the loading indicator
     */
    public func finishLoading() {
        
        if let activityView = viewWithTag(456766999) as? UIActivityIndicatorView {
            
            activityView.stopAnimating()
            activityView.removeFromSuperview()
            
            isEnabled = true
            
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                
                    activityView.alpha = 0.0
                    self.titleLabel?.alpha = 1.0
                    self.imageView?.alpha = 1.0
                
                }, completion: { (completed) -> Void in
                    
                    if completed {
                        activityView.removeFromSuperview()
                    }
            })
        }
    }
}
#endif
