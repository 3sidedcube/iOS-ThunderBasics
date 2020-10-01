//
//  ToastView.swift
//  ThunderBasics
//
//  Created by Simon Mitchell on 02/11/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import UIKit

/// A closure for when a toast view is tapped
public typealias ToastActionHandler = (_ toastView: ToastView) -> Void

/// A visual representation of a `Toast` that will be displayed to the user from the top of their screen
public class ToastView: UIView {
    
    /// Defines where the toast should appear on-screen
    public enum ScreenPosition {
        case top
        case bottom
        
        func insetFor(safeAreaInsets: UIEdgeInsets) -> CGFloat {
            switch self {
            case .top:
                return safeAreaInsets.top
            case .bottom:
                return safeAreaInsets.bottom
            }
        }
    }
    
    /// Where the toast should appear on-screen
    public var screenPosition: ScreenPosition = .top
    
    /// The action to be called if the user taps the toast
    var action: ToastActionHandler?
    
    /// The colour of the text in the notification view
    @objc public dynamic var textColour: UIColor = .black {
        didSet {
            titleLabel.textColor = textColour
            messageLabel.textColor = textColour
        }
    }
    
    /// The visible duration of the toast view
    @objc public dynamic var visibleDuration: CGFloat = 2.0
    
    /// The margins to apply around the toast view if safe area insets are zero. If top or bottom (dependent on position) are > 1
    /// the view will be inset also by the safe area insets of the window and in this case `safeAreaMargin` will override this value (Assuming safe area insets are non-zero). This allows users to change margins dependent on if the user is on a notched or non-notched device.
    @objc public dynamic var margins: UIEdgeInsets = .zero
    
    /// The margins to apply around the toast view if safe area insets are non-zero
    @objc public dynamic var safeAreaMargin: CGFloat = 0
    
    private let titleLabel = UILabel()
    
    private let messageLabel = UILabel()
    
    private let imageView = UIImageView()
    
    /// The padding to apply to the inside of the toast view. The safe area insets of the window will be added to this if `margins.top` or `margins.bottom` are zero, but this can be disabled by setting `safeAreaInset`.
    @objc public dynamic var insets: UIEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    
    /// The padding to apply to the relevant side of the toast view if safe area insets are non-zero.
    @objc public dynamic var safeAreaInset: CGFloat = 0

    /// Creates a toast view with a title, message and image
    ///
    /// - Parameters:
    ///   - title: The title text to display on the toast
    ///   - message: The message text to display on the toast
    ///   - image: The image to display on the left hand side of the toast
    ///   - action: The action to be called if the user taps the toast
    public init(title: String?, message: String?, image: UIImage? = nil, action: ToastActionHandler? = nil) {
        
        super.init(frame: .zero)
        
        if #available(iOS 11.0, *) {
            titleLabel.font = UIFont.dynamicSystemFont(ofSize: 18, withTextStyle: .headline, weight: .bold)
        } else {
            titleLabel.font = UIFont.preferredFont(forTextStyle: .headline, scaledBy: 18.0/17.0).withWeight(.bold)
        }
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.text = title
        titleLabel.textColor = textColour
        
