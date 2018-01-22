//
//  BtnActions.swift
//  myInstagram
//
//  Created by XIN LIU on 1/11/18.
//  Copyright © 2018 XIN LIU. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import TWMessageBarManager

extension NewHomeViewController{
    @objc func commentAction(sender : UIButton){
        //go to the new view controller, pass the current user info, and post info to the next view
        if let controller = storyboard?.instantiateViewController(withIdentifier: "AddCommentViewController") as? AddCommentViewController{
            controller.curPostInfo = self.postList[sender.tag]
            controller.curUserInfo = self.userInfo
            controller.curPostUserName = self.postUserName[sender.tag]
            controller.curPostUserProfileImg = self.postProfileImg[sender.tag]
            navigationController?.pushViewController(controller, animated: true)
        }
        
    }
    
    
    @objc func showLikeUser(sender : UIButton){
        //go to likes viewcontroller
        if let controller = storyboard?.instantiateViewController(withIdentifier: "LikeInfoViewController") as? LikeInfoViewController{
            controller.postInfo = self.postList[sender.tag]
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @objc func showUserFeeds(sender : UIButton){
        let myStoryBoard : UIStoryboard = UIStoryboard(name: "Reusable", bundle:nil)
        if let controller = myStoryBoard.instantiateViewController(withIdentifier: "PublicFeedsViewController") as? PublicFeedsViewController{
            controller.postsUserId = self.postList[sender.tag].userId
            controller.curUserInfo = self.userInfo
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}

extension PublicFeedsViewController{
    @objc func commentAction(sender : UIButton){
        //go to the new view controller, pass the current user info, and post info to the next view
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let controller = storyboard.instantiateViewController(withIdentifier: "AddCommentViewController") as? AddCommentViewController{
            controller.curPostInfo = self.posts[sender.tag]
            controller.curUserInfo = self.curUserInfo
            controller.curPostUserName = self.postsUserInfo?.username
            controller.curPostUserProfileImg = self.postsUserInfo?.imgUrl
            navigationController?.pushViewController(controller, animated: true)
        }
        
    }
    
    
    @objc func showLikeUser(sender : UIButton){
        //go to likes viewcontroller
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let controller = storyboard.instantiateViewController(withIdentifier: "LikeInfoViewController") as? LikeInfoViewController{
            controller.postInfo = self.posts[sender.tag]
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @objc func likeAction(sender : UIButton){
        //check if current user already like this post. if it is unlike it, remove it from list
        //if not like it, add cur user to list
        //
        var onePost = self.posts[sender.tag]
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
                    self.posts[sender.tag].numLikes -= 1
                    onePost.numLikes -= 1
                    self.isLike[sender.tag] = false
                    TWMessageBarManager.sharedInstance().showMessage(withTitle: "Success", description: "You just unlike this post", type: .info)
                }else{
                    //not contain current user, add user
                    sender.isSelected = true
                    likeInfo[uid!] = self.curUserInfo
                    self.isLike[sender.tag] = true
                    onePost.numLikes += 1
                    self.posts[sender.tag].numLikes += 1;
                    Database.database().reference().child("LikeInfo").child(onePost.postId).updateChildValues(likeInfo)
                    TWMessageBarManager.sharedInstance().showMessage(withTitle: "Success", description: "You just like this post", type: .info)
                    //
                }
            }else{
                //empty like list
                sender.isSelected = true
                self.isLike[sender.tag] = true
                onePost.numLikes += 1
                self.posts[sender.tag].numLikes += 1;
                Database.database().reference().child("LikeInfo").child(onePost.postId).updateChildValues([uid! : self.curUserInfo])
                TWMessageBarManager.sharedInstance().showMessage(withTitle: "Success", description: "You just like this post", type: .info)
                
            }
            
            //update post info
            Database.database().reference().child("Posts").child(onePost.postId).updateChildValues(["timeStamp" : onePost.timestamp, "userId" : onePost.userId, "imgURL" : onePost.imgURL, "likeCount" : onePost.numLikes, "description" :onePost.description, "postId" : onePost.postId])
            
            //reload data
            let indexPath = IndexPath(item: sender.tag, section: 0)
            self.postsTableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
            
            //home page should also change
            //add notification
            let nc = NotificationCenter.default
            let notification = Notification(name: Notification.Name(rawValue: "NewFeedAdded"), object: self)
            nc.post(notification)
        }
    }
}
