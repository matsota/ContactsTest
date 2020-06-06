//
//  DetailContactViewController.swift
//  ContactsTest
//
//  Created by Andrew Matsota on 05.06.2020.
//  Copyright © 2020 Andrew Matsota. All rights reserved.
//

import UIKit

class DetailContactViewController: UIViewController {
    
    //MARK: - Implementation
    var contactData = ContactsData()
    
    //MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        // - image
        if contactData.imageData != nil {
            self.imageView.image = UIImage(data: contactData.imageData!)
        }else{
            self.imageView.image = UIImage(named: "noPhoto")
        }
        imageView.layer.cornerRadius = imageView.frame.width * 0.45
        imageView.layer.borderColor = UIColor.gray.cgColor
        imageView.layer.borderWidth = 2
        
        // - textfields
        nameTextField.text = contactData.name
        surnameTextField.text = contactData.surname
        emailTextField.text = contactData.mail
        phoneTextField.text = contactData.phone
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //MARK: - Save changes
    @IBAction private func backOrSaveTapped(_ sender: UIButton) {
            let name = self.nameTextField.text ?? "no name",
            surname = self.surnameTextField.text ?? "no surname",
            mail = self.emailTextField.text ?? "no email",
            phone = self.phoneTextField.text ?? "no phone",
            data = self.contactData.imageData ?? UIImage(named: "noPhoto")?.jpegData(compressionQuality: .infinity),
            contact = ContactStruct(name: name, surname: surname, mail: mail, phone: phone, image: data!)
            CoreDataManager.shared.saveContact(data: contact) {
                CoreDataManager.shared.deleteCertainContact(contact: self.contactData)
                self.present(UIAlertController.completionDoneHalfSec(title: "Великолепно!", message: "Изменения сохранены"), animated: true)
            }
    }
    
    //MARK: - Private Implementation
    
    //MARK: Image
    @IBOutlet private weak var imageView: UIImageView!
    
    //MARK: Text field
    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var surnameTextField: UITextField!
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var phoneTextField: UITextField!
    
    //MARK: Constraint
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
}



//MARK: - Hide And Show Any
private extension DetailContactViewController {
    
    @objc func keyboardWillShow(notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber, let keyboardFrameValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        scrollViewBottomConstraint.constant = keyboardFrameValue.cgRectValue.height + 14
        UIView.animate(withDuration: duration.doubleValue) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber else {return}
        scrollViewBottomConstraint.constant = 14
        UIView.animate(withDuration: duration.doubleValue) {
            self.view.layoutIfNeeded()
        }
    }
}