        if #available(iOS 11.0, *) {
            messageLabel.font = UIFont.dynamicSystemFont(ofSize: 16, withTextStyle: .subheadline)
        } else {
            messageLabel.font = UIFont.preferredFont(forTextStyle: .subheadline, scaledBy: 16.0/16.0)
        }
        messageLabel.numberOfLines = 0
        messageLabel.lineBreakMode = .byWordWrapping
        messageLabel.text = message
        messageLabel.textColor = textColour
        
        imageView.image = image
        
        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(messageLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private var coverWindow: UIWindow?
    
    private var animator: UIDynamicAnimator?
    
    private var gravity: UIGravityBehavior?
    
    private var completion: (() -> Void)?
    
    /// Shows the toast notification on the screen
    ///
    /// - Parameter completion: A completion block to be called when the toast notification has displayed and dismissed successfully
    internal func show(completion: @escaping () -> Void) {
        
        frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44)
                
        let containerView = UIView(frame: .zero)
        
        coverWindow = UIWindow(frame: .zero)
        coverWindow?.isHidden = false
        coverWindow?.windowLevel = UIWindow.Level.statusBar + 1
        
        let toastViewController = ToastViewController()
        toastViewController.statusBarStyle = window?.visibleViewController?.preferredStatusBarStyle ?? .default
        
        coverWindow?.rootViewController = toastViewController
        coverWindow?.rootViewController?.view.addSubview(containerView)
        containerView.addSubview(self)
        
        layout()
        
        // For some reason margins is only available at this point!
        var safeAreaInsets: UIEdgeInsets = .zero
        if #available(iOS 11.0, *) {
            safeAreaInsets = UIApplication.shared.keyWindow?.rootViewController?.view.safeAreaInsets ?? .zero
            // If safe area insets only apply to `.top` we can ignore them as we're not on a notched device and the
            // toast already displays ABOVE the status bar so we don't need to worry about that, unless we have non-zero top margin
            if margins.top <= 0 && safeAreaInsets.bottom == 0 && safeAreaInsets.left == 0 && safeAreaInsets.right == 0 {
                safeAreaInsets = .zero
            }
        }
                
        let safeArea = screenPosition.insetFor(safeAreaInsets: safeAreaInsets)
        
        // We add the opposite side's margin because the side that relates to the screenposition is added on later based on `margins`
        var marginV: CGFloat = 0.0
        if safeArea > 0 {
            switch screenPosition {
            case .top:
                marginV = safeAreaMargin + margins.bottom
            case .bottom:
                marginV = safeAreaMargin + margins.top
            }
        } else {
            marginV = margins.top + margins.bottom
        }
        
        var containerHeight = bounds.height + marginV
        
        switch screenPosition {
        case .top:
            if margins.top > 0 {
                containerHeight += safeArea
            }
        case .bottom:
            if margins.bottom > 0 {
                containerHeight += safeArea
            }
        }

        containerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: containerHeight)
        let coverFrame = CGRect(
            x: 0,
            y: screenPosition == .top ? 0 : UIScreen.main.bounds.height - containerHeight,
            width:  UIScreen.main.bounds.width,
            height: containerHeight
        )
        coverWindow?.frame = coverFrame
        
        frame = frame.offsetBy(dx: 0, dy: screenPosition == .top ? -coverFrame.height : (coverFrame.height - margins.top))

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        coverWindow?.addGestureRecognizer(tapGesture)
        
        animator = UIDynamicAnimator(referenceView: containerView)
        
        let _gravity = UIGravityBehavior(items: [self])
        gravity = _gravity
        _gravity.gravityDirection = CGVector(dx: 0.0, dy: screenPosition == .top ? 1.0 : -1.0)
        animator?.addBehavior(_gravity)
        
        let elasticBehaviour = UIDynamicItemBehavior(items: [self])
        elasticBehaviour.elasticity = 0.3
        animator?.addBehavior(elasticBehaviour)
        
        let collisionBehaviour = UICollisionBehavior(items: [self])
        let collisionInsets =  UIEdgeInsets(
            top: screenPosition == .top ? -(coverFrame.height + 10) : margins.top,
            left: -10,
            bottom: screenPosition == .top ? margins.bottom : (coverFrame.height + 10),
            right: -10
        )
        collisionBehaviour.translatesReferenceBoundsIntoBoundary = true

        collisionBehaviour.setTranslatesReferenceBoundsIntoBoundary(with: collisionInsets)
        animator?.addBehavior(collisionBehaviour)
        
        self.completion = completion
        
        let dismissTime = DispatchTime.now() + Double(visibleDuration) + 0.7
        DispatchQueue.main.asyncAfter(deadline: dismissTime) { [weak self] in
            guard let self = self else { return }
            self.dismiss()
        }
    }
    
    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
        action?(self)
    }
    
    /// The size that the image provided to the toast view will be rendered at. Defaults to 38x38pts.
    public var imageSize: CGSize = CGSize(width: 38, height: 38)
    
    /// The amount of padding to add to the right of the image view when provided. Defaults to 12pts.
    public var imageViewRightMargin: CGFloat = 12.0
    
    private func layout() {
        
        var safeAreaInsets: UIEdgeInsets = .zero
        if #available(iOS 11.0, *) {
            safeAreaInsets = UIApplication.shared.keyWindow?.rootViewController?.view.safeAreaInsets ?? .zero
            // If safe area insets only apply to `.top` we can ignore them as we're not on a notched device and the
            // toast already displays ABOVE the status bar so we don't need to worry about that, unless we have non-zero top margin
            if margins.top <= 0 && safeAreaInsets.bottom == 0 && safeAreaInsets.left == 0 && safeAreaInsets.right == 0 {
                safeAreaInsets = .zero
            }
        }
        
        // Need to inset at top if margin == 0 so we cover the safe area on-screen
        var topInset = insets.top
        if screenPosition == .top, margins.top <= 0 {
            // Override insets.top in this case so we don't end up with more padding than the user wants!
            topInset = safeAreaInsets.top > 0 ? safeAreaInset : topInset
            topInset += safeAreaInsets.top
        }
        
        var labelContainerFrame = CGRect(
            x: insets.left,
            y: topInset,
            width: frame.width - (insets.left + safeAreaInsets.left + margins.left) - (insets.right + safeAreaInsets.right + margins.right),
            height: .greatestFiniteMagnitude
        )
        
        // If we have an image adjust how much room we have for the labels.
        if imageView.image != nil {
            imageView.frame = CGRect(x: insets.left + safeAreaInsets.left + margins.left, y: 0, width: imageSize.width, height: imageSize.height)
            labelContainerFrame.origin.x += imageViewRightMargin + imageSize.width
            labelContainerFrame.size.width -= imageViewRightMargin + imageSize.width
        }
        
        let titleSize = titleLabel.sizeThatFits(labelContainerFrame.size)
        titleLabel.frame = CGRect(origin: labelContainerFrame.origin, size: titleSize)
        
        let messageSize = messageLabel.sizeThatFits(labelContainerFrame.size)
        messageLabel.frame = CGRect(origin: labelContainerFrame.offsetBy(dx: 0, dy: titleLabel.frame.height).origin, size: messageSize)
        
        // If we're flush with the bottom, on a device with bottom safe area insets and the toast is at the bottom of the screen override
        // insets.bottom with safeAreaInset
        let bottomInset = (margins.bottom <= 0 && safeAreaInsets.bottom > 0 && screenPosition == .bottom) ? safeAreaInset : insets.bottom
        // Minimum height of 44pts
        var height = max(messageLabel.frame.maxY + bottomInset, 44)
        switch screenPosition {
        case .top:
            break
        default:
            if margins.bottom <= 0 {
                height += safeAreaInsets.bottom
            }
        }
        frame = CGRect(x: margins.left, y: margins.top, width: frame.width - (margins.left + margins.right), height: height)
        imageView.center.y = frame.height/2
    }
    
    private func dismiss() {
        
        if let gravity = gravity {
            animator?.removeBehavior(gravity)
        }
        animator?.removeAllBehaviors()
        
        let gravityBehaviour = UIGravityBehavior(items: [self])
        gravityBehaviour.gravityDirection = CGVector(dx: 0, dy: screenPosition == .top ? -2.4 : 2.4)
        animator?.addBehavior(gravityBehaviour)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { [weak self] in
            guard let self = self else { return }
            self.cleanUp()
        }
    }
    
    private func cleanUp() {
        
        coverWindow?.isHidden = true
        removeFromSuperview()
        completion?()
    }
}
