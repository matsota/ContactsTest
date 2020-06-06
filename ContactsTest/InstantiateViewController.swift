//
//  InstantiateViewController.swift
//  ContactsTest
//
//  Created by Andrew Matsota on 05.06.2020.
//  Copyright © 2020 Andrew Matsota. All rights reserved.
//

import UIKit
import Contacts

class InstantiateViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CoreDataManager.shared.fetchContactData(success: { (data) in
            if let _ = data.map({$0.name}).first {
                self.transitionForward()
            }else{
                ContactsManager.shared.fetchContacts(success: {
                    DispatchQueue.main.sync {
                        self.transitionForward()
                    }
                }) { error in
                    self.present(UIAlertController.completionDoneTwoSec(title: "Внимание!", message: "Произошла ошибка. Попробуйте перезагрузить приложение"), animated: true)
                    print("ERROR: InstantiateViewController: viewDidLoad: fetchContactData: fetchContacts", error.localizedDescription)
                }
            }
        }) { (error) in
            self.present(UIAlertController.completionDoneTwoSec(title: "Внимание!", message: "Произошла ошибка. Попробуйте перезагрузить приложение"), animated: true)
            print("ERROR: InstantiateViewController: viewDidLoad: fetchContactData: ", error.localizedDescription)
        }
    }
    
}


private extension InstantiateViewController {
    
    //MARK: Transition Forward
    func transitionForward() {
        let destination = storyboard?.instantiateViewController(withIdentifier: NavigationCases.Transition.ContactsVC.rawValue) as! ContactsViewController
        self.navigationController?.pushViewController(destination, animated: true)
    }
    
}
