//
//  UIAlertController + Custom.swift
//  ContactsTest
//
//  Created by Andrew Matsota on 04.06.2020.
//  Copyright © 2020 Andrew Matsota. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    //MARK: Alert with 2 buttons and 2 textfields
    static func createNewContact(title: String, success: @escaping(ContactStruct, ContactsData) -> Void) -> (UIAlertController) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.addTextField { (textField: UITextField) in
            textField.keyboardType = .namePhonePad
            textField.placeholder = "name"
        }
        alert.addTextField { (textField: UITextField) in
            textField.keyboardType = .namePhonePad
            textField.placeholder = "surname"
        }
        alert.addTextField { (textField: UITextField) in
            textField.keyboardType = .emailAddress
            textField.placeholder = "email"
        }
        alert.addTextField { (textField: UITextField) in
            textField.keyboardType = .phonePad
            textField.placeholder = "phone"
        }
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Создать", style: .default, handler: { action in
            let name = alert.textFields?.first?.text ?? "no name",
            surname = alert.textFields?[1].text ?? "no surname",
            mail = alert.textFields?[2].text ?? "no mail",
            phone = alert.textFields?.last?.text ?? "no phone"
            
            let data = ContactStruct(name: name, surname: surname, mail: mail, phone: phone, image: Data())
            let contactData = ContactsData()
            contactData.name = name
            contactData.surname = surname
            contactData.mail = mail
            contactData.phone = phone
            success(data, contactData)
        }))
        return alert
    }
    
    //MARK: - Ok && Deny
    static func classic(title: String, message: String, success: @escaping() -> Void) -> (UIAlertController){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let actionOk = UIAlertAction(title: "Подтвердить", style: .default) { _ in
            success()
        }
        let actionDeny = UIAlertAction(title: "Отмена", style: .destructive, handler: nil)
        
        alert.addAction(actionOk)
        alert.addAction(actionDeny)
    
        return alert
    }
    
    //MARK: - Show alert for half sec
    static func completionDoneHalfSec(title: String, message: String, success: @escaping() -> Void) -> (UIAlertController){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            alert.dismiss(animated: true, completion: nil)
        }
        success()
        return alert
    }
    static func completionDoneHalfSec(title: String, message: String) -> (UIAlertController){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            alert.dismiss(animated: true, completion: nil)
        }
        return alert
    }
    
    //MARK: - Show alert for two sec
    static func completionDoneTwoSec(title: String, message: String) -> (UIAlertController){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            alert.dismiss(animated: true, completion: nil)
        }
        return alert
    }
}
