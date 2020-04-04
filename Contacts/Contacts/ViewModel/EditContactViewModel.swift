//
//  EditContactViewModel.swift
//  Contacts
//
//  Created by Somenath on 23/03/20.
//  Copyright © 2020 Somenath. All rights reserved.
//

import Foundation

class EditContactViewModel {
    
    var contactDetails = Contact()
    var edittedContact = [String : String]()
    var isNewContact = false
    
    
    func updateContactDetails(completion: @escaping (Bool) -> Void) {
        
        var bodyContact = [String: String]()

        bodyContact["first_name"] = edittedContact["first_name"]
        bodyContact["last_name"] = edittedContact["last_name"]
        bodyContact["email"] = edittedContact["email"]
        bodyContact["phone_number"] = edittedContact["phone_number"]

        
        if isNewContact == false {
            let urlSt = contactDetails.url
            ContactManager.shared.editContactDetails(urlStr: urlSt!, bodyStr: bodyContact) { (updatedContact) in
                //print(contact)
                if updatedContact != nil {
                    completion(true)
                }
                else {
                    completion(false)
                }
            }
        }
        else {
            ContactManager.shared.addNewContactDetails(urlStr: contactsURL, bodyStr: bodyContact) { (newContact) in
                //print(newContact)
                if newContact != nil {
                    completion(true)
                }
                else {
                    completion(false)
                }
            }
        }
        
    }
}
