//
//  UIVC + Custom.swift
//  ContactsTest
//
//  Created by Andrew Matsota on 04.06.2020.
//  Copyright © 2020 Andrew Matsota. All rights reserved.
//

import UIKit

//MARK: - Hide Keyboard
extension UIViewController {
    
    @objc func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    
}
