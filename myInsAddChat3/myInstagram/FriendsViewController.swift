//
//  FriendsViewController.swift
//  myInstagram
//
//  Created by XIN LIU on 1/8/18.
//  Copyright © 2018 XIN LIU. All rights reserved.
//

import UIKit
import Firebase
import TWMessageBarManager
import SDWebImage


class FriendsViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource{

    
    @IBOutlet weak var friendsTableView: UITableView!
    var databaseRef: DatabaseReference?
    var storageRef : StorageReference?
    
    var userDict = ["UserId" : ""]
    var friendList = [String]()
    var friendNameList  = [String]()
    var allUserList = [[String : Any]]()
    var friendImgList = [String]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.friendsTableView.delegate = self
        self.friendsTableView.dataSource = self
        friendsTableView.backgroundColor = UIColor.clear
        //
        databaseRef = Database.database().reference().child("Users")
        storageRef = Storage.storage().reference()
        
        self.getCurUserInfo()
        //self.friendsTableView.reloadData()
        friendsTableView.tableFooterView = UIView()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendNameList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsTableViewCell") as? AllUsersTableViewCell
        cell?.cellAddFriendBtn.isSelected = false
        cell?.backgroundColor = UIColor.clear
       // let friendId = friendList[indexPath.row]
        cell?.showFeedsBtn.tag = indexPath.row
        cell?.showFeedsBtn.addTarget(self, action: #selector(showUserFeeds), for: .touchUpInside)
        cell?.cellUserNameLable.text = friendNameList[indexPath.row]
        cell?.cellAddFriendBtn.tag = indexPath.row
        cell?.cellAddFriendBtn.addTarget(self, action: #selector(btnCheckBtnClicked), for: .touchUpInside)
        cell?.cellImgView.layer.cornerRadius = (cell?.cellImgView.frame.size.width)!/2
        cell?.cellImgView.clipsToBounds = true
        
        let imgUrl = self.friendImgList[indexPath.row]
        if imgUrl == ""{
            cell?.cellImgView.image = UIImage(named : "defaultProfileImg")
        }else{
            let url = URL(string: imgUrl)
            cell?.cellImgView.sd_setImage(with: url, completed: nil)
        }
        return cell!
    }
    
    @objc func showUserFeeds(sender : UIButton){
        let myStoryBoard : UIStoryboard = UIStoryboard(name: "Reusable", bundle:nil)
        if let controller = myStoryBoard.instantiateViewController(withIdentifier: "PublicFeedsViewController") as? PublicFeedsViewController{
            let userId = self.friendList[sender.tag]
            controller.postsUserId = userId
            controller.curUserInfo = self.userDict
            navigationController?.pushViewController(controller, animated: true)
        }
//        let userId = self.friendList[sender.tag]
//        self.sendMsg(uid: userId)
    }
    
//    func sendMsg(uid : String){
//        print(uid)
//        let notificationkey = Database.database().reference().child("notificationRequests").childByAutoId().key
//
//        //make the dictionary
//        let dict = ["username" : uid, "message" : "Test Msg"]
//        //let notifyupdate = ["/notificationRequests/\(notificationkey)" : dict]
//        Database.database().reference().child("notificationRequests").child(notificationkey).updateChildValues(dict)
//       // Database.database().reference().updateChildValues(notifyupdate)
//
//    }
    
    func getCurUserInfo(){
        
        if let user = Auth.auth().currentUser{
            AccessFirebase.sharedAccess.getUserInfo(uid: user.uid){ (userDict, friendList, postlist) in
                self.userDict = userDict as! [String : String]
                self.friendList = friendList as! [String]
                self.friendNameList = [String]()
                self.friendImgList = [String]()
                for friend in self.friendList{
                    self.getUserName(userid: friend)
                }
                
            }
            
        }
    }
    
    func getUserName(userid : String){
        AccessFirebase.sharedAccess.getPublicUserInfo(uid: userid){(username, imgurl) in
            if let userName = username as? String{
                self.friendNameList.append(userName)
            }
            if let imgUrl = imgurl as? String{
                self.friendImgList.append(imgUrl)
                DispatchQueue.main.async {
                    self.friendsTableView.reloadData()
                }
                
            }else{
                self.friendImgList.append("")
                DispatchQueue.main.async {
                    self.friendsTableView.reloadData()
                }
            }
            
        }
    }
    
    @objc func btnCheckBtnClicked(sender : UIButton){
        sender.isSelected = true
            //delete user//OneFriendDeleted
        let deleteUserid = friendList[sender.tag]
        let deletename = friendNameList[sender.tag]
        friendList.remove(at: sender.tag)
        friendNameList.remove(at: sender.tag)
        friendImgList.remove(at: sender.tag)
        let curId = Auth.auth().currentUser?.uid
        self.databaseRef?.child(curId!).updateChildValues(["Friends" : self.friendList])
        TWMessageBarManager.sharedInstance().showMessage(withTitle: "Success", description: "Delete a friend \(deletename)", type: .info)
        self.friendsTableView.reloadData()
        let nc = NotificationCenter.default
        let notification = Notification(name: Notification.Name(rawValue: "NewFeedAdded"))
        nc.post(notification)
    }
    

}
