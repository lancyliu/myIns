//
//  AllChatViewController.swift
//  myInstagram
//
//  Created by XIN LIU on 1/16/18.
//  Copyright © 2018 XIN LIU. All rights reserved.
//

import UIKit
import Firebase
import TWMessageBarManager
import SDWebImage



class AllChatViewController: UIViewController {

    
    @IBOutlet weak var friendsTableView: UITableView!
    var databaseRef: DatabaseReference?
    var storageRef : StorageReference?
    
    var userDict = ["UserId" : ""]
    var friendList = [String]()
    var refreshControll = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        friendsTableView.delegate = self
        friendsTableView.dataSource = self
        friendsTableView.backgroundColor = UIColor.clear
        //
        databaseRef = Database.database().reference().child("Users")
        storageRef = Storage.storage().reference()
        getCurUserInfo()
        
        refreshControll.isEnabled = true
        refreshControll.tintColor = UIColor.red
        refreshControll.addTarget(self, action: #selector(refreshAction(_:)), for: .valueChanged)
        friendsTableView.addSubview(refreshControll)
        
        friendsTableView.tableFooterView = UIView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func refreshAction(_ sender : Any){
        friendList = [String]()
        getCurUserInfo()
        self.refreshControll.endRefreshing()
    }
    
    func getCurUserInfo(){
        if let userInfo = AccessFirebase.sharedAccess.curUserInfo, let friends = AccessFirebase.sharedAccess.curUserFriends{
            userDict = userInfo
            friendList = friends
            friendsTableView.reloadData()
            
        }
    }
    
}

extension AllChatViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsTableViewCell") as? AllUsersTableViewCell
        cell?.backgroundColor = UIColor.clear
        cell?.cellImgView.layer.cornerRadius = (cell?.cellImgView.frame.size.width)!/2
        cell?.cellImgView.clipsToBounds = true
        let friend = friendList[indexPath.row]
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //friend id
        let friend = self.friendList[indexPath.row]
        gotoChatPage(receivId: friend)
    }
    
    func gotoChatPage(receivId : String){
        let myStoryBoard : UIStoryboard = UIStoryboard(name: "Reusable", bundle:nil)
        if let controller = myStoryBoard.instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController{
            controller.receiverId = receivId
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}
