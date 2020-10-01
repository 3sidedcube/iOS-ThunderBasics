//
//  UIView+Frame.swift
//  ThunderBasics
//
//  Created by Simon Mitchell on 05/11/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

#if os(iOS)
public typealias View = UIView
#elseif os(macOS)
public typealias View = NSView
#endif

public typealias ViewEnumerator = (_ view: View, _ stop: inout Bool) -> Void

extension View {
    
    /// Adjust the height of the current view's frame to the given value
    ///
    /// - Parameter height: The height to adjust the view to
    public func set(height: CGFloat) {
        set(size: CGSize(width: bounds.width, height: height))
    }
    
    /// Adjusts the width of the current view's frame to the given value
    ///
    /// - Parameter width: The width to adjust the view to
    public func set(width: CGFloat) {
        set(size: CGSize(width: width, height: bounds.height))
    }
    
    /// Adjusts the views x origin to the given position
    ///
    /// - Parameter minX: The x coordinate to set the frames origin to
    public func set(minX: CGFloat) {
        set(origin: CGPoint(x: minX, y: frame.minY))
    }
    
    /// Adjusts the views y origin to the given position
    ///
    /// - Parameter minX: The y coordinate to set the frames origin to
    public func set(minY: CGFloat) {
        set(origin: CGPoint(x: frame.minX, y: minY))
    }
    
    /// Adjusts the views x center to the given position
    ///
    /// - Parameter minX: The x coordinate to set the frames center to
    public func set(centerX x: CGFloat) {
        #if os(iOS)
        center = CGPoint(x: x, y: center.y)
        #elseif os(macOS)
        set(minX: x - bounds.width/2.0)
        #endif
    }
    
    /// Adjusts the views y center to the given position
    ///
    /// - Parameter minX: The y coordinate to set the frames center to
    public func set(centerY y: CGFloat) {
        #if os(iOS)
        center = CGPoint(x: center.x, y: y)
        #elseif os(macOS)
        set(minY: y - bounds.height)
        #endif
    }
    
    /// Adjust the size of the current view's frame to the given value
    ///
    /// - Parameter size: The size to adjust the view to
    public func set(size: CGSize) {
        frame = CGRect(origin: frame.origin, size: size)
    }
    
    /// Sets the view's origin to the given point
    ///
    /// - Parameter origin: The point to set as the view's origin
    public func set(origin: CGPoint) {
        frame = CGRect(origin: origin, size: frame.size)
    }
    
    private func heightInformation(of views: [View]) -> (height: CGFloat, lowestMinY: CGFloat, heighestMaxY: CGFloat) {
        
        var highestMaxY: CGFloat = -.greatestFiniteMagnitude
        var lowestMinY: CGFloat = .greatestFiniteMagnitude
        
        subviews.forEach { (view) in
            
            if view.frame.maxY > highestMaxY {
                highestMaxY = view.frame.maxY
            }
            
            if view.frame.minY < lowestMinY {
                lowestMinY = view.frame.minY
            }
        }
        
        return (highestMaxY - lowestMinY, lowestMinY, highestMaxY)
    }
    
    /// Returns the height of the subviews by analysing the frames of the view's subviews
    public var heightOfSubviews: CGFloat {
        
        guard !subviews.isEmpty else { return 0 }
        return heightInformation(of: subviews).height
    }
    
    /// Centers all of the subviews in the view vertically, maintaining their current spacing and
    /// offsetting all views by the given value vertically whilst ignoring the provided views
    ///
    /// - Parameter excluding: Any views to be excluded from the centering process
    /// - Parameter offset: The y offset from the center of the view
    public func centerSubviewsVertically(excluding: [View] = [], offsetingBy offset: CGFloat = 0.0) {
        
        guard !subviews.isEmpty else { return }
        
        let allowedViews = subviews.filter({ !excluding.contains($0) })
        guard !allowedViews.isEmpty else { return }
        
        let heightInfo = heightInformation(of: allowedViews)
        let height = heightInfo.height
        let yOffset = (bounds.height - height - offset)/2 - heightInfo.lowestMinY
        
        allowedViews.forEach({
            $0.set(minY: $0.frame.minY + yOffset)
        })
    }
    
    /// Enumerates the subviews of this view, and every subview of every subview recursively until told to stop.
    ///
    /// - Parameter handler: Closure which each enumerated view will be passed to and given a chance to stop the enumeration
    public func enumerateSubviews(_ handler: @escaping ViewEnumerator) {
        enumerateSubviewsOf(self, using: handler)
    }
    
    private func enumerateSubviewsOf(_ view: View, using handler: @escaping ViewEnumerator) {
        
        for subview in view.subviews { // I wrote this (Me, Simon)... Don't even ask me how it works! :D (Let's just pretend I know).
            
            var stop: Bool = false
            let block = handler
            handler(subview, &stop)
            
            guard !stop else {
                return
            }
            
            enumerateSubviewsOf(subview) { (view, shouldContinue) in
                block(view, &stop)
                shouldContinue = stop
            }
            
            if stop {
                return
            }
        }
    }
}
