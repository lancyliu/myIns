//
//  PublicFeedsViewController.swift
//  myInstagram
//
//  Created by XIN LIU on 1/13/18.
//  Copyright © 2018 XIN LIU. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class PublicFeedsViewController: UIViewController {

    
    @IBOutlet weak var numOfFriends: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var numOfPost: UILabel!
    @IBOutlet weak var postsTableView: UITableView!
    
    var postsUserId : String?
    var postsUserInfo : UserInfo?
    var posts = [Post]()
    var isLike = [Bool]()
    var curUserInfo = [String: String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postsTableView.delegate = self
        postsTableView.dataSource = self
        postsTableView.backgroundColor = UIColor.clear
        postsTableView.tableFooterView = UIView()
        
        /*
         get current userinfo, show it, add notification observers
         */
        
        setUpUserInfo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func btnBackAction(_ sender: Any) {
        
        navigationController?.popViewController(animated: true)
    }
    
    func setUpUserInfo(){
        if AccessFirebase.sharedAccess.curUserInfo == nil{
            AccessFirebase.sharedAccess.getCurUserInfo(){ (res) in
                
            }
        }
        if let userInfo = AccessFirebase.sharedAccess.curUserInfo{
            curUserInfo = userInfo
        }
        
        DispatchQueue.global().async {
            if let uid = self.postsUserId{
                AccessFirebase.sharedAccess.getUserInfo(uid: uid){ (userdict, friendlist, postlist) in
                    if let userDict = userdict as? [String : String], let friendList = friendlist as? [String]{
                        
                        //show userinfo
                        if let userName = userDict["UserName"], let imgurl = userDict["ProfileImgURL"]{
                            self.postsUserInfo = UserInfo(uname: userName, id: uid, url: imgurl)
                            
                            DispatchQueue.main.async {
                                self.userNameLabel.text = userName
                                let count = String(describing : friendList.count)
                                if let numPost = userDict["NumPosts"] {
                                    self.numOfPost.text =  numPost
                                    self.numOfFriends.text = count
                                }
                                let url = URL(string: imgurl)
                                self.profileImgView.layer.cornerRadius = self.profileImgView.frame.width/2
                                self.profileImgView.clipsToBounds = true
                                self.profileImgView.sd_setImage(with: url, completed: nil)
                            }
                        }
                        
                        //show posts info
                        //move it to tableview
                        if let postList1 = postlist as? [String : String]{
                            for item in postList1{
                                Database.database().reference().child("Posts").child(item.key).observeSingleEvent(of: .value, with: {(snapshot) in
                                    if let dict = snapshot.value as? Dictionary<String,Any>{
                                        let userId = dict["userId"] as! String
                                        let imgurl = dict["imgURL"] as! String
                                        let time = dict["timeStamp"] as! Double
                                        let num = dict["likeCount"] as! Int
                                        let postId = dict["postId"] as! String
                                        let description = dict["description"] as! String
                                        let onePost = Post(timestamp: time, userId: userId, imgURL: imgurl, numLikes: num, description: description, postId : postId)
                                        self.posts.append(onePost)
                                        
                                        if(self.posts.count == postList1.count){
                                            self.posts.sort(by: { ($0.timestamp > $1.timestamp)})
                                            for element in self.posts{
                                                Database.database().reference().child("LikeInfo").child(element.postId
                                                    ).child((Auth.auth().currentUser?.uid)!).observeSingleEvent(of: .value, with: {(snapshot) in
                                                        if snapshot.value as? Dictionary<String, Any> == nil{
                                                            self.isLike.append(false)
                                                        }
                                                        else{
                                                            self.isLike.append(true)
                                                        }
                                                        if(self.isLike.count == postList1.count){
                                                            
                                                            DispatchQueue.main.async {
                                                                self.postsTableView.reloadData()
                                                            }
                                                        }
                                                    })

                                            }
                                            
                                        }
                                        //like info
                                    }
                                })
                            }
                        }
                    }
                }
            }
        }
        
    }

}

extension PublicFeedsViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PublicFeedCell") as? NewPostTableViewCell
        cell?.backgroundColor = UIColor.clear
        let onePost = self.posts[indexPath.row]
        cell?.likeBtn.isSelected = self.isLike[indexPath.row]
        cell?.likeBtn.tag = indexPath.row
        cell?.likeBtn.addTarget(self, action: #selector(likeAction), for: .touchUpInside)
        cell?.commentBtn.tag = indexPath.row
        cell?.commentBtn.addTarget(self, action: #selector(commentAction), for: .touchUpInside)
        cell?.likeCountBtn.tag = indexPath.row
        cell?.likeCountBtn.addTarget(self, action: #selector(showLikeUser), for: .touchUpInside)
     
        cell?.descriptionLabel.text = onePost.description
        let postImgURL = URL(string: onePost.imgURL)
        cell?.postImgView.sd_setImage(with: postImgURL, completed: nil)
        cell?.userNameLabel.text = self.postsUserInfo?.username
        let profileImgURL = URL(string: (self.postsUserInfo?.imgUrl)!)
        cell?.profileImgView.layer.cornerRadius = (cell?.profileImgView.frame.size.width)!/2
        cell?.profileImgView.clipsToBounds = true
       if (self.postsUserInfo?.imgUrl)! == ""{
            cell?.profileImgView.image = UIImage(named: "defaultProfileImg")
        }else{
            cell?.profileImgView.sd_setImage(with: profileImgURL, completed: nil)
        }
        let str = String(describing : onePost.numLikes) + " likes"
        cell?.likeCountBtn.setTitle(str, for: .normal)
        return cell!
    }
    
    
}
