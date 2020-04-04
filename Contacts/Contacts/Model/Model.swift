//
//  Model.swift
//  Contacts
//
//  Created by Somenath on 21/03/20.
//  Copyright © 2020 Somenath. All rights reserved.
//

import Foundation


struct Contact: Codable {
    var favorite: Int? = 0
    var first_name: String? = ""
    var last_name: String? = ""
    var id: Int? = 0
    var profile_pic: String? = ""
    var url: String? = ""
    
    var email: String? = ""
    var phone_number: String? = ""
    var created_at: String? = ""
    var updated_at: String? = ""
}

struct Contact2: Codable {
    var favorite: Bool? = false
    var first_name: String? = ""
    var last_name: String? = ""
    var id: Int? = 0
    var profile_pic: String? = ""
    var url: String? = ""
}
