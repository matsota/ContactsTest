//
//  ContactsViewController.swift
//  ContactsTest
//
//  Created by Andrew Matsota on 04.06.2020.
//  Copyright © 2020 Andrew Matsota. All rights reserved.
//

import UIKit


class ContactsViewController: UIViewController{
    
    //MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        restoreDataActivityIndicator.stopAnimating()
        mySearchBar.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        CoreDataManager.shared.fetchContactData(success: { (data) in
            self.contactsData = data.sorted(by: { (a, z) -> Bool in
                guard let a = a.name, let z = z.name else {return false}
                return a.lowercased() < z.lowercased()
            })
            self.tableView.reloadData()
        }) { (error) in
            self.present(UIAlertController.completionDoneTwoSec(title: "", message: ""), animated: true)
            print("ERROR: ContactsViewController: viewDidLoad: fetchContactData: ", error.localizedDescription)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let _ = sender as? ContactsTableViewCell {
            if segue.identifier == NavigationCases.Transition.contact_DetailContact.rawValue, let destination = segue.destination as? DetailContactViewController, let index = tableView.indexPathsForSelectedRows?.first  {
                var contactData: ContactsData
                if searchActive, mySearchBar.text != "" {
                    contactData = filteredContactsData[index.row]
                    destination.contactData = contactData
                }else{
                    contactData = contactsData[index.row]
                    destination.contactData = contactData
                }
            }
        }
    }
    
    //MARK: - Reset to default state
    @IBAction private func resetToDefaultStateTapped(_ sender: UIButton) {
        self.present(UIAlertController.classic(title: "Внимание!", message: "При возврате оригинальной контактой книги все ваши изменения исчезнут. Подтвердите свои намерения") {
            self.restoreDataActivityIndicator.startAnimating()
            CoreDataManager.shared.deleteAllData(entity: NavigationCases.Entities.ContactsData.rawValue, success: {
                ContactsManager.shared.fetchContacts(success: {
                    CoreDataManager.shared.fetchContactData(success: { (data) in
                        self.contactsData = data
                        self.tableView.reloadData()
                        self.present(UIAlertController.completionDoneHalfSec(title: "Отлично!", message: "Вы подтянули свою книгу контактов заново"), animated: true)
                        self.restoreDataActivityIndicator.stopAnimating()
                    }) { (error) in
                        self.present(UIAlertController.completionDoneTwoSec(title: "Внимание", message: "Обновление провалилось."), animated: true)
                        self.restoreDataActivityIndicator.stopAnimating()
                    }
                }) { (error) in
                    self.present(UIAlertController.completionDoneTwoSec(title: "Внимание", message: "Обновление провалилось."), animated: true)
                    self.restoreDataActivityIndicator.stopAnimating()
                }
            }) { (error) in
                self.present(UIAlertController.completionDoneTwoSec(title: "Внимание", message: "Обновление провалилось."), animated: true)
                self.restoreDataActivityIndicator.stopAnimating()
            }
        }, animated: true)
        
    }
    
    //MARK: - Private Implementation
    private var contactsData = [ContactsData]()
    private var filteredContactsData = [ContactsData]()
    private var searchActive : Bool = false
    
    //MARK: Search Bar
    @IBOutlet private weak var mySearchBar: UISearchBar!
    
    
    //MARK: Table View
    @IBOutlet private weak var tableView: UITableView!
    
    //MARK: Button
    @IBOutlet private weak var resetButton: UIButton!
    
    //MARK: Activity Indicator
    @IBOutlet private weak var restoreDataActivityIndicator: UIActivityIndicatorView!
    
    //MARK: Constraint
    @IBOutlet private weak var tableViewBottonConstraint: NSLayoutConstraint!
    
}









//MARK: - Extentions

//MARK: - Table View
extension ContactsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchActive {
            return filteredContactsData.count
        }
        return contactsData.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NavigationCases.Transition.ContactsTVCell.rawValue, for: indexPath) as! ContactsTableViewCell
        cell.delegate = self
        var fetch: ContactsData
        
        if searchActive {
            fetch = filteredContactsData[indexPath.row]
        }else{
            fetch = contactsData[indexPath.row]
        }
        
        let name = fetch.name,
        surname = fetch.surname,
        mail = fetch.mail,
        image = fetch.imageData ?? UIImage(named: "noPhoto")?.jpegData(compressionQuality: .infinity)
        
        
        
        cell.fill(name: name ?? "ошибка", surname: surname ?? "ошибка" , mail: mail ?? "ошибка", image: image!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = deleteAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    private func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Удалить") { (action, view, complition) in
            
            if self.searchActive {
                self.contactsData.removeAll { (data) -> Bool in
                    if data.phone == self.filteredContactsData[indexPath.row].phone{
                        CoreDataManager.shared.deleteCertainContact(contact: self.filteredContactsData[indexPath.row])
                        return true
                    }
                    return false
                }
                self.filteredContactsData.remove(at: indexPath.row)
            }else{
                CoreDataManager.shared.deleteCertainContact(contact: self.contactsData[indexPath.row])
                self.contactsData.remove(at: indexPath.row)
            }
            self.tableView.reloadData()
            complition(true)
        }
        action.backgroundColor = .red
        return action
    }
    
}

//MARK: Table Cell protocol
extension ContactsViewController: ContactsTableViewCellDelegate {
    
    @objc func copyMail(_ cell: ContactsTableViewCell) {
        if cell.contactMailLabel.text == "no email"{
            self.present(UIAlertController.completionDoneHalfSec(title: "No email", message: "To Copy"), animated: true)
        }
        self.present(UIAlertController.completionDoneHalfSec(title: "Email", message: "is copied") {
            UIPasteboard.general.string = cell.contactMailLabel.text
        }, animated: true)
    }
    
}

//MARK: Search bar
extension ContactsViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredContactsData = contactsData.filter({ (data) -> Bool in
            let string: NSString = data.name!.lowercased() as NSString,
            range = string.range(of: searchText.lowercased(), options: .literal)
            print(range)
            return range.location != NSNotFound
        })
        if filteredContactsData.count == 0 {
            searchActive = false
        }else{
            searchActive = true
        }
        self.tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
    }
    
}

//MARK: - Hide and show Any
private extension ContactsViewController {
    
    @objc func keyboardWillShow(notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber, let keyboardFrameValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        tableViewBottonConstraint.constant = keyboardFrameValue.cgRectValue.height - resetButton.frame.height
        UIView.animate(withDuration: duration.doubleValue) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber else {return}
        tableViewBottonConstraint.constant = 14
        UIView.animate(withDuration: duration.doubleValue) {
            self.view.layoutIfNeeded()
        }
    }
    
}
