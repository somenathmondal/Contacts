//
//  ContactManager.swift
//  Contacts
//
//  Created by Somenath on 23/03/20.
//  Copyright © 2020 Somenath. All rights reserved.
//

import Foundation


class ContactManager {

    static let shared = ContactManager()
    
    private let concurrentContactQueue =
    DispatchQueue(
      label: "contactQueue",
      attributes: .concurrent)
    
    private var copyContactArray = [Contact]()
    
    var contactArray: [Contact] {
         var contactCopy: [Contact]!
        concurrentContactQueue.sync {
            contactCopy = self.copyContactArray
        }
        return contactCopy
    }
    
    let nc = NotificationCenter.default
    
    var errors = [String]()
    

    private init() {
    }
    
    
    //MARK:- ContactArray Operations
    
    func updateContactArray(newContactVar: Contact) {
        for (index, ele) in self.contactArray.enumerated() {
            if (ele.id == newContactVar.id) {
                self.concurrentContactQueue.async(flags: .barrier) { [weak self] in
                    guard let self = self else {
                        return
                    }
                   
                    self.copyContactArray[index] = newContactVar
                   
                }
            }
        }
    }
    
    func addContactInArray(newContact: Contact) {
        
        self.copyContactArray.append(newContact)
        self.copyContactArray.sort { (lhs, rhs) -> Bool in
           return (lhs.first_name ?? "") < (rhs.first_name ?? "")
        }
    }
    
    func removeContactFromArray(contactToDelete: Contact) {
        
        for (index, ele) in self.contactArray.enumerated() {
            if (ele.id == contactToDelete.id) {
                self.concurrentContactQueue.async(flags: .barrier) { [weak self] in
                    guard let self = self else {
                       return
                    }
                    self.copyContactArray.remove(at: index)
                    return
                }
            }
        }
        
        self.removeContact(urlStr: contactToDelete.url!)
    }
    
    
    
    //MARK:- API Calls
    
    // 1 - Get All Contacts
    func getAllContacts(completion: @escaping ([Contact]?) -> Void) {
       
        concurrentContactQueue.async(flags: .barrier) { [weak self] in
            guard let self = self else {
              return
            }
            NetworkManager.shared.getAllContacts { (jsonData) in
                           //Parse
                self.copyContactArray = self.parseContactJSON(jsonData: jsonData!)
                self.copyContactArray.sort { (lhs, rhs) -> Bool in
                    return (lhs.first_name ?? "") < (rhs.first_name ?? "")
                }
                completion(self.copyContactArray)
            }
            
        }
    }
    
    // 2 - Get Details of a Contact
    func getContactDetails(currentContact: Contact, completion: @escaping(Contact?) -> Void) {
        
        NetworkManager.shared.getContactDetails(urlString: currentContact.url!) { (jsonData) in
            var newContactVar = self.parseContactDetailJSON(jsonData: jsonData!)
            newContactVar?.url = currentContact.url
            
            if let newContactVar = newContactVar {
                self.updateContactArray(newContactVar: newContactVar)
            }
            completion(newContactVar)
        }
        
 
    }
    
    // 3 - Edit Details of a Contact
    func editContactDetails(urlStr: String, bodyStr: [String: Any], completion: @escaping (Contact?) -> Void) {
        NetworkManager.shared.editContactDetails(urlStr: urlStr, httpMethod: "PUT", body: bodyStr) { (contactData) in
            var updatedContact = self.parseContactDetailJSON(jsonData: contactData!)
            updatedContact?.url = urlStr
            
            if let updatedContact = updatedContact {
                self.updateContactArray(newContactVar: updatedContact)
                
                let newDict = ["info": updatedContact]
                self.nc.post(Notification(name: Notification.Name(rawValue: "ContactUpdated"), object: nil, userInfo: newDict))
            }
            completion(updatedContact)
        }
        
    }
    
    // 4 - Add a new Contact
    func addNewContactDetails(urlStr: String, bodyStr: [String: String], completion: @escaping (Contact?) -> Void) {
        NetworkManager.shared.editContactDetails(urlStr: urlStr, httpMethod: "POST", body: bodyStr) { (contactData) in
            let newContact = self.parseContactDetailJSON(jsonData: contactData!)
                        
            if var newContact = newContact {
                newContact.url = baseURL + "/contacts/\(newContact.id!).json"
                self.addContactInArray(newContact: newContact)
                
                let newDict = ["info": newContact]
                self.nc.post(Notification(name: Notification.Name(rawValue: "ContactAdded"), object: nil, userInfo: newDict))
            }
            completion(newContact)
        }
    }
   
    // 5 - Remove a Contact
    func removeContact(urlStr: String) {
        NetworkManager.shared.removeContact(urlStr: urlStr)
    }
}


extension ContactManager {
    
    func parseContactJSON(jsonData: Any) -> [Contact] {
        var contactList = [Contact]()
        //var contactList2 = [Contact2]()
        
        let json = (jsonData as? [[String: Any]])!
        
        for contact in json {
            var newContact = Contact()
            
            if let id = contact["id"] as? Int {
                newContact.id = id
            }
            if let favorite = contact["favorite"] as? Int {
                newContact.favorite = favorite
            }
            if let firstName = contact["first_name"] as? String {
                newContact.first_name = firstName
            }
            if let lastName = contact["last_name"] as? String {
                newContact.last_name = lastName
            }
            if let profile_pic = contact["profile_pic"] as? String {
                newContact.profile_pic = profile_pic
            }
            if let url = contact["url"] as? String {
                newContact.url = url
            }
            
            contactList.append(newContact)
        }
        
        
//        do {
//            contactList2 = try JSONDecoder().decode([Contact2].self, from: jsonData as! Data)
//            print(contactList2)
//        }
//        catch {
//
//        }
        return contactList
    }
    
    
    func parseContactDetailJSON(jsonData: Any) -> Contact? {
                
        let contact = (jsonData as? [String: Any])!
        
        
        if let error = contact["errors"] as? [String] {
            self.errors = error
            return nil
        }
        
        
        var newContact = Contact()
        
        if let email = contact["email"] as? String {
            newContact.email = email
        }
        if let phoneNo = contact["phone_number"] as? String {
            newContact.phone_number = phoneNo
        }
        if let id = contact["id"] as? Int {
            newContact.id = id
        }
        if let favorite = contact["favorite"] as? Int {
            newContact.favorite = favorite
        }
        if let firstName = contact["first_name"] as? String {
            newContact.first_name = firstName
        }
        if let lastName = contact["last_name"] as? String {
            newContact.last_name = lastName
        }
        if let profile_pic = contact["profile_pic"] as? String {
            newContact.profile_pic = profile_pic
        }
        if let created_at = contact["created_at"] as? String {
            newContact.created_at = created_at
        }
        if let updated_at = contact["updated_at"] as? String {
            newContact.updated_at = updated_at
        }
            
        return newContact
    }
}
