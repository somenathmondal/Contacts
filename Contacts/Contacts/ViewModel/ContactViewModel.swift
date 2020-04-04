//
//  ContactViewModel.swift
//  Contacts
//
//  Created by Somenath on 21/03/20.
//  Copyright © 2020 Somenath. All rights reserved.
//

import Foundation

class ContactViewModel {
    
    
    func getAllContacts(completion: @escaping ([Contact]?) -> Void) {
        ContactManager.shared.getAllContacts { (contactArr) in
            completion(contactArr)
        }
    }
    
    func getContactArrayForSection(sec: Int) -> [Contact] {
        
        let sectionArr = ContactManager.shared.contactArray.filter { (contact) -> Bool in
            if (sec != 0) {
                return String((contact.first_name?.first?.lowercased())!) == sectionArray[sec].lowercased()
            }
            else {
                return String((contact.first_name?.first?.lowercased())!) < "a" || String((contact.first_name?.first?.lowercased())!) > "z"
            }
        }
        return sectionArr
        
    }
}


extension ContactViewModel {
    
    
}
