//
//  TableViewCell.swift
//  ContactsTest
//
//  Created by Andrew Matsota on 04.06.2020.
//  Copyright © 2020 Andrew Matsota. All rights reserved.
//

import UIKit

//MARK: - Cell protocol
protocol ContactsTableViewCellDelegate: class {
    func copyMail(_ cell: ContactsTableViewCell)
}


//MARK: - Cell
class ContactsTableViewCell: UITableViewCell {

    //MARK: - Implementation
    weak var delegate: ContactsTableViewCellDelegate?

    //MARK: Image
    @IBOutlet weak var contactImageView: UIImageView!
    
    //MARK: Label
    @IBOutlet weak var contactNameLabel: UILabel!
    @IBOutlet weak var contactSurnameLabel: UILabel!
    @IBOutlet weak var contactMailLabel: UILabel!
    
    
    //MARK: - Override
    override func awakeFromNib() {
        super.awakeFromNib()
        let copyMail = UILongPressGestureRecognizer()
        copyMail.addTarget(self, action: #selector(self.copyMail(sender:)))
        contactMailLabel.addGestureRecognizer(copyMail)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    
    //MARK: - Gestures methods
    @objc private func copyMail(sender: UILongPressGestureRecognizer) {
        delegate?.copyMail(self)
    }
    
    //MARK: - Fill Table View
    func fill(name: String, surname: String, mail: String, image: Data) {
        
        contactNameLabel.text = name
        contactSurnameLabel.text = surname
        contactMailLabel.text = mail
    
        contactImageView.image = UIImage(data: image)
        contactImageView.layer.cornerRadius = contactImageView.frame.width / 2
        contactImageView.layer.borderWidth = 1
        contactImageView.layer.borderColor = UIColor.gray.cgColor
        
    }

}
