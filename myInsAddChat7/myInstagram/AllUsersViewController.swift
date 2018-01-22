//
//  AllFriendsViewController.swift
//  myInstagram
//
//  Created by XIN LIU on 1/8/18.
//  Copyright © 2018 XIN LIU. All rights reserved.
//

import UIKit
import Firebase
import TWMessageBarManager
import FirebaseStorageUI
import SDWebImage


class AllUsersViewController: BaseViewController{

    
    @IBOutlet weak var allUserTableView: UITableView!
    var databaseRef: DatabaseReference?
    var storageRef : StorageReference?
    
    var userDict = ["UserId" : ""]
    var friendList = [String]()
    var allUserList = [[String : Any]]()
    var refreshControll = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.allUserTableView.delegate = self
        self.allUserTableView.dataSource = self
        databaseRef = Database.database().reference().child("Users")
        storageRef = Storage.storage().reference()
        allUserTableView.backgroundColor = UIColor.clear
        allUserTableView.tableFooterView = UIView()
        
        refreshControll.isEnabled = true
        refreshControll.tintColor = UIColor.red
        refreshControll.addTarget(self, action: #selector(refreshAction(_:)), for: .valueChanged)
                allUserTableView.addSubview(refreshControll)
        
        getCurUserInfo()
        getAllUserList()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
        @objc func refreshAction(_ sender : Any){
            friendList = [String]()
            getCurUserInfo()
            getAllUserList()
        }
    
    @objc func showUserFeeds(sender : UIButton){
        let myStoryBoard : UIStoryboard = UIStoryboard(name: "Reusable", bundle:nil)
        if let controller = myStoryBoard.instantiateViewController(withIdentifier: "PublicFeedsViewController") as? PublicFeedsViewController{
            let oneUser = self.allUserList[sender.tag]
            let userId = oneUser["UserId"] as! String
            controller.postsUserId = userId
            controller.curUserInfo = self.userDict
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @objc func btnCheckBtnClicked(sender : UIButton){
        sender.isSelected = true
        //add user to friend list
        
        if let newUserid = allUserList[sender.tag]["UserId"] as? String{
            if !friendList.contains(newUserid){
                friendList.append(newUserid)
                let curId = Auth.auth().currentUser?.uid
                self.databaseRef?.child(curId!).updateChildValues(["Friends" : self.friendList])
                TWMessageBarManager.sharedInstance().showMessage(withTitle: "Success", description: "You just add a new friend", type: .info)
               
                AccessFirebase.sharedAccess.getCurUserInfo(){ (res) in
                    guard res is String else{
                        return
                    }
                    let nc = NotificationCenter.default
                    let notification = Notification(name: Notification.Name(rawValue: "NewFeedAdded"), object: self)
                    nc.post(notification)
//                    
                }
            }
        }
    }
}


extension AllUsersViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allUserList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AllUsersTableViewCell") as? AllUsersTableViewCell
        //cell?.cellUserNameLable
        cell?.showFeedsBtn.tag = indexPath.row
        cell?.showFeedsBtn.addTarget(self, action: #selector(showUserFeeds), for: .touchUpInside)
        cell?.cellImgView.layer.cornerRadius = (cell?.cellImgView.frame.size.width)!/2
        cell?.cellImgView.clipsToBounds = true
        cell?.cellImgView.image = UIImage(named : "defaultProfileImg")
        cell?.backgroundColor = UIColor.clear
        cell?.cellAddFriendBtn.tag = indexPath.row
        cell?.cellAddFriendBtn.addTarget(self, action: #selector(btnCheckBtnClicked), for: .touchUpInside)
        let oneUser = self.allUserList[indexPath.row]
        let userId = oneUser["UserId"] as! String
        if userId == Auth.auth().currentUser?.uid{
            cell?.cellUserNameLable.text = "You"
            //cell?.cellAddFriendBtn.isEnabled = true
            cell?.cellAddFriendBtn.isHighlighted = true
            cell?.cellAddFriendBtn.setImage(UIImage(), for: .normal)
            
        }else{
            if let username = oneUser["UserName"] as? String{
                cell?.cellUserNameLable.text = username
            }
            if self.friendList.contains(userId){
                cell?.cellAddFriendBtn.isSelected = true
            }else{
                cell?.cellAddFriendBtn.isSelected = false
            }
        }
        
        if let imgUrl = oneUser["ProfileImgURL"] as? String{
            let url = URL(string: imgUrl)
            cell?.cellImgView.sd_setImage(with: url, completed: nil)
        }
        
        return cell!
    }
}
