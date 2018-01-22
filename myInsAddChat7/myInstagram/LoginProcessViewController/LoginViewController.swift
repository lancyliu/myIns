//
//  ViewController.swift
//  myInstagram
//
//  Created by XIN LIU on 1/6/18.
//  Copyright © 2018 XIN LIU. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import FBSDKLoginKit
import FBSDKCoreKit

class LoginViewController: BaseViewController{

    
    @IBOutlet weak var emailAddTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var databaseRef : DatabaseReference?
    var storageRef : StorageReference?
    var fullname : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //check current user, if already have an account, directly login
        hideKeyboardWhenTappedAround()
        databaseRef = Database.database().reference().child("Users")
        storageRef = Storage.storage().reference()
        showCurUserInfo()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func btnLoginAction(_ sender: Any) {
        Auth.auth().signIn(withEmail: emailAddTextField.text!, password: passwordTextField.text!){(user,error) in
            if let err = error{
                print(err.localizedDescription)
            }else{
                //subscript the message topic
                if let uid = Auth.auth().currentUser?.uid{
                    Messaging.messaging().subscribe(toTopic: uid)
                }
                self.passwordTextField.text = ""
                //load curUserInfo
                AccessFirebase.sharedAccess.getCurUserInfo(){(res) in
                    if let result = res as? String{
                        if result == "success"{
                            //go to main screen
                            self.gotoHomePage()
                        }else{
                            print("Login error")
                        }
                    }else{
                        print("Login error")
                    }
                    
                }
                
            }
        }
    }
    
    
    @IBAction func btnFBLoginAction(_ sender: Any) {
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["email", "public_profile"], from: self) { (result, error) -> Void in
            if (error == nil){
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
                // if user cancel the login
                if (result?.isCancelled)!{
                    return
                }
                if(fbloginresult.grantedPermissions.contains("email"))
                {
                    //if this is the first time login, upload the data to database
                    //if not, just login
                    
                    let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                    Auth.auth().signIn(with: credential) { (user, error) in
                        if let error = error {
                            print(error.localizedDescription)
                            return
                        }
                    
                        self.databaseRef?.child((user?.uid)!).observeSingleEvent(of : .value, with:{(snapshot) in
                        if (snapshot.value as? Dictionary<String, Any>) == nil{
                            //save the info to database
                            if let fireBaseUser = user{
                                self.getFBUserData(fireBaseUser : fireBaseUser)
                                AccessFirebase.sharedAccess.getCurUserInfo(){(res) in
                                    if let result = res as? String{
                                        if result == "success"{
                                            //go to main screen
                                            self.gotoHomePage()
                                        }else{
                                            print("Login error")
                                        }
                                    }else{
                                        print("Login error")
                                    }
                                    
                                }
                            }
                        }
                        else{
                            //read userinfo to singleton class, then go to main screen
                            AccessFirebase.sharedAccess.getCurUserInfo(){(res) in
                                if let result = res as? String{
                                    if result == "success"{
                                        //go to main screen
                                        self.gotoHomePage()
                                    }else{
                                        print("Login error")
                                    }
                                }else{
                                    print("Login error")
                                }
                                
                            }
                        }
                        })
                    }
                    
                }
                
            }
        }
    }
    
    
    @IBAction func btnSignupAction(_ sender: Any) {
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "FirstSignupViewController") as? FirstSignupViewController{
           // controller.title = "First Signup Page"
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
}



