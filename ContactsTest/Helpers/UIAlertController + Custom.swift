//
//  UIAlertController + Custom.swift
//  ContactsTest
//
//  Created by Andrew Matsota on 04.06.2020.
//  Copyright © 2020 Andrew Matsota. All rights reserved.
//

import UIKit

extension UIAlertController {
    
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
