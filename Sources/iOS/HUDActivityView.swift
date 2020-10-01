//
//  HUDActivityView.swift
//  ThunderBasics
//
//  Created by Simon Mitchell on 01/11/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import UIKit

public extension BinaryInteger {
    var degreesToRadians: CGFloat { return CGFloat(Int(self)) * .pi / 180 }
}

public extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}

/// A view which show an activity indicator and an (Optional) descriptive string below it in a HUD display
public class HUDActivityView: UIView {

    /// The style of the HUD
    ///
    /// - `default`: Displays a light activity indicator in a dark translucent view with text beneath
    /// - logo: Displays the logo with text below it
    /// - minimal: Displays a dark activity indicator and black text below it
    public enum Style {
        case `default`
        case logo
        case minimal
    }
    
    private var activityIndicator: UIActivityIndicatorView?
    
    fileprivate var identifier: String
    
    private var logoView: UIImageView?
    
    private let textLabel: UILabel = UILabel()
    
    private let backgroundView: UIView?

    /// Creates a new instance with a particular style and identifier
    ///
    /// - Parameters:
    ///   - style: The style of the loading HUD
    ///   - identifier: The identifier of the HUD
    ///   - text: The text to display on the HUD
    private init(style: Style, identifier: String, text: String?) {
        
        self.identifier = identifier
        
        if style != .minimal {
            backgroundView = UIView(frame: .zero)
        } else {
            backgroundView = nil
        }
        
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        
        if style != .minimal {
            backgroundView?.backgroundColor = .black
            backgroundView?.alpha = 0.7
            backgroundView?.layer.cornerRadius = 8
            if let bgView = backgroundView {
                addSubview(bgView)
            }
        }
        
        if style != .logo {
            
            activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
            addSubview(activityIndicator!)
            activityIndicator?.startAnimating()
        }

        textLabel.textAlignment = .center
        textLabel.adjustsFontSizeToFitWidth = false
        textLabel.numberOfLines = 0
        textLabel.lineBreakMode = .byWordWrapping
        textLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        textLabel.textColor = .white
        textLabel.text = text
        textLabel.adjustsFontForContentSizeCategory = true
        
        addSubview(textLabel)
        
        switch style {
        case .logo:
            logoView = UIImageView(image: UIImage(named: "MDCLoadingLogo", in: Bundle(for: type(of: self)), compatibleWith: nil))
            addSubview(logoView!)
        case .minimal:
            activityIndicator?.color = .black
            textLabel.textColor = .black
        default:
            break
        }
    }
    
    /// These margins will be used to make sure the activity indicator doesn't come within this distance of the edge of the view
    public var margins: UIEdgeInsets = UIEdgeInsets(top: 32, left: 32, bottom: 32, right: 32)
    
    /// The padding between the hud container and it's subviews
    public var padding: UIEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    
    private static let activityLabelVerticalPadding: CGFloat = 12.0
    
    public override var isAccessibilityElement: Bool {
        get {
            return true
        }
        set {  }
    }
    
    public override var accessibilityTraits: UIAccessibilityTraits {
        get {
            return activityIndicator?.accessibilityTraits ?? []
        }
        set { }
    }
    
    public override var accessibilityLabel: String? {
        get {
            return [activityIndicator?.accessibilityLabel, textLabel.text].compactMap({ $0 }).joined(separator: ". ")
        }
        set { }
    }
    
    public override var accessibilityValue: String? {
        get {
            return activityIndicator?.accessibilityValue
        }
        set { }
    }
    
    required init?(coder aDecoder: NSCoder) {
        identifier = ""
        backgroundView = nil
        super.init(coder: aDecoder)
    }
    
