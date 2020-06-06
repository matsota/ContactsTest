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
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        hideKeyboardWhenTappedAround()
        setupSearchBar()
        
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
        if let cell = sender as? ContactsTableViewCell {
            if segue.identifier == NavigationCases.Transition.contact_DetailContact.rawValue, let destination = segue.destination as? DetailContactViewController, let index = tableView.indexPath(for: cell)?.row {
                var contactData: ContactsData
                if isFiltering == true {
                    contactData = filteringContactsBySearchController[index]
                    destination.contactData = contactData
                }else{
                    contactData = contactsData[index]
                    destination.contactData = contactData
                }
            }
        }
        //        if segue.identifier == NavigationCases.Transition.contact_DetailContact.rawValue, let detailVC = segue.destination as? DetailContactViewController, let index = tableView.indexPathsForSelectedRows?.first?.row {
        //            var contactData: ContactsData
        //            if isFiltering == true {
        //                contactData = filteringContactsBySearchController[index]
        //                detailVC.contactData = contactData
        //            }else{
        //                contactData = contactsData[index]
        //                detailVC.contactData = contactData
        //            }
        //        }
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
    var contactsData = [ContactsData]()
    private var filteringContactsBySearchController = [ContactsData]()
    private var searchController = UISearchController(searchResultsController: nil)
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else {return false}
        return text.isEmpty
    }
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    //MARK: Table View
    @IBOutlet private weak var tableView: UITableView!
    
    //MARK: Button
    @IBOutlet weak var resetButton: UIButton!
    
    //MARK: Activity Indicator
    @IBOutlet private weak var restoreDataActivityIndicator: UIActivityIndicatorView!
    
    //MARK: Constraint
    @IBOutlet weak var tableViewBottonConstraint: NSLayoutConstraint!
    
}









//MARK: - Extentions

//MARK: - Table View
extension ContactsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteringContactsBySearchController.count
        }
        return contactsData.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NavigationCases.Transition.ContactsTVCell.rawValue, for: indexPath) as! ContactsTableViewCell
        cell.delegate = self
        var fetch: ContactsData
        
        if isFiltering {
            fetch = self.filteringContactsBySearchController[indexPath.row]
        }else{
            fetch = self.contactsData[indexPath.row]
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
            
            if self.isFiltering {
                self.contactsData.removeAll { (data) -> Bool in
                    if data.phone == self.filteringContactsBySearchController[indexPath.row].phone{
                        CoreDataManager.shared.deleteCertainContact(contact: self.filteringContactsBySearchController[indexPath.row])
                        return true
                    }
                    return false
                }
                self.filteringContactsBySearchController.remove(at: indexPath.row)
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
extension ContactsViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filter(search: searchController.searchBar.text!)
    }
    
    private func filter(search text: String) {
        filteringContactsBySearchController = contactsData.filter({ (data: ContactsData) -> Bool in
            if let name = data.name, let surname = data.surname {
                let strings = [name + " " + surname, surname + " " + name ]
                return strings.contains{ string -> Bool in
                    string.lowercased().contains(text.lowercased())
                }
            }
            return false
        })
        tableView.reloadData()
    }
    
    private func setupSearchBar() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        let searchBar = searchController.searchBar
        searchBar.placeholder = "Начните Поиск"
        searchBar.showsCancelButton = false
        searchBar.enablesReturnKeyAutomatically = false
        searchBar.returnKeyType = .done
        
        tableView.tableHeaderView = searchBar
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
        setupSearchBar()
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber else {return}
        tableViewBottonConstraint.constant = 14
        UIView.animate(withDuration: duration.doubleValue) {
            self.view.layoutIfNeeded()
        }
    }
}
