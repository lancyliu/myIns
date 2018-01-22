//
//  AddCommentViewController.swift
//  myInstagram
//
//  Created by XIN LIU on 1/11/18.
//  Copyright © 2018 XIN LIU. All rights reserved.
//

import UIKit
import SDWebImage
import Firebase
import TWMessageBarManager
import SVProgressHUD

//show the post info, and recent 20 comments, then you can add one comment

class AddCommentViewController: UIViewController {

    @IBOutlet weak var curUserProfileImg: UIImageView!
    @IBOutlet weak var newCommentsTextView: UITextView!
    @IBOutlet weak var commentsTableView: UITableView!
    @IBOutlet weak var postUserProfile: UIImageView!
    @IBOutlet weak var postDescription: UITextView!
    
    
    @IBOutlet weak var userInfoView: UIView!
    
    var curPostInfo : Post?
    var curUserInfo : [String:String]?
    var curPostUserName : String?
    var curPostUserProfileImg : String?
    var pid : String?
    var allComments = [Comment]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.commentsTableView.dataSource = self
        self.commentsTableView.delegate = self
        self.newCommentsTextView.delegate = self
        self.commentsTableView.backgroundColor = UIColor.clear
        self.commentsTableView.tableFooterView = UIView()
        self.userInfoView.layer.borderWidth = 3
        self.userInfoView.layer.borderColor = UIColor.darkGray.cgColor
        setUpInfos()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpInfos(){
        SVProgressHUD.show()
        if let url = self.curUserInfo?["ProfileImgURL"]{
            let curUserImgUrl = URL(string :url )
            curUserProfileImg.layer.cornerRadius = (self.curUserProfileImg.frame.size.width)/2
            curUserProfileImg.clipsToBounds = true
            curUserProfileImg.sd_setImage(with: curUserImgUrl!, completed: nil)
        }
        let url = URL(string : self.curPostUserProfileImg!)
        postUserProfile.layer.cornerRadius = (self.postUserProfile.frame.size.width)/2
        postUserProfile.clipsToBounds = true
        postUserProfile.sd_setImage(with: url!, completed: nil)
        postDescription.text = curPostUserName! + ": " + (curPostInfo?.description)!
        pid = self.curPostInfo?.postId
        SVProgressHUD.dismiss()
        getRecentComments()
    }
    
    func getRecentComments(){
        AccessFirebase.sharedAccess.getAllComments(pid: self.pid!){(result) in
            if let comments = result as? [Comment]{
                //filter comments, and sort it by timestamp
                var allComments = comments
                allComments.sort(by: {$0.timestamp < $1.timestamp})
                //only keeps
                self.allComments = allComments
                self.commentsTableView.reloadData()
            }
        }
    }
    
    @IBAction func btnBackAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func btnPostAction(_ sender: Any) {
        let time = (Date().timeIntervalSince1970)
        let userId = Auth.auth().currentUser?.uid
        let key = Database.database().reference().child("Comments").child((curPostInfo?.postId)!).childByAutoId().key
        
        let comment = self.newCommentsTextView.text
        
        Database.database().reference().child("Comments").child((curPostInfo?.postId)!).child(key).updateChildValues(["TimeStamp" : time, "UserId" : userId!, "Content" : comment!, "UserName" : self.curUserInfo!["UserName"]!, "ImgURL" : (self.curUserInfo?["ProfileImgURL"])!, "PostId" : (self.curPostInfo?.postId)!])
        
        TWMessageBarManager.sharedInstance().showMessage(withTitle: "Success", description: "Post a new comment", type: .info)
        
        self.newCommentsTextView.text = ""
        self.getRecentComments()
        
    }
    
}


extension AddCommentViewController : UITableViewDelegate, UITableViewDataSource, UITextViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allComments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTableViewCell") as? CommentTableViewCell
        cell?.backgroundColor = UIColor.clear
        let oneComment = self.allComments[indexPath.row]
        let url = URL(string : oneComment.imgURL)
        cell?.profileImgView.layer.cornerRadius = (cell?.profileImgView.frame.size.width)!/2
        cell?.profileImgView.clipsToBounds = true
        cell?.profileImgView.sd_setImage(with: url!, completed: nil)
        let time = stringFromTimeInterval(interval: oneComment.timestamp)
        cell?.commentLabel.text = oneComment.userName + " write on " + time + ": " + oneComment.content
        return cell!
    }
    
    func stringFromTimeInterval(interval:Double) -> String {
        let date = Date(timeIntervalSince1970: interval)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy hh:mm"
        return dateFormatter.string(from: date)
    
    }
}
