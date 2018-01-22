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


class FriendsViewController: BaseViewController{

    
    @IBOutlet weak var friendsTableView: UITableView!
    var databaseRef: DatabaseReference?
    var storageRef : StorageReference?
    
    var userDict = ["UserId" : ""]
    var friendList = [String]()
    var refreshControll = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.friendsTableView.delegate = self
        self.friendsTableView.dataSource = self
        friendsTableView.backgroundColor = UIColor.clear
        //
        databaseRef = Database.database().reference().child("Users")
        storageRef = Storage.storage().reference()
        friendsTableView.tableFooterView = UIView()
        getCurUserInfo()
        refreshControll.isEnabled = true
        refreshControll.tintColor = UIColor.red
        refreshControll.addTarget(self, action: #selector(refreshAction(_:)), for: .valueChanged)
        friendsTableView.addSubview(refreshControll)
        
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func refreshAction(_ sender : Any){
        friendList = [String]()
        getCurUserInfo()
       
    }
    
    func getCurUserInfo(){
        if let userInfo = AccessFirebase.sharedAccess.curUserInfo, let friends = AccessFirebase.sharedAccess.curUserFriends{
            self.userDict = userInfo
            self.friendList = friends
            friendsTableView.reloadData()
            self.refreshControll.endRefreshing()
        }
    }

}

extension FriendsViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendList.count //friendNameList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsTableViewCell") as? AllUsersTableViewCell
        cell?.cellAddFriendBtn.isSelected = false
        cell?.backgroundColor = UIColor.clear
        cell?.showFeedsBtn.tag = indexPath.row
        cell?.showFeedsBtn.addTarget(self, action: #selector(showUserFeeds), for: .touchUpInside)
        let friend = friendList[indexPath.row]
        cell?.cellImgView.layer.cornerRadius = (cell?.cellImgView.frame.size.width)!/2
        cell?.cellImgView.clipsToBounds = true
        cell?.cellAddFriendBtn.tag = indexPath.row
        cell?.cellAddFriendBtn.addTarget(self, action: #selector(btnCheckBtnClicked), for: .touchUpInside)
        AccessFirebase.sharedAccess.getPublicUserInfo(uid: friend){(username, imgurl) in
            if let userName = username as? String{
                cell?.cellUserNameLable.text = userName
            }
            if let imgUrl = imgurl as? String{
                DispatchQueue.main.async {
                    let url = URL(string : imgUrl)
                cell?.cellImgView.sd_setImage(with: url!, completed: nil)
                }
                
            }else{
                DispatchQueue.main.async {
                    cell?.cellImgView.image = UIImage(named: "defaultProfileImg")
                }
            }
            
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
    }
    
    @objc func btnCheckBtnClicked(sender : UIButton){
        sender.isSelected = true
        //delete user//OneFriendDeleted
        friendList.remove(at: sender.tag)
        let curId = Auth.auth().currentUser?.uid
        self.databaseRef?.child(curId!).updateChildValues(["Friends" : self.friendList])
        TWMessageBarManager.sharedInstance().showMessage(withTitle: "Success", description: "Delete a friend", type: .info)
        self.friendsTableView.reloadData()
        //user info changed, update the value
        AccessFirebase.sharedAccess.getCurUserInfo(){ (res) in
            guard res is String else{
                return
            }
            let nc = NotificationCenter.default
            let notification = Notification(name: Notification.Name(rawValue: "NewFeedAdded"))
            nc.post(notification)
        }
    }

}
