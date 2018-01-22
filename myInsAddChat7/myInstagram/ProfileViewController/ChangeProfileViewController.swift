//
//  ChangeProfileViewController.swift
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

/*
 Edit Profile, gender should be picker
 */

class ChangeProfileViewController: BaseViewController{
    
    @IBOutlet weak var genderPickerView: UIPickerView!
    
    @IBOutlet weak var pickerViewHeight: NSLayoutConstraint!
    
    var databaseRef: DatabaseReference?
    var storageRef : StorageReference?
    var userDict = ["UserId" : ""]
    var tempUserDict = ["FullName" : ""]
    let genderOption = ["Female", "Male", "Not Specified"]
    let contents = ["FullName", "UserName","Website","Bio",  "EmailId", "Phone", "Gender"]
    @IBOutlet weak var profileTableView: UITableView!
    var isEdit = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        databaseRef = Database.database().reference().child("Users")
        storageRef = Storage.storage().reference()
        
        if AccessFirebase.sharedAccess.curUserInfo == nil{
            AccessFirebase.sharedAccess.getCurUserInfo(){(res) in 
                
            }
        }
        if let userInfo = AccessFirebase.sharedAccess.curUserInfo{
            userDict = userInfo
        }
        
        genderPickerView.delegate = self
        genderPickerView.dataSource = self
        profileTableView.delegate = self
        profileTableView.dataSource = self
        profileTableView.reloadData()
        pickerViewHeight.constant = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func btnCancelAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnResetPassword(_ sender: Any) {
        if let user = Auth.auth().currentUser{
            self.databaseRef?.child(user.uid).observeSingleEvent(of: .value, with : {(snapshot) in
                guard let value = snapshot.value as? Dictionary<String,Any> else{
                    return
                }
                if let strEmail = value["EmailId"] as? String{
                    Auth.auth().sendPasswordReset(withEmail: strEmail){ (error) in
                        if let err = error{
                            TWMessageBarManager.sharedInstance().showMessage(withTitle: "Sorry", description: err.localizedDescription, type: .error)
                        }else{
                            TWMessageBarManager.sharedInstance().showMessage(withTitle: "Success", description: "An email already send to you" , type: .error)
                        }
                        
                    }
                }
            })
            
        }
    }
    
    

    @IBAction func btnDoneAction(_ sender: Any) {
        
        //upload to database
        profileTableView.reloadData()
        userDict = tempUserDict
        if let user = Auth.auth().currentUser{
            self.databaseRef?.child(user.uid).updateChildValues(userDict)
        }
        
    }
}
