//
//  ContactsController.swift
//  ThunderBasics-iOS
//
//  Created by Simon Mitchell on 29/09/2020.
//  Copyright © 2020 threesidedcube. All rights reserved.
//

import Contacts
#if canImport(UIKit)
import ContactsUI

fileprivate class ContactPickerViewController: CNContactPickerViewController {
    
    fileprivate var statusBarStyle: UIStatusBarStyle = .default
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }
}

fileprivate class ContactViewController: CNContactViewController {
    
    fileprivate var statusBarStyle: UIStatusBarStyle = .default
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }
}
#endif

public typealias ContactSelectedCompletion = (_ contact: AutoUpdatingContact?, _ error: Error?) -> Void

#if canImport(UIKit)
extension ContactsController: CNContactPickerDelegate {
    
}
#endif

/// Contacts controller is responsible for handling all interaction with the user's address book.
///
/// There are convenience methods for giving the user the option to select a contact, automatically
/// handling authentication and returning a CNContact in the closure
public class ContactsController: NSObject {
    
    #if canImport(UIKit)
    private var presentedPersonViewController: UINavigationController?
    #endif
    
    private var contactRefreshObserver: AnyObject?
    
    private var personSelectedCompletion: ContactSelectedCompletion?
    
    public static let shared = ContactsController()
        
    private override init() {
        super.init()
    }
    
    #if canImport(UIKit)
    /// Presents a contact picker view controller for selecting an individual contact
    /// - Parameters:
    ///   - viewController: The view controller to present from
    ///   - statusBarStyle: The status bar style to be used for the picker
    ///   - completion: A closure called once a contact is picked
    public func presentPeoplePicker(
        in viewController: UIViewController,
        statusBarStyle: UIStatusBarStyle = .default,
        completion: @escaping ContactSelectedCompletion
    ) {
        personSelectedCompletion = completion
        let pickerViewController = ContactPickerViewController()
        pickerViewController.delegate = self
        pickerViewController.statusBarStyle = statusBarStyle
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            viewController.modalPresentationStyle = .formSheet
            pickerViewController.modalPresentationStyle = .formSheet
        }
        viewController.present(
            pickerViewController,
            animated: true,
            completion: nil
        )
    }
    #endif
    
    // MARK: - Converting and extracting users
    
    /// Finds and returns the contact with a given identifier
    /// - Parameter identifier: The identifier to return a contact for
    /// - Returns: The contact, if found
    public func contact(for identifier: String) -> CNContact? {
        let store = CNContactStore()
        return try? store.unifiedContact(
            withIdentifier: identifier,
            keysToFetch: ContactsController.contactKeysToFetch
        )
    }
    
    /// Loads and returns all contacts from the user's address book
    /// - Throws: Throws an error if one occured
    /// - Returns: The full array of all contacts
    public func allContacts() throws -> [CNContact] {
        
        let store = CNContactStore()
        let fetchRequest = CNContactFetchRequest(keysToFetch: ContactsController.contactKeysToFetch)
        var contacts: [CNContact] = []
        do {
            try store.enumerateContacts(
                with: fetchRequest
            ) { (contact, _) in
                contacts.append(contact)
            }
        } catch let error {
            throw error
        }
        return contacts
    }
    
    /// Returns an array of contacts from the given identifiers
    /// - Parameter identifiers: The contact identifiers to lookup
    /// - Returns: An array of valid contacts from the identifiers
    func contacts(for identifiers: [String]) -> [CNContact] {
        return identifiers.compactMap({ contact(for: $0) })
    }
    
    // MARK: - Presenting/Editing contacts
    
    #if canImport(UIKit)
    /// Returns a CNContactViewController for the contact with given identifier if could be found
    /// - Parameter identifier: The identifier of the contact
    /// - Returns: A contact view controller
    func contactViewController(for identifier: String) -> CNContactViewController? {
        guard let contact = contact(for: identifier) else { return nil }
        return ContactViewController(for: contact)
    }
    
    /// Presents the contact with the given identifier
    /// - Parameters:
    ///   - identifier: The contact identifier for the contact
    ///   - statusBarStyle: The status bar style to render
    /// - Returns: Whether any UI was shown
    func presentContact(
        with identifier: String,
        from viewController: UIViewController,
        statusBarStyle: UIStatusBarStyle = .default
    ) -> Bool {
        guard let contactVC = contactViewController(for: identifier) else { return false }
        (contactVC as? ContactViewController)?.statusBarStyle = statusBarStyle
        contactVC.navigationItem.backBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(dismissPeopleView)
        )
        
        let navController = UINavigationController(rootViewController: contactVC)
        presentedPersonViewController = navController
        viewController.present(navController, animated: true, completion: nil)
        return true
    }
    
    @objc private func dismissPeopleView() {
        presentedPersonViewController?.dismiss(animated: true, completion: nil)
    }
    #endif
    
    #if canImport(UIKit)
    static let contactKeysToFetch: [CNKeyDescriptor] = [
        CNContactGivenNameKey as CNKeyDescriptor,
        CNContactFamilyNameKey as CNKeyDescriptor,
        CNContactNicknameKey as CNKeyDescriptor,
        CNContactPhoneNumbersKey as CNKeyDescriptor,
        CNContactEmailAddressesKey as CNKeyDescriptor,
        CNContactImageDataKey as CNKeyDescriptor,
        CNContactThumbnailImageDataKey as CNKeyDescriptor,
        CNContactViewController.descriptorForRequiredKeys()
    ]
    #else
    static let contactKeysToFetch: [CNKeyDescriptor] = [
        CNContactGivenNameKey as CNKeyDescriptor,
        CNContactFamilyNameKey as CNKeyDescriptor,
        CNContactNicknameKey as CNKeyDescriptor,
        CNContactPhoneNumbersKey as CNKeyDescriptor,
        CNContactEmailAddressesKey as CNKeyDescriptor,
        CNContactImageDataKey as CNKeyDescriptor,
        CNContactThumbnailImageDataKey as CNKeyDescriptor,
    ]
    #endif
    
    #if canImport(UIKit)
    public func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        personSelectedCompletion?(nil, nil)
    }
    
    public func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        personSelectedCompletion?(AutoUpdatingContact(contact), nil)
    }
    #endif
}
