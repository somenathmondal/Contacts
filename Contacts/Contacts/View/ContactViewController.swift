//
//  ContactViewController.swift
//  Contacts
//
//  Created by Somenath on 17/03/20.
//  Copyright © 2020 Somenath. All rights reserved.
//

import UIKit

class ContactViewController: UIViewController {

    @IBOutlet weak var contactTableView: UITableView!
    
    @IBOutlet weak var noInternetView: UIView!
    
    let contactViewModel = ContactViewModel()
    let nc = NotificationCenter.default
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.configureContactTableView()
        
        DispatchQueue.global().async {
            if NetworkManager.shared.isConnectedToInternet() {
                self.contactViewModel.getAllContacts { (contactList) in
                    DispatchQueue.main.async {
                        self.contactTableView.reloadData()
                    }
                }
            }
            else {
                DispatchQueue.main.async {
                    self.navigationController?.navigationBar.isHidden = true
                    self.noInternetView.isHidden = false
                    self.showNetworkUnavailableAlert()
                }
            }
            
        }
        nc.addObserver(self, selector: #selector(updateCell(notification:)), name: Notification.Name(rawValue: "ContactUpdated"), object: nil)
        nc.addObserver(self, selector: #selector(updateCell(notification:)), name: Notification.Name(rawValue: "ContactAdded"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         self.contactTableView.reloadData()
    }
    
    func configureContactTableView() {
        
        self.contactTableView.register(UINib(nibName: "ContactTableViewCell", bundle: nil), forCellReuseIdentifier: "contactCell")
        
        self.contactTableView.delegate = self
        self.contactTableView.dataSource = self
        self.contactTableView.sectionIndexColor = UIColor.gray
    }

    @objc func updateCell(notification: Notification) {
        //let contact = notification.userInfo!["info"] as! Contact
        
        DispatchQueue.main.async {
            self.contactTableView.reloadData()
        }
    }
    
    @IBAction func addNewContactButtonAction(_ sender: Any) {
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let editContactVC = mainStoryBoard.instantiateViewController(withIdentifier: "EditContactViewController") as! EditContactViewController
        editContactVC.editContactVM.contactDetails = Contact()
        editContactVC.editContactVM.isNewContact = true
        self.navigationController?.pushViewController(editContactVC, animated: true)
    }
    
    
}

extension ContactViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: TableView - Delegate, Datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contactViewModel.getContactArrayForSection(sec: section).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath) as! ContactTableViewCell
        let contact = self.contactViewModel.getContactArrayForSection(sec: indexPath.section)[indexPath.row]
        cell.personNameLabel.text = (contact.first_name ?? "") + " " + (contact.last_name ?? "")
        cell.favoriteImgView.isHidden = (contact.favorite == 1) ? false : true
        cell.photoImgView.downloadIImage(from: URL(string: baseURL + contact.profile_pic!)!)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let contactDetailsVC = mainStoryBoard.instantiateViewController(withIdentifier: "ContactDetailsViewController") as! ContactDetailsViewController
        contactDetailsVC.contactDetailsVM.contactDetails = self.contactViewModel.getContactArrayForSection(sec: indexPath.section)[indexPath.row]
        self.navigationController?.pushViewController(contactDetailsVC, animated: true)
    }
    
    
    // MARK: - TableView Sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionArray.count
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sectionArray
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionArray[section]
    }
    
    
    //MARK:- Delete Cells
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let contact = self.contactViewModel.getContactArrayForSection(sec: indexPath.section)[indexPath.row]
            ContactManager.shared.removeContactFromArray(contactToDelete: contact)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
}
