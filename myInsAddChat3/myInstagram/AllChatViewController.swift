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
    var friendNameList  = [String]()
    var allUserList = [[String : Any]]()
    var friendImgList = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

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
    
}

extension AllChatViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendNameList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsTableViewCell") as? AllUsersTableViewCell
        cell?.backgroundColor = UIColor.clear
        cell?.cellUserNameLable.text = friendNameList[indexPath.row]
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //friend id
        let friend = self.friendList[indexPath.row]
        let friendName = self.friendNameList[indexPath.row]
        let friendImg = self.friendImgList[indexPath.row]
        
        let myStoryBoard : UIStoryboard = UIStoryboard(name: "Reusable", bundle:nil)
        if let controller = myStoryBoard.instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController{
            controller.receiverId = friend
            controller.receiverInfo = UserInfo(username: friendName, userId: friend, imgUrl: friendImg)
            controller.curUserInfo = UserInfo(username: userDict["UserName"]!, userId: userDict["UserId"]!, imgUrl: userDict["ProfileImgURL"]!)
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}