    override public func layoutSubviews() {
        
        super.layoutSubviews()
        
        backgroundView?.frame = bounds
        
        activityIndicator?.frame = CGRect(
            x: frame.width/2,
            y: frame.height/2,
            width: 30,
            height: 30
        )
        
        logoView?.frame = CGRect(
            x: frame.width/2,
            y: frame.height/2,
            width: 40,
            height: 40
        )
        
        if textLabel.text != nil {
            activityIndicator?.frame = (activityIndicator?.frame ?? .zero).offsetBy(dx: 0, dy: -7)
            logoView?.frame = (logoView?.frame ?? .zero).offsetBy(dx: 0, dy: -7)
        }
        
        let textLabelSize = textLabel.sizeThatFits(CGSize(width: frame.width - padding.left - padding.right, height: .greatestFiniteMagnitude))
        textLabel.frame = CGRect(x: padding.left, y: frame.height - textLabelSize.height - padding.bottom, width: frame.width - padding.left - padding.right, height: textLabelSize.height)
        
        activityIndicator?.center = CGPoint(x: frame.width/2, y: textLabel.frame.minY/2)
        logoView?.center = CGPoint(x: frame.width/2, y: textLabel.frame.minY/2)
    }
    
    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        
        var totalSize = activityIndicator?.frame.size ?? logoView?.frame.size ?? .zero
        totalSize.width += padding.left + padding.right
        totalSize.height += padding.top + padding.bottom
        
        if textLabel.text != nil {
            let textLabelSize = textLabel.sizeThatFits(CGSize(width: size.width - padding.left - padding.right, height: .greatestFiniteMagnitude))
            totalSize = CGSize(
                width: max(textLabelSize.width + padding.left + padding.right, totalSize.width) ,
                height: totalSize.height + textLabelSize.height + HUDActivityView.activityLabelVerticalPadding + padding.top + padding.bottom
            )
        }
        
