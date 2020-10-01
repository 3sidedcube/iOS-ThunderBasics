//
//  CNContact+Helpers.swift
//  ThunderBasics-iOS
//
//  Created by Simon Mitchell on 29/09/2020.
//  Copyright © 2020 threesidedcube. All rights reserved.
//

import Contacts

#if canImport(UIKit)
import UIKit
#endif

/// `AutoUpdatingContact` is an self-updating alternative to `CNContact` which keeps all properties
/// updated by listening to address book notifications.
public class AutoUpdatingContact {
    
    weak var observer: AnyObject?
    
    /// Provides access to the underlying `CNContact` object for utilising any underlying
    /// properties that `AutoUpdatingContact` doesn't directly expose
    public var contact: CNContact {
        didSet {
            setupImages()
        }
    }
    
    /// Initialise an `AutoUpdatingContact` from a given `CNContact`
    /// - Parameter contact: The contact to initialise the person from
    init(_ contact: CNContact) {
        self.contact = contact
        observer = NotificationCenter.default.addObserver(
            forName: .CNContactStoreDidChange,
            object: nil,
            queue: .main,
            using: { [weak self] (_) in
                let contactController = ContactsController.shared
                guard let contact = contactController.contact(for: contact.identifier) else { return }
                self?.contact = contact
            }
        )
        setupImages()
    }
    
    private func setupImages() {
        #if canImport(UIKit)
        if let imageData = contact.imageData {
            largeImage = UIImage(data: imageData)
        }
        if let thumbnailData = contact.thumbnailImageData {
            photo = UIImage(data: thumbnailData)
        } else if let initials = initials {
            photo = AutoUpdatingContact.contactPlaceholder(initials: initials)
        }
        #endif
    }
    
    /// Returns the contact's first name
    ///
    /// This will be the contact's given name, and if both that and `lastName` aren't present
    /// it will instead return their nickname
    public var firstName: String? {
        // This mirrors the logic that `TSCPerson` previously employed
        let givenName = contact.givenName
        guard givenName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return givenName
        }
        guard lastName == nil else { return nil }
        let nickname = contact.nickname
        return nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : nickname
    }
    
    /// Returns the contact's last name
    ///
    /// If non-empty this returns `contact.familyName`
    public var lastName: String? {
        // This mirrors the logic that `TSCPerson` previously employed
        let familyName = contact.familyName
        return familyName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : familyName
    }
    
    /// Returns the contact's full name using `CNContactFormatter`
    public var fullName: String? {
        return CNContactFormatter.string(from: contact, style: .fullName)
    }
    
    /// Returns the contact's initials
    public var initials: String? {
        var components = [firstName, lastName].compactMap({ $0 }).filter({ !$0.isEmpty })
        if components.isEmpty, let companyName = companyName, !companyName.isEmpty {
            components = [companyName]
        }
        guard !components.isEmpty else { return nil }
        return components.joined(separator: "")
    }
    
    /// Returns the contact's company name
    ///
    /// If non-empty this returns `contact.organizationName`
    public var companyName: String? {
        // This mirrors the logic that `TSCPerson` previously employed
        let organizationName = contact.organizationName
        return organizationName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : organizationName
    }
    
    /// Returns all of the contact's email addresses as strings
    public var emailAddresses: [String] {
        return contact.emailAddresses.map({ $0.value as String })
    }
    
    #if canImport(UIKit)
    /// Returns a `UIImage` from `contact.imageData` if present
    public var largeImage: UIImage?
    
    /// Returns a `UIImage` from `contact.thumbnailImageData` if present,
    /// or if not, a photo generated from `Self.placeholderWithInitials(:)`
    public var photo: UIImage?
    #endif
    
    /// Returns an array of the contact's mobile numbers as strings.
    ///
    /// This maps `contact.phoneNumbers` returning the values of all numbers
    /// which have the label `CNLabelPhoneNumberiPhone` or `CNLabelPhoneNumberMobile`
    public var mobileNumbers: [String] {
        let mobileLabels = [
            CNLabelPhoneNumberiPhone,
            CNLabelPhoneNumberMobile
        ]
        let numbers = contact.phoneNumbers.filter { (value) -> Bool in
            guard let label = value.label else { return false }
            return mobileLabels.contains(label)
        }
        return numbers.map({ $0.value.stringValue })
    }
    
    /// Returns all of the contact's phone numbers as strings
    public var phoneNumbers: [String] {
        return contact.phoneNumbers.map({ $0.value.stringValue })
    }
    
    #if canImport(UIKit)
    /// Returns a circular placeholder image for the contact based on the provided initials
    /// - Parameter initials: The initials for the contact
    /// - Parameter backgroundColor: The background colour for the placeholder image
    /// - Parameter textColor: The text colour to render the initials in
    /// - Returns: A round UIImage with the contact's initials displayed
    public class func contactPlaceholder(
        initials: String,
        backgroundColor: UIColor = UIColor(
            displayP3Red: 203.0/255.0,
            green: 194.0/255.0,
            blue: 188.0/255.0,
            alpha: 1.0
        ),
        textColor: UIColor = UIColor(
            displayP3Red: 246.0/255.0,
            green: 241.0/255.0,
            blue: 236.0/255.0,
            alpha: 1.0
        )
    ) -> UIImage? {
        
        let rect = CGRect(x: 0, y: 0, width: 126, height: 126)
        UIGraphicsBeginImageContextWithOptions(
            rect.size,
            false,
            2.0
        )
        
        backgroundColor.setFill()
        
        let circlePath = UIBezierPath(ovalIn: rect)
        circlePath.lineWidth = 6.0
        circlePath.fill()
        
        let paragraphStyle = NSParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle ?? NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 52),
            .paragraphStyle: paragraphStyle,
            .foregroundColor: textColor
        ]
        
        let textSize = (initials as NSString).size(
            withAttributes: textAttributes
        )
        
        let textRect = CGRect(
            x: rect.origin.x,
            y: rect.origin.y + (rect.size.height - textSize.height)/2,
            width: rect.size.width,
            height: textSize.height
        )
        
        (initials as NSString).draw(in: textRect, withAttributes: textAttributes)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    #endif
    
    deinit {
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
