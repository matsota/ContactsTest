//
//  ContactsManager.swift
//  ContactsTest
//
//  Created by Andrew Matsota on 04.06.2020.
//  Copyright © 2020 Andrew Matsota. All rights reserved.
//

import Foundation
import Contacts

class ContactsManager {
    static let shared = ContactsManager()
    let store = CNContactStore()
    
    
    //MARK: - Read Contacts
    func fetchContacts(success: @escaping() -> Void, failure: @escaping(NSError) -> Void){
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { (granted, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            if granted {
                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey ,CNContactEmailAddressesKey ,CNContactImageDataKey] as [CNKeyDescriptor],
                request = CNContactFetchRequest(keysToFetch: keys)
                do {
                    try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointer) in
                        let name = contact.givenName,
                        surname = contact.familyName,
                        mail = contact.emailAddresses.first?.value ?? "no email",
                        phone = contact.phoneNumbers.first?.value.stringValue ?? "no phone",
                        image = contact.imageData,
                        data = ContactStruct(name: name, surname: surname, mail: mail as String, phone: phone, image: image ?? Data())
                        
                        CoreDataManager.shared.saveContact(data: data)
                    })
                } catch let error as NSError {
                    print("ERROR: ContactsViewController: getContactData()", error.localizedDescription)
                    failure(error)
                }
                success()
            }
        }
    }
    
}

