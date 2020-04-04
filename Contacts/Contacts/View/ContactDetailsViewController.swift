//
//  ContactDetailsViewController.swift
//  Contacts
//
//  Created by Somenath on 19/03/20.
//  Copyright © 2020 Somenath. All rights reserved.
//

import UIKit

class ContactDetailsViewController: UIViewController {
    
    @IBOutlet weak var personImageView: UIImageView!
    @IBOutlet weak var personNameLabel: UILabel!
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var favouriteButton: UIButton!
    
    @IBOutlet weak var mobileNumberLabel: UILabel!
    @IBOutlet weak var emailIDLabel: UILabel!
    
    @IBOutlet weak var navItem: UINavigationItem!
    
    let nc = NotificationCenter.default
    var contactDetailsVM = ContactDetailsViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.personNameLabel.text = (contactDetailsVM.contactDetails?.first_name ?? "") + " " + (contactDetailsVM.contactDetails?.last_name ?? "")
        let colorTop = UIColor.white
        let colorBottom = UIColor(red: 80.0/255.0, green: 227.0/255.0, blue: 192.0/255.5, alpha: 0.28*0.55)
        self.topView.setGradientBackground(colorTop: colorTop, colorBottom: colorBottom)
        
        showDetails()
        nc.addObserver(self, selector: #selector(updateDetails(notification:)), name: Notification.Name(rawValue: "ContactUpdated"), object: nil)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    @IBAction func emailButtonAction(_ sender: Any) {
        
       let callURL = URL(string: "mailto:\(String(describing: self.emailIDLabel.text!))")
       if let url = callURL, UIApplication.shared.canOpenURL(url) {
           if #available(iOS 10, *) {
               UIApplication.shared.open(url)
           } else {
               UIApplication.shared.openURL(url)
           }
       }
    }
    
    @IBAction func callButtonAction(_ sender: Any) {
        let callURL = URL(string: "tel://\(String(describing: self.mobileNumberLabel.text!))")
        if let url = callURL, UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    
    @IBAction func msgButtonAction(_ sender: Any) {
//        displayMessageInterface()
        let msgURL = URL(string: "sms:\(String(describing: self.mobileNumberLabel.text!))")
           if let url = msgURL, UIApplication.shared.canOpenURL(url) {
           if #available(iOS 10, *) {
               UIApplication.shared.open(url)
           } else {
               UIApplication.shared.openURL(url)
           }
        }
    }
    
    
    @IBAction func favoriteButtonAction(_ sender: Any) {
        contactDetailsVM.editFavoriteContact {(success) in
            if (success) {
                DispatchQueue.main.async {
                    self.favouriteButton.imageView?.image = (self.contactDetailsVM.contactDetails?.favorite == 1) ? UIImage(named: "favourite_button_selected") : UIImage(named: "favourite_button")
                }
            }
        }
    }
    
    
    @IBAction func editButtonAction(_ sender: Any) {
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let editContactVC = mainStoryBoard.instantiateViewController(withIdentifier: "EditContactViewController") as! EditContactViewController
        editContactVC.editContactVM.contactDetails = self.contactDetailsVM.contactDetails!
        editContactVC.editContactVM.isNewContact = false
        self.navigationController?.pushViewController(editContactVC, animated: true)
    }
    
  
    func showDetails() {
        
        if NetworkManager.shared.isConnectedToInternet() {
            self.contactDetailsVM.getContactDetails { (contact) -> (Void) in
                
                DispatchQueue.main.async {
                    self.personImageView.downloadIImage(from: URL(string: baseURL + (contact?.profile_pic)!)!)
                    self.mobileNumberLabel.text = contact?.phone_number
                    self.emailIDLabel.text = contact?.email
                    self.favouriteButton.imageView?.image = (self.contactDetailsVM.contactDetails?.favorite == 1) ? UIImage(named: "favourite_button_selected") : UIImage(named: "favourite_button")
                }
            }
        }
        else {
            self.showNetworkUnavailableAlert()
        }
        
    }
    
    @objc func updateDetails(notification: Notification) {
        let contact = notification.userInfo!["info"] as! Contact
        
        DispatchQueue.main.async {
            self.personImageView.downloadIImage(from: URL(string: baseURL + (contact.profile_pic)!)!)
            self.mobileNumberLabel.text = contact.phone_number
            self.emailIDLabel.text = contact.email
            self.personNameLabel.text = (contact.first_name ?? "") + " " + (contact.last_name ?? "")
        }
    }
}
