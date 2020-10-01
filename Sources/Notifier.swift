import Foundation

// MARK: - Protocol

/// A protocol which can be added to a class to add easier NSNotificationCenter capabilities
public protocol Notifier {
    associatedtype Notification: RawRepresentable
}

public extension Notifier where Notification.RawValue == String {
    
    // MARK: - Static Computed Variables
    private static func name(for notification: Notification) -> String {
        return "\(self).\(notification.rawValue)"
    }
    
    
    // MARK: - Instance Methods
    
    /// Posts a notification to NSNotificationCenter
    ///
    /// - Parameters:
    ///   - notification: The notification to post
    ///   - object: The object posting the notification
    func postNotification(notification: Notification, object: Any? = nil) {
        Self.postNotification(notification: notification, object: object)
    }
    
    /// Posts a notification to NSNotificationCenter with a set sender and userInfo object
    ///
    /// - Parameters:
    ///   - notification: The notification to post
    ///   - object: The object posting the notification.
    ///   - userInfo: Information about the the notification. May be nil.
    func postNotification(notification: Notification, object: Any? = nil, userInfo: [AnyHashable : Any]? = nil) {
        
        Self.postNotification(notification: notification, object: object, userInfo: userInfo)
    }
    
    
    // MARK: - Static Function
    
    /// Posts a notification to NSNotificationCenter with a set sender and userInfo object
    ///
    /// - Parameters:
    ///   - notification: The notification to post
    ///   - object: The object posting the notification.
    ///   - userInfo: Information about the the notification. May be nil.
    static func postNotification(notification: Notification, object: Any? = nil, userInfo: [AnyHashable : Any]? = nil) {
        let notificationName = name(for: notification)
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: notificationName), object: object, userInfo: userInfo)
    }
    
    
    /// Adds an observer for a particular notification type
    ///
    /// - Parameters:
    ///   - observer: The object whose notifications the observer wants to receive; that is, only notifications sent by this sender are delivered to the observer.
    ///   - selector: A selector which will be called when the notification is triggered
    ///   - notification: The notification for which to register the observer
    static func addObserver(observer: AnyObject, selector: Selector, notification: Notification) {
        let notificationName = name(for: notification)
        
        NotificationCenter.default.addObserver(observer, selector: selector, name: NSNotification.Name(rawValue: notificationName), object: nil)
    }
    
   
    /// Removes an observer for a particular notification type
    ///
    /// - Parameters:
    ///   - observer: The object whose notifications the observer wants to stop receiving.
    ///   - notification: The notification type to stop receiving notifications for
    ///   - object: Sender to remove from the dispatch table. Specify a notification sender to remove only entries that specify this sender.
    static func removeObserver(observer: AnyObject, notification: Notification, object: AnyObject? = nil) {
        let notificationName = name(for: notification)
        
        NotificationCenter.default.removeObserver(observer, name: NSNotification.Name(rawValue: notificationName), object: object)
    }
}
