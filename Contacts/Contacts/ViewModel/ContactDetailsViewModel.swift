//
//  ContactDetailsViewModel.swift
//  Contacts
//
//  Created by Somenath on 23/03/20.
//  Copyright © 2020 Somenath. All rights reserved.
//

import Foundation



class ContactDetailsViewModel {
    
    var contactDetails: Contact?
   
    func getContactDetails(completion: @escaping (Contact?) -> (Void)) {
        ContactManager.shared.getContactDetails(currentContact: contactDetails!) { (contact) in
            self.contactDetails = contact
            completion(contact)
        }
    }
    
    func editFavoriteContact(completion: @escaping (Bool) -> Void) {
        let urlSt = contactDetails?.url
        let val = (contactDetails?.favorite == 1) ? false : true
        let bodyContact = ["favorite" : val]

        ContactManager.shared.editContactDetails(urlStr: urlSt!, bodyStr: bodyContact) {[weak self] (updatedContact) in
            
            //print(contact)
            if updatedContact != nil {
                self?.contactDetails = updatedContact
                completion(true)
            }
            else {
                completion(false)
            }
        }
    }
    
}
