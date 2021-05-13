//
//  MultipleShadowView.swift
//  ShadowView
//
//  Created by Simon Mitchell on 23/07/2020.
//  Copyright © 2020 3 Sided Cube. All rights reserved.
//

import UIKit


protocol CornerObservableLayerDelegate: AnyObject {
    
    func cornerObservableLayer(_ layer: CornerObservableLayer, didUpdateCornerRadius cornerRadius: CGFloat)
    
    func cornerObservableLayer(_ layer: CornerObservableLayer, didUpdateCornerCurve cornerCurve: CALayerCornerCurve)
}

internal class CornerObservableLayer: CALayer {
    
    /// Delegate for corner property changes
    weak var cornerDelegate: CornerObservableLayerDelegate?
    
    override var cornerRadius: CGFloat {
        didSet {
            cornerDelegate?.cornerObservableLayer(self, didUpdateCornerRadius: cornerRadius)
        }
    }
    
    override var cornerCurve: CALayerCornerCurve {
        didSet {
            cornerDelegate?.cornerObservableLayer(self, didUpdateCornerCurve: cornerCurve)
        }
    }
}

/// A subclass of `UIView` which ensures multiple shadows have their
/// bounds, and corner radius properties updated when the parent view's properties
/// change.
public class MultipleShadowView: UIView {
    
    public override class var layerClass: AnyClass {
        return CornerObservableLayer.self
    }
    
    public override var backgroundColor: UIColor? {
        didSet {
            forEachShadowLayer { (shadowLayer) in
                shadowLayer.backgroundColor = layer.backgroundColor
            }
        }
    }
    
    /// Whether the shadow layers should update their corner radius to match the view's
    /// layer's corner radius
    public var matchShadowCornerRadius: Bool = true {
        didSet {
            guard matchShadowCornerRadius else { return }
            forEachShadowLayer { (shadowLayer) in
                shadowLayer.cornerRadius = layer.cornerRadius
            }
        }
    }
    
    /// Whether the shadow layers should update their corner curve to match the view's
    /// layer's corner curve
    public var matchShadowCornerCurve: Bool = true {
        didSet {
            guard matchShadowCornerCurve else { return }
            if #available(iOS 13.0, *) {
                forEachShadowLayer { (shadowLayer) in
                    shadowLayer.cornerCurve = layer.cornerCurve
                }
            }
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        (layer as? CornerObservableLayer)?.cornerDelegate = self
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        (layer as? CornerObservableLayer)?.cornerDelegate = self
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        forEachShadowLayer { (shadowLayer) in
            shadowLayer.frame = bounds
        }
    }
}

extension MultipleShadowView: CornerObservableLayerDelegate {
    
    func cornerObservableLayer(_ layer: CornerObservableLayer, didUpdateCornerRadius cornerRadius: CGFloat) {
        guard matchShadowCornerRadius else { return }
        forEachShadowLayer { (shadowLayer) in
            shadowLayer.cornerRadius = cornerRadius
        }
    }
    
    func cornerObservableLayer(_ layer: CornerObservableLayer, didUpdateCornerCurve cornerCurve: CALayerCornerCurve) {
        guard matchShadowCornerCurve else { return }
        if #available(iOS 13.0, *) {
            forEachShadowLayer { (shadowLayer) in
                shadowLayer.cornerCurve = layer.cornerCurve
            }
        }
    }
}
