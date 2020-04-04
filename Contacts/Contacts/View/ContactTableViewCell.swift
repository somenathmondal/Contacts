//
//  ContactTableViewCell.swift
//  Contacts
//
//  Created by Somenath on 17/03/20.
//  Copyright © 2020 Somenath. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell {

    @IBOutlet weak var photoImgView: UIImageView!
    @IBOutlet weak var personNameLabel: UILabel!
    @IBOutlet weak var favoriteImgView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        self.favoriteImgView.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
