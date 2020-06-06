//
//  CoreDataManager.swift
//  ContactsTest
//
//  Created by Andrew Matsota on 04.06.2020.
//  Copyright © 2020 Andrew Matsota. All rights reserved.
//

import Foundation
import CoreData

class CoreDataManager {
    
    static let shared = CoreDataManager()
    var managedObjectContext: NSManagedObjectContext?
    
    //MARK: - Save data
    func saveContact(data: ContactStruct) {
        let contactsData = ContactsData(context: PersistenceService.context)
        
        contactsData.name = data.name
        contactsData.surname = data.surname
        contactsData.mail = data.mail
        contactsData.phone = data.phone
        contactsData.imageData = data.image
        
        PersistenceService.saveContext()
    }
    
    //MARK: - Save data + success block
    func saveContact(data: ContactStruct, success: @escaping() -> Void) {
        let contactsData = ContactsData(context: PersistenceService.context)
        
        contactsData.name = data.name
        contactsData.surname = data.surname
        contactsData.mail = data.mail
        contactsData.phone = data.phone
        contactsData.imageData = data.image
        
        PersistenceService.saveContext()
        success()
    }
    
    //MARK: - Fetch all contacts
    func fetchContactData(success: @escaping([ContactsData]) -> Void, failure: @escaping(NSError) -> Void) {
        let fetchRequest: NSFetchRequest<ContactsData> = ContactsData.fetchRequest()
        do {
            let result = try PersistenceService.context.fetch(fetchRequest)
            success(result)
        } catch let error as NSError{
            failure(error)
        }
    }
    
    //MARK: - Delete certain contact
    func deleteCertainContact(contact: ContactsData) {
        PersistenceService.context.delete(contact)
        PersistenceService.saveContext()
    }
    
    //MARK: - Delete all contacts
    func deleteAllData(entity: String, success: @escaping() -> Void, failure: @escaping(NSError) -> Void) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        do
        {
            let results = try PersistenceService.context.fetch(fetchRequest)
            for managedObject in results
            {
                let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
                PersistenceService.context.delete(managedObjectData)
                PersistenceService.saveContext()
            }
            success()
        } catch let error as NSError {
            failure(error)
        }
    }
    
}
