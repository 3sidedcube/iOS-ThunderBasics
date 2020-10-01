//
//  UIView+AutoLayout.swift
//  ThunderBasics
//
//  Created by Simon Mitchell on 05/02/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import UIKit

public extension UIView {
	
	@discardableResult
	func fromNib<T : UIView>() -> T? {
		guard let view = Bundle.main.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)?[0] as? T else {    // 3
			// xib not loaded, or it's top view is of the wrong type
			return nil
		}
		addSubview(view)
		view.attachEdges(to: self)
		return view
	}
	
    /// Attached the view's edges to the view passed in using layout constraints.
    ///
    /// - Parameters:
    ///   - edges: The edges to add constraints for.
    ///   - parentView: The view to attach the edges to.
    ///
    /// - Warning: the `UIView` this is called on, must be a subclass of parentView
    func attachEdges(_ edges: [NSLayoutConstraint.Attribute] = [.left, .right, .top, .bottom], to parentView:UIView)
	{
		translatesAutoresizingMaskIntoConstraints = false
		
		let constraints: [NSLayoutConstraint] = edges.map({
			return NSLayoutConstraint(item: parentView, attribute: $0, relatedBy: .equal, toItem: self, attribute: $0, multiplier: 1.0, constant: 0)
		})
		
		parentView.addConstraints(constraints)
	}
}
