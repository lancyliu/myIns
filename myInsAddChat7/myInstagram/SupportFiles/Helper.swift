//
//  File.swift
//  myInstagram
//
//  Created by XIN LIU on 1/8/18.
//  Copyright © 2018 XIN LIU. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseStorage
import FBSDKLoginKit
import FBSDKCoreKit
import SDWebImage

extension ChangeProfileViewController : UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
       return  3
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genderOption[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.userDict["Gender"] = self.genderOption[row]
        self.pickerViewHeight.constant = 0
        self.profileTableView.reloadData()
    }
}

extension ChangeProfileViewController : UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contents.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell") as? ProfileTableViewCell
        let content = contents[indexPath.row]
        cell?.cellLable.text = content
        cell?.cellTextField.delegate = self
        if !isEdit{
            
            if let text = userDict[content]{
                cell?.cellTextField.text = text
            }else{
                cell?.cellTextField.placeholder = content
            }
        }else{
            if let text = cell?.cellTextField.text{
                if text != ""{
                    tempUserDict[content] = cell?.cellTextField.text
                }
            }
            
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == self.contents.count-1{
            //gender
            //show picker view
            self.pickerViewHeight.constant = 60
        }
    }
 
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.isEdit = true
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.profileTableView.reloadData()
        return true
    }
}

extension AllUsersViewController{
    func getCurUserInfo(){
        if let userInfo = AccessFirebase.sharedAccess.curUserInfo, let friends = AccessFirebase.sharedAccess.curUserFriends{
            self.userDict = userInfo
            self.friendList = friends
        }
    }

    
    
    func getAllUserList(){
        Database.database().reference().child("Public Users").observeSingleEvent(of: .value, with: {(snapshot) in
            guard let value = snapshot.value as? Dictionary<String,Any> else{
                        return
                }
          //  print(value)
            var arrofDict = [[String: Any]]()
            for item in value{
                if let dict = item.value as? Dictionary<String,Any>{
                    arrofDict.append(dict)
                }
            }
            self.allUserList = arrofDict
            self.allUserTableView.reloadData()
            self.refreshControll.endRefreshing()
        })
    }
}


extension LoginViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailAddTextField{
            passwordTextField.becomeFirstResponder()
        }else{
            passwordTextField.resignFirstResponder()
        }
        return true
    }
    
    func showCurUserInfo(){
        if (Auth.auth().currentUser?.uid) != nil{
            AccessFirebase.sharedAccess.getCurUserInfo(){(res) in
                if let result = res as? String{
                    if result == "success"{
                        
                        if let email = AccessFirebase.sharedAccess.curUserInfo?["EmailId"]{
                            self.emailAddTextField.text = email
                            
                        }
                        if let passW = AccessFirebase.sharedAccess.curUserInfo?["Password"]{
                            self.passwordTextField.text = passW
                        }
                        
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
    
    func getFBUserData(fireBaseUser : User){
        if((FBSDKAccessToken.current()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    //everything works print the user data
                    // print(result)
                    if let dict = result as? [String : AnyObject]{
                        
                        if let email = dict["email"] as? String{
                            self.emailAddTextField.text = email
                        }
                        if let name = dict["name"] as? String{
                            self.fullname = name
                        }
                        let userDict = ["UserId" : fireBaseUser.uid, "FullName" : self.fullname ,"EmailId": self.emailAddTextField.text!, "UserName" : self.fullname]
                        self.databaseRef?.child(fireBaseUser.uid).updateChildValues(userDict)
                        //save info to public user
                        Database.database().reference().child("Public Users").child(fireBaseUser.uid).updateChildValues(["UserName" : self.fullname, "isFriend" : false, "UserId" : fireBaseUser.uid])
                        if let picDict = dict["picture"] as? [String:Any]{
                            if let pic = picDict["data"] as? [String:Any]{
                                let path = pic["url"] as! String
                                DispatchQueue.global().async {
                                    let img1 = Downloader.downloadImageWithURL(url: path)
                                    //upload img1 to storage
                                    AccessFirebase.sharedAccess.uploadImg(image: img1!)
                                    //self.uploadImg(image: img1!)
                                }
                            }
                        }
                        
                    }
                }
                else{
                    print((error?.localizedDescription)!)
                }
            })
        }
    }
}

extension SecondSignupViewController{
    func isUnique(userId: String) -> Bool{
        return true
    }
}
