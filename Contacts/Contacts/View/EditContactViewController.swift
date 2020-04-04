//
//  EditContactViewController.swift
//  Contacts
//
//  Created by Somenath on 19/03/20.
//  Copyright © 2020 Somenath. All rights reserved.
//

import UIKit

class EditContactViewController: UIViewController {


    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var mobileTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var personImageView: UIImageView!
    @IBOutlet weak var topView: UIView!
    
    var editContactVM = EditContactViewModel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.personImageView.layer.cornerRadius = self.personImageView.frame.width/2
        self.personImageView.layer.borderWidth = 3
        self.personImageView.layer.borderColor = UIColor.white.cgColor

        // Do any additional setup after loading the view.
        self.firstNameTextField.delegate = self
        self.lastNameTextField.delegate = self
        self.mobileTextField.delegate = self
        self.emailTextField.delegate = self
        
        showDetails()
        let colorTop = UIColor.white
        let colorBottom = UIColor(red: 80.0/255.0, green: 227.0/255.0, blue: 192.0/255.5, alpha: 0.28)
        self.topView.setGradientBackground(colorTop: colorTop, colorBottom: colorBottom)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
       
    }
    
    func showDetails() {
       self.firstNameTextField.text = self.editContactVM.contactDetails.first_name
       self.lastNameTextField.text = self.editContactVM.contactDetails.last_name
       self.mobileTextField.text = self.editContactVM.contactDetails.phone_number
       self.emailTextField.text = self.editContactVM.contactDetails.email
       self.personImageView.downloadIImage(from: URL(string: baseURL + self.editContactVM.contactDetails.profile_pic!)!)
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func doneButtonAction(_ sender: Any) {
        editContactVM.edittedContact["phone_number"] = self.mobileTextField.text
        editContactVM.edittedContact["email"] = self.emailTextField.text
        editContactVM.edittedContact["first_name"] = self.firstNameTextField.text
        editContactVM.edittedContact["last_name"] = self.lastNameTextField.text
        
        if (self.mobileTextField.text == "" || self.emailTextField.text == "" || self.firstNameTextField.text == "" || self.lastNameTextField.text == "") {
            self.showEmptyFieldAlert()
            return
        }
        
        if NetworkManager.shared.isConnectedToInternet() {
            editContactVM.updateContactDetails { (success) in
                if(success) {
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                else {
                    DispatchQueue.main.async {
                        var errorMessage = ""
                        for error in ContactManager.shared.errors {
                            errorMessage += error + "\n"
                        }
                        
                        let alertController = UIAlertController(title: "Oops!", message: errorMessage, preferredStyle: .alert)
                        let dismiss = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        alertController.addAction(dismiss)
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        }
        else {
            self.showNetworkUnavailableAlert()
        }
        
    }
    
    @IBAction func cameraButtonAction(_ sender: Any) {
        self.showActionSheet()
    }

}

extension EditContactViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == self.mobileTextField {
            textField.keyboardType = .phonePad
            
        }
        else if textField == self.emailTextField {
            textField.keyboardType = .emailAddress
        }
        else {
            textField.keyboardType = .default
        }

    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}



extension EditContactViewController {
    
    func camera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self;
            myPickerController.sourceType = .camera
            self.present(myPickerController, animated: true, completion: nil)
        }
        
    }
    func photoLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self;
            myPickerController.sourceType = .photoLibrary
            self.present(myPickerController, animated: true, completion: nil)
        }
    }
    
    func showActionSheet() {
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (alert:UIAlertAction!) -> Void in
            self.camera()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { (alert:UIAlertAction!) -> Void in
            self.photoLibrary()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
}


extension EditContactViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.personImageView.image = image
        }else{
            print("Something went wrong")
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
