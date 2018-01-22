//
//  FirstSigninViewController.swift
//  myInstagram
//
//  Created by XIN LIU on 1/7/18.
//  Copyright © 2018 XIN LIU. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth


class FirstSignupViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var emailAddTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnNextAction(_ sender: Any) {
        //pass email address to next view controller
        //email address can not be empty
        //validit email format here
        if let controller = storyboard?.instantiateViewController(withIdentifier: "SecondSignupViewController") as? SecondSignupViewController{
            controller.emailAdd = emailAddTextField.text!
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @IBAction func btnSigninAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailAddTextField.resignFirstResponder()
        return true
    }
}
