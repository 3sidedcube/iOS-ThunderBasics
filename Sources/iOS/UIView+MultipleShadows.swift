//
//  UIView+MultipleShadows.swift
//  ShadowView
//
//  Created by Simon Mitchell on 23/07/2020.
//  Copyright © 2020 3 Sided Cube. All rights reserved.
//

import UIKit

/// A simple subclass of `CALayer` so we can class-check within `MultipleShadowView`
internal class ShadowLayer: CALayer {
    
    init(
        shadowComponents: ShadowComponents,
        cornerRadius: CGFloat,
        cornerCurve: UIViewCornerCurve
    ) {
        super.init()
        shadow = shadowComponents
        self.cornerRadius = cornerRadius
        self.viewCornerCurve = cornerCurve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public extension UIView {
    
    /// Sets multiple shadows on the UIView instance, this is suitable if your corner radius or bounds are not changing.
    /// If your bounds or corner radius change, and you want your shadows to reflect these changes consider using or subclassing
    /// from `MultipleShadowView`
    /// - Parameters:
    ///   - shadows: The shadows to apply
    ///   - cornerRadius: The cornerRadius to give the shadows, if `nil` then this will be fetched from the view's own layer
    ///   - cornerCurve: The corner curve to give the shadows, if `nil` then this will be fetched from the view's own layer
    /// - Important: This doesn't work well with `UIImageView` because the added `CALayer`s used to render shadows cover the image
    /// itself. To apply a shadow to an image, we suggest wrapping it in a container view and using this method on the container
    func setShadows(
        shadows: [ShadowComponents],
        cornerRadius: CGFloat? = nil,
        cornerCurve: UIViewCornerCurve? = nil
    ) {
        removeExistingShadowLayers()
        reconstructShadowLayers(
            from: shadows,
            withCornerRadius: cornerRadius ?? layer.cornerRadius,
            cornerCurve: cornerCurve ?? layer.viewCornerCurve
        )
    }
    
    internal func forEachShadowLayer(_ body: (ShadowLayer) -> Void) {
        layer.sublayers?.compactMap({
            $0 as? ShadowLayer
        }).forEach({
            body($0)
        })
    }

    private func removeExistingShadowLayers() {
        forEachShadowLayer { $0.removeFromSuperlayer() }
    }
    
    private func reconstructShadowLayers(
        from shadows: [ShadowComponents],
        withCornerRadius cornerRadius: CGFloat,
        cornerCurve: UIViewCornerCurve
    ) {
        
        shadows.forEach { (shadow) in
            
            let shadowLayer = ShadowLayer(
                shadowComponents: shadow,
                cornerRadius: cornerRadius,
                cornerCurve: cornerCurve
            )
            // This is important because layers with no background colour cannot render shadows
            shadowLayer.backgroundColor = layer.backgroundColor
            shadowLayer.frame = bounds
            layer.insertSublayer(shadowLayer, at: 0)
        }
    }
}
