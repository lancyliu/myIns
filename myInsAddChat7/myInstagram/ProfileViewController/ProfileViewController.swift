//
//  ProfileViewController.swift
//  myInstagram
//
//  Created by XIN LIU on 1/7/18.
//  Copyright © 2018 XIN LIU. All rights reserved.
//

import UIKit
import Firebase
import TWMessageBarManager
import SDWebImage

//todo--> upload profile photo, edit profile, change password

class ProfileViewController: BaseViewController {

    @IBOutlet weak var numOfPost: UIButton!
    @IBOutlet weak var numOfFriends: UIButton!
    
    @IBOutlet weak var userImgView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var usernameLabel2: UILabel!
    var databaseRef: DatabaseReference?
    var storageRef : StorageReference?
    var refreshControll = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userImgView.layer.cornerRadius = self.userImgView.frame.size.width/2
        self.userImgView.clipsToBounds = true
        databaseRef = Database.database().reference().child("Users")
        storageRef = Storage.storage().reference()
       // showCurUserInfo()
        
        refreshControll.isEnabled = true
        refreshControll.tintColor = UIColor.red
        refreshControll.addTarget(self, action: #selector(refreshAction(_:)), for: .valueChanged)
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showCurUserInfo()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func refreshAction(_ sender : Any){
        showCurUserInfo()
        refreshControll.endRefreshing()
    }
    
    
    @IBAction func btnLogoutAction(_ sender: Any) {
        do{
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
            
        }catch{
            TWMessageBarManager.sharedInstance().showMessage(withTitle: "Error", description: error.localizedDescription, type: .error)
        }
        
    }
    
    
    @IBAction func btnEditProfileAction(_ sender: Any) {
        if let controller = storyboard?.instantiateViewController(withIdentifier: "ChangeProfileViewController") as? ChangeProfileViewController{
            //controller.userDict = self.userDict
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    
    
    @IBAction func addProfileImgAction(_ sender: Any) {
        self.getPicture()
    }
    
    
    @IBAction func btnShowFeeds(_ sender: Any) {
        let myStoryBoard : UIStoryboard = UIStoryboard(name: "Reusable", bundle:nil)
        if let controller = myStoryBoard.instantiateViewController(withIdentifier: "PublicFeedsViewController") as? PublicFeedsViewController{
            controller.postsUserId = (Auth.auth().currentUser?.uid)!
            //controller.curUserInfo = self.userDict
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    
}

extension ProfileViewController{
    //imagePickerController delegate methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        picker.dismiss(animated: true)
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        //show the picture you just choose
        self.userImgView.image = image
        AccessFirebase.sharedAccess.uploadImg(image: self.userImgView.image!)
    }
}

extension ProfileViewController{
    func showCurUserInfo(){
        //if cur user info is nil, get cur user info at first
        if AccessFirebase.sharedAccess.curUserInfo == nil{
            AccessFirebase.sharedAccess.getCurUserInfo(){(res) in
            }
        }
        
        if let userInfo = AccessFirebase.sharedAccess.curUserInfo{
            if let fullname = userInfo["FullName"]{
                self.userNameLabel.text = fullname
            }
            if let username = userInfo["UserName"]{
                self.usernameLabel2.text = username
            }
            if let friends = AccessFirebase.sharedAccess.curUserFriends{
                let count = String(describing : friends.count)
                self.numOfFriends.setTitle(count, for: .normal)
            }else{
                self.numOfFriends.setTitle("0", for: .normal)
            }
           if let postsNum = userInfo["NumPosts"]{
                self.numOfPost.setTitle(postsNum, for: .normal)
            }
            if let imgURL = userInfo["ProfileImgURL"]{
                let url = URL(string: imgURL)
                self.userImgView.sd_setImage(with: url!, completed: nil)
          }
        }
    }
}
