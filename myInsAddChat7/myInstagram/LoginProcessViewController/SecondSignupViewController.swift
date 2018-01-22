//
//  SecondSigninViewController.swift
//  myInstagram
//
//  Created by XIN LIU on 1/7/18.
//  Copyright © 2018 XIN LIU. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import TWMessageBarManager

class SecondSignupViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var fullnameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var userIDTextField: UITextField!
    
    var emailAdd : String?
    var databaseRef: DatabaseReference?
    var storageRef : StorageReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        databaseRef = Database.database().reference().child("Users")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func btnNextAction(_ sender: Any) {
        //asign user id
        //create account on firebase, use emailAdd, and password
        Auth.auth().createUser(withEmail:emailAdd!, password: passwordTextField.text!){
            (user,error) in
            if let err = error{
                print(err.localizedDescription)
            }else{
                if let fireBaseUser = user{
                    let userDict = ["UserId" : fireBaseUser.uid, "FullName" : self.fullnameTextField.text!,"EmailId": self.emailAdd!, "Password" : self.passwordTextField.text!, "UserName" : self.userIDTextField.text!]
                    self.databaseRef?.child(fireBaseUser.uid).updateChildValues(userDict)
                    Database.database().reference().child("Public Users").child(fireBaseUser.uid).updateChildValues(["UserName" : self.userIDTextField.text!, "UserId" : fireBaseUser.uid, "isFriend" : false])
                }
                TWMessageBarManager.sharedInstance().showMessage(withTitle: "Success", description: "sign up successfully", type: .info)
                //go to home page?
                self.gotoHomePage()
                
            }
            
        }
        
    }
    
    
    
    @IBAction func btnBackAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnBactToRootAction(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    //MARK---> Textfield delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == fullnameTextField{
            userIDTextField.becomeFirstResponder()
        }else if textField == userIDTextField{
            //check if user id is unique or not
            if isUnique(userId: textField.text!){
                passwordTextField.becomeFirstResponder()
            }
            
        }else{
            passwordTextField.resignFirstResponder()
        }
        return true
    }
    
}
