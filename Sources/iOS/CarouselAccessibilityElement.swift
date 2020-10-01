//
//  CarouselAccessibilityElement.swift
//  ThunderBasics-iOS
//
//  Created by Simon Mitchell on 23/10/2019.
//  Copyright © 2019 threesidedcube. All rights reserved.
//

import UIKit

/// A protocol which must be impelemented by users of `CarouselAccessibilityElement` which allows the provision of:
///  accessibility values, the number of items in the carousel and performs accessibility scrolling
public protocol CarouselAccessibilityElementDataSource {
    
    /// This is used by a `CarouselAcccessibilityElement` to fetch the `accessibilityValue` for the element at a given index
    /// - Parameter element: The accessibility element which is asking for an `accessibilityValue`
    /// - Parameter index: The index of the value to return
    func carouselAccessibilityElement(_ element: CarouselAccessibilityElement, accessibilityValueAt index: Int) -> String?
    
    /// This is used by a `CarouselAcccessibilityElement` to fetch the `UIAccessibilityTraits` for the element at a given index
    ///
    /// - Note: If `adjustable` is true on the `element` (It is true by default) the returned value here will have the `.adjustable` trait appended to it.
    /// - Parameter element: The accessibility element which is asking for the `UIAccessibilityTraits`
    /// - Parameter index: The index of the value to return
    func carouselAccessibilityElement(_ element: CarouselAccessibilityElement, accessibilityTraitsForItemAt index: Int) -> UIAccessibilityTraits
    
    /// This is used by a `CarouselAccessibilityElement` to fetch the number of items in the carousel to make sure we don't try and scroll too far
    /// - Parameter element: The accessibility element requesting the number of items
    func numberOfItems(in element: CarouselAccessibilityElement) -> Int
    
    /// This is used by a `CarouselAccessibilityElement` to request a scroll to the item at a given index
    /// - Parameter element: The accessibility element that requested the scroll
    /// - Parameter index: The index the accessibility element wants to scroll to
    /// - Parameter announce: Whether the scroll should be announced (Only true for `accessibilityScroll` calls)
    func carouselAccessibilityElement(_ element: CarouselAccessibilityElement, scrollToItemAt index: Int, announce: Bool)
}

/// A subclass of `UIAccessibilityElement` which simplifies all the logic that is needed to implement a carousel-like accessibility control.
/// Return an instance of this class from your container element's `accessibilityElements` to implement carousel scrolling in Voice Over.
public class CarouselAccessibilityElement: UIAccessibilityElement {
    
    /// The source for the data which this accessibility element needs to function
    public var dataSource: CarouselAccessibilityElementDataSource?
    
    /// Creates a new carousel accessibility element for the given container and dataSource
    /// - Parameter container: The container element for the accessibility element
    /// - Parameter dataSource: The data source used to perform accessibility functions
    public init(accessibilityContainer container: Any, dataSource: CarouselAccessibilityElementDataSource) {
        super.init(accessibilityContainer: container)
        self.dataSource = dataSource
    }
    
    /// The current element which is selected in the carousel
    public var currentElement: Int = 0
    
    /// Whether the adjustable behaviour should be implemented for this element.
    /// Settings this to `false` disables the auto-appending of `adjustable` to the elements traits,
    /// and disables the logic in `accessibilityIncrement` and `accessibilityDecrement`
    /// (Unless `.adjustable` is returned by the data source method `carouselAccessibilityElement(_ element: CarouselAccessibilityElement, accessibilityTraitsForItemAt index: Int)`.
    public var adjustable: Bool = true
    
    override public var accessibilityTraits: UIAccessibilityTraits {
        get {
            guard var dataSourceTraits = dataSource?.carouselAccessibilityElement(self, accessibilityTraitsForItemAt: currentElement) else {
                return adjustable ? [.adjustable, .button] : [.button]
            }
            if !dataSourceTraits.contains(.adjustable) && adjustable {
                dataSourceTraits.insert(.adjustable)
            }
            return dataSourceTraits
        }
        set {
            super.accessibilityTraits = newValue
        }
    }
    
    override public var accessibilityValue: String? {
        get {
            return dataSource?.carouselAccessibilityElement(self, accessibilityValueAt: currentElement)
        }
        set {
            super.accessibilityValue = newValue
        }
    }
    
    /**
     A convenience for forward scrolling in both `accessibilityIncrement` and `accessibilityScroll`.
     It returns a `Bool` because `accessibilityScroll` needs to know if the scroll was successful.
     - Parameter announce: Whether the scroll should be announced by voiceover
     */
    @discardableResult func accessibilityScrollForward(announce: Bool) -> Bool {

        // Initialize the container view which will house the collection view.
        guard let dataSource = dataSource else { return false }
        
        let items = dataSource.numberOfItems(in: self)
        guard currentElement < items - 1 else {
            return false
        }
        
        dataSource.carouselAccessibilityElement(self, scrollToItemAt: currentElement + 1, announce: announce)
        currentElement = currentElement + 1
        
        return true
    }
    
    /**
     A convenience for backward scrolling in both `accessibilityIncrement` and `accessibilityScroll`.
     It returns a `Bool` because `accessibilityScroll` needs to know if the scroll was successful.
     - Parameter announce: Whether the scroll should be announced by voiceover
     */
    @discardableResult func accessibilityScrollBackward(announce: Bool) -> Bool {

        // Initialize the container view which will house the collection view.
        guard let dataSource = dataSource else { return false }
        
        guard currentElement > 0 else {
            return false
        }
        
        dataSource.carouselAccessibilityElement(self, scrollToItemAt: currentElement - 1, announce: announce)
        currentElement = currentElement - 1
        
        return true
    }
    
    // MARK: Accessibility

    override public func accessibilityIncrement() {
        guard accessibilityTraits.contains(.adjustable) else { return }
        accessibilityScrollForward(announce: false)
    }
    
    override public func accessibilityDecrement() {
        guard accessibilityTraits.contains(.adjustable) else { return }
        accessibilityScrollBackward(announce: false)
    }

    override public func accessibilityScroll(_ direction: UIAccessibilityScrollDirection) -> Bool {
        if direction == .left {
            return accessibilityScrollForward(announce: true)
        } else if direction == .right {
            return accessibilityScrollBackward(announce: true)
        }
        return false
    }
}
