//
//  NewHomeViewController.swift
//  myInstagram
//
//  Created by XIN LIU on 1/10/18.
//  Copyright © 2018 XIN LIU. All rights reserved.
//

import UIKit
import Firebase
import TWMessageBarManager
import FirebaseStorageUI
import SDWebImage
import SVProgressHUD

class NewHomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    
    @IBOutlet weak var postTableView: UITableView!
    
    var friendList = [String]()
    var postList = [Post]()
    var postUserName = [String]()
    var postProfileImg = [String]()
    var refreshControll = UIRefreshControl()
    var userInfo = [String : String]()
    var isLike = [Bool]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postTableView.delegate = self
        postTableView.dataSource = self
        fechData()
        
        postTableView.tableFooterView = UIView()
        postTableView.backgroundColor = UIColor.clear
        weak var nc = NotificationCenter.default
        nc?.addObserver(self, selector: #selector(changeFeeds), name: NSNotification.Name(rawValue: "NewFeedAdded"), object : nil)
    }
    
    @objc func changeFeeds(){
        friendList = [String]()
        postList = [Post]()
        postUserName = [String]()
        postProfileImg = [String]()
        DispatchQueue.global().async {
           self.fechData()
        }
        
    }
    
    func fechData(){
       SVProgressHUD.show()
       // let uid = Auth.auth().currentUser?.uid
        AccessFirebase.sharedAccess.getAllPosts(){ (ppost) in
            if let posts = ppost as? [Post]{
                self.postList = posts
                if self.postList.count == 0{
                    SVProgressHUD.dismiss()
                }
                if let friendlist = AccessFirebase.sharedAccess.curUserFriends, let userinfo = AccessFirebase.sharedAccess.curUserInfo{
                    self.friendList = friendlist
                    self.filterPost()
                    //get aresponding userinfo
                    self.userInfo = userinfo
                    self.postUserName = [String]()
                    self.postProfileImg = [String]()
                    self.isLike = [Bool]()
                    self.postTableView.reloadData()
                    SVProgressHUD.dismiss()
                }
            }else{
                SVProgressHUD.dismiss()
            }
        }
    }
    
    func filterPost(){
        self.postList = postList.filter({ friendList.contains($0.userId) || $0.userId == Auth.auth().currentUser?.uid})
        self.postList.sort(by: { ($0.timestamp > $1.timestamp)})
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func AddNewPost(_ sender: Any) {
        if let controller = storyboard?.instantiateViewController(withIdentifier: "AddPostViewController") as? AddPostViewController{
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    //MARK ---> TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.postList.count//self.isLike.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewPostTableViewCell") as? NewPostTableViewCell
        cell?.backgroundColor = UIColor.clear
        let onePost = postList[indexPath.row]
        cell?.profileImgView.layer.cornerRadius = (cell?.profileImgView.frame.size.width)!/2
        cell?.profileImgView.clipsToBounds = true
        //for post in self.postList{
        // print(index)
        AccessFirebase.sharedAccess.getPublicUserInfo2(uid: onePost.userId){(userid, userName, profileImg) in
            if let id = userid as? String{
                if id == onePost.userId{
                    self.postUserName.append(userName as! String)
                    cell?.userNameLabel.text = userName as? String
                    if let profileimg = profileImg as? String{
                        self.postProfileImg.append(profileimg)
                        let url = URL(string : profileimg)
                        cell?.profileImgView.sd_setImage(with: url!, completed: nil)
                    }else{
                        self.postProfileImg.append("")
                        cell?.profileImgView.image = UIImage(named: "defaultProfileImg")
                    }
                    
                    
                    //check like status
                    let uid = Auth.auth().currentUser?.uid; Database.database().reference().child("LikeInfo").child(onePost.postId).child(uid!).observeSingleEvent(of: .value, with: {(snapshot) in
                        if snapshot.value as? Dictionary<String, Any> == nil{
                            self.isLike.append(false)
                        }
                        else{
                            self.isLike.append(true)
                        }
                        DispatchQueue.main.async {
                           // self.postTableView.reloadData()
                            cell?.likeBtn.isSelected = self.isLike[indexPath.row]
                            
                            
                            cell?.likeBtn.tag = indexPath.row
                            cell?.likeBtn.addTarget(self, action: #selector(self.likeAction), for: .touchUpInside)
                            cell?.commentBtn.tag = indexPath.row
                            cell?.commentBtn.addTarget(self, action: #selector(self.commentAction), for: .touchUpInside)
                            cell?.likeCountBtn.tag = indexPath.row
                            cell?.likeCountBtn.addTarget(self, action: #selector(self.showLikeUser), for: .touchUpInside)
                            cell?.btnShowDetail.tag = indexPath.row
                            cell?.btnShowDetail.addTarget(self, action: #selector(self.showUserFeeds), for: .touchUpInside)
                            
                            cell?.descriptionLabel.text = onePost.description
                            let postImgURL = URL(string: onePost.imgURL)
                            cell?.postImgView.sd_setImage(with: postImgURL, completed: nil)
                            
                            let str = String(describing : onePost.numLikes) + " likes"
                            cell?.likeCountBtn.setTitle(str, for: .normal)
                        }
                    })
                    
                }
                
            }
        }
        
        
        return cell!
    }
    
    
    @objc func likeAction(sender : UIButton){
        //check if current user already like this post. if it is unlike it, remove it from list
        //if not like it, add cur user to list
        //
        var onePost = postList[sender.tag]
        let uid = Auth.auth().currentUser?.uid
        //get like list
        AccessFirebase.sharedAccess.getLikeList(pid: onePost.postId){ (result) in
            if var likeInfo = result as? [String : Any]{
                if likeInfo[uid!] != nil{
                    //it contains current user
                    //remove it
                    sender.isSelected = false
                    //upload list
                Database.database().reference().child("LikeInfo").child(onePost.postId).child(uid!).removeValue()
                    self.postList[sender.tag].numLikes -= 1
                    onePost.numLikes -= 1
                    self.isLike[sender.tag] = false
                    TWMessageBarManager.sharedInstance().showMessage(withTitle: "Success", description: "You just unlike this post", type: .info)
                }else{
                    self.addOneLike(sender: sender, uid: uid!)
                }
            }else{
                 self.addOneLike(sender: sender, uid: uid!)
            }
            
            //update post info
            Database.database().reference().child("Posts").child(onePost.postId).updateChildValues(["timeStamp" : onePost.timestamp, "userId" : onePost.userId, "imgURL" : onePost.imgURL, "likeCount" : self.postList[sender.tag].numLikes, "description" :onePost.description, "postId" : onePost.postId])
            
            //reload data
            let indexPath = IndexPath(item: sender.tag, section: 0)
            self.postTableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
            
        }
    }
    
    func addOneLike(sender : UIButton, uid : String){
        var onePost = self.postList[sender.tag]
        sender.isSelected = true
        self.isLike[sender.tag] = true
        onePost.numLikes += 1
        self.postList[sender.tag].numLikes += 1;
        Database.database().reference().child("LikeInfo").child(onePost.postId).updateChildValues([uid : self.userInfo])
        TWMessageBarManager.sharedInstance().showMessage(withTitle: "Success", description: "You just like this post", type: .info)
        
    }
    
    
}
