//
//  ToastNotificationController.swift
//  ThunderBasics
//
//  Created by Simon Mitchell on 02/11/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import UIKit

/// The controller responsible for displaying toast notifications at the top of the screen.
///
/// This class has a shared instance that can be used to queue and display as many notification toasts as required.
///
/// The class is particularly useful for showing remote or local alerts passed to the app whilst the app is open.
public final class ToastNotificationController {

    /// A shared instance of `ToastNotificationController` responsible for displaying toasts
    public static let shared = ToastNotificationController()
    
    private init() {
        
    }
    
    fileprivate(set) lazy var operationQueue: OperationQueue = {
        let opQueue = OperationQueue()
        opQueue.maxConcurrentOperationCount = 1
        return opQueue
    }()
    
    /// Displays the given toast view immediately
    ///
    /// - Parameter toastView: An instance of `ToastView` to display
    public func display(_ toastView: ToastView) {
        let toastOperation = ToastOperation(toastView: toastView)
        operationQueue.addOperation(toastOperation)
    }
    
    /// Creates and displays a toast view with a given title, message and image and action.
    ///
    /// - Parameters:
    ///   - title: The title text to display on the toast
    ///   - message: The message text to display on the toast
    ///   - image: The image to display on the left hand side of the toast
    ///   - action: A closure to call when the user taps the toast notification
    public func displayToastWith(title: String?, message: String?, image: UIImage? = nil, screenPosition: ToastView.ScreenPosition = .top, action: ToastActionHandler? = nil) {
        let toastView = ToastView(title: title, message: message, image: image, action: action)
        toastView.screenPosition = screenPosition
        display(toastView)
    }
}