        return CGSize(width: min(size.width, max(100, totalSize.width)), height: min(size.height, max(100, totalSize.height)))
    }
    
    //MARK: - Animations
    
    private func wobbleLogo() {
        
        let animation = CAKeyframeAnimation(keyPath: "transform")
        
        let rotation1 = CATransform3DMakeRotation(0, 0, 0, 1)
        let rotation2 = CATransform3DMakeRotation(135.degreesToRadians, 0, 0, 1)
        let rotation3 = CATransform3DMakeRotation(115.degreesToRadians, 0, 0, 1)
        let rotation4 = CATransform3DMakeRotation(120.degreesToRadians, 0, 0, 1)
        
        animation.values = [
            rotation1,
            rotation2,
            rotation3,
            rotation4
        ]
        
        animation.duration = 1.0
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        
        logoView?.layer.add(animation, forKey: "wiggle")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            self.wobbleLogo()
        }
    }
    
    //MARK: - Starting
    
    /// Shows the activity HUD in the centre of the provided view
    ///
    /// - Parameter view: The view to show the HUD in
    private func show(in view: UIView?) {
        
        guard let view = view else { return }
        
        view.addSubview(self)
        
        let size = sizeThatFits(CGSize(width: view.frame.width - margins.left - margins.right, height: view.frame.width - margins.top - margins.bottom))
        var viewFrame = CGRect()
        viewFrame.size = size
        viewFrame.origin = CGPoint(x: (view.bounds.width/2) - (size.width/2), y: (view.bounds.height/2) - (size.height/2))
        frame = viewFrame
        
        // Pop
        let animation = CAKeyframeAnimation(keyPath: "transform")
        let scale1 = CATransform3DMakeScale(0.1, 0.1, 1.0)
        let scale2 = CATransform3DMakeScale(1.2, 1.2, 1.0)
        let scale3 = CATransform3DMakeScale(0.9, 0.9, 1.0)
        let scale4 = CATransform3DMakeScale(1.0, 1.0, 1.0)
        
        animation.values = [scale1, scale2, scale3, scale4]
        
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        animation.duration = 0.65
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        
        layer.add(animation, forKey: "popup")
    }
    
    /// Adds an animated HUD to the centre of the view to indicate loading with a message displayed underneath the activity indicator
    ///
    /// - Parameters:
    ///   - identifier: The unique identifier that will be used to reference the activity view at a future point.
    ///   - view: The view that should present the loading HUD
    ///   - text: The text to display beneath the indicator
    ///   - style: The style of the HUD
    ///   - isModalAccessibilityView: Whether the HUD should be considered a modal accessibility view, this will be forwarded to the `accessibilityViewIsModal` property on the view, and also call `screenChanged` accessibility notification when the HUD is shown
    public class func addHUDWith(identifier: String, to view: UIView?, withText text: String? = nil, style: Style = .default, isModalAccessibilityView: Bool = true) {
        
        let activityView = HUDActivityView(style: style, identifier: identifier, text: text)
        activityView.accessibilityViewIsModal = isModalAccessibilityView
        activityView.show(in: view)
        
        if isModalAccessibilityView {
            UIAccessibility.post(notification: .screenChanged, argument: activityView)
        }
        
        guard style == .logo else {
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak activityView] in
            guard let activityView = activityView else { return }
            activityView.wobbleLogo()
        }
    }
    
    //MARK: - Removing
    
    /// Removes any loading HUD views from the specified view
    ///
    /// - Parameters:
    ///   - identifier: The identifier of the activity view we want to finish.
    ///   - view: The view which the HUD is shown in.
    ///   - completion: A closure to be called when the HUD was sucessfully dismissed, if this returns a value, then this will be sent to the `screenChanged` notification once the hud has been dismissed
    public class func removeHUDWith(identifier: String, in view: UIView?, completion: (() -> Any?)? = nil) {
        guard let hud = view?.HUDActivityViewWith(identifier: identifier) else {
            return
        }
        hud.animateOut {
            guard hud.accessibilityViewIsModal else { return }
            UIAccessibility.post(notification: .screenChanged, argument: completion?())
        }
    }
    
    private func animateOut(completion: @escaping () -> Void) {
        
        UIView.animate(withDuration: 0.35, animations: {
            self.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            self.alpha = 0.0
        }) { (_) in
            completion()
            self.removeFromSuperview()
        }
    }
    
    //MARK: - Modifying existing
    
    /// Updates the text label beneath an already running loading HUD
    ///
    /// - Parameters:
    ///   - text: The text to replace the existing text with.
    ///   - identifier: The identifier of the activity view we want to update
    ///   - view: The view which contains the loading HUD
    public class func updateText(_ text: String?, forHUDWithId identifier: String, in view: UIView?) {
    
        guard let activityView = view?.HUDActivityViewWith(identifier: identifier) else {
            return
        }
        
        switch (activityView.textLabel.text, text) {
        case (.some(_), nil):
            
            UIView.animate(
                withDuration: 0.65,
                delay: 0,
                usingSpringWithDamping: 0.5,
                initialSpringVelocity: 0.5,
                options: .curveEaseInOut,
                animations: {
                    
                    activityView.frame = (activityView.activityIndicator?.frame ?? .zero).offsetBy(dx: 0, dy: 7)
                    activityView.frame = (activityView.activityIndicator?.frame ?? .zero).offsetBy(dx: 0, dy: 7)
                    activityView.textLabel.text = text
                },
                completion: nil)
            
        case (.some(_), .some(let newText)):
            activityView.textLabel.text = newText
        case (nil, _):
            
            UIView.animate(
                withDuration: 0.65,
                delay: 0,
                usingSpringWithDamping: 0.5,
                initialSpringVelocity: 0.5,
                options: .curveEaseInOut,
                animations: {
                    
                    activityView.frame = (activityView.activityIndicator?.frame ?? .zero).offsetBy(dx: 0, dy: -7)
                    activityView.frame = (activityView.activityIndicator?.frame ?? .zero).offsetBy(dx: 0, dy: -7)
                    activityView.textLabel.text = text
            },
                completion: nil)
        }
    }
    
    /// Removes text from the activity view with a particular identifier in the view
    ///
    /// - Parameters:
    ///   - identifier: The identifier of the activity view that we want to remove the text from.
    ///   - view: The view which already contains a loading HUD.
    public class func removeTextFromHUDWith(identifier: String, in view: UIView?) {
        updateText(nil, forHUDWithId: identifier, in: view)
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        guard previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory else { return }
        guard let superView = superview else { return }
        textLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        let size = sizeThatFits(CGSize(width: superView.frame.width - margins.left - margins.right, height: superView.frame.width - margins.top - margins.bottom))
        var viewFrame = CGRect()
        viewFrame.size = size
        viewFrame.origin = CGPoint(x: (superView.bounds.width/2) - (size.width/2), y: (superView.bounds.height/2) - (size.height/2))
        frame = viewFrame
    }
}

extension UIView {
    /// Finds the first HUD activity view with an identifier
    ///
    /// - Parameter identifier: The identifier of the HUD activity view
    /// - Returns: The first HUD Activity view that is found
    func HUDActivityViewWith(identifier: String) -> HUDActivityView? {
        return subviews.compactMap({ $0 as? HUDActivityView }).first(where: { $0.identifier == identifier })
    }
}
