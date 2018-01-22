//
//  AccessFirebase.swift
//  myInstagram
//
//  Created by XIN LIU on 1/9/18.
//  Copyright © 2018 XIN LIU. All rights reserved.
//

import Foundation
import UIKit
import Firebase

typealias completionHandler = (Any, Any) ->()
typealias completionHandler2 = (Any) ->()
typealias completionHandler3 = (Any, Any, Any) ->()
enum FirebaseError : Error{
    case ReadDatabaseFailed
    case ReadStorageFailed
}

class AccessFirebase : NSObject{
    
    private override init(){}
    static let sharedAccess = AccessFirebase()
    
    var databaseRef: DatabaseReference = Database.database().reference().child("Users")
    var storageRef : StorageReference = Storage.storage().reference()
    var curUserInfo : [String : String]?
    var curUserFriends : [String]?
   // var curUserPosts : [String : String]?
    
    func getCurUserInfo(completion : @escaping completionHandler2){
        curUserInfo = [String : String]()
        curUserFriends = [String]()
      //  curUserPosts = [String : String]()
        
        let uid = Auth.auth().currentUser?.uid
        databaseRef.child(uid!).observeSingleEvent(of: .value, with : {(snapshot) in
            guard let value = snapshot.value as? Dictionary<String,Any> else{
                completion("error")
                return
            }
            if let fullname = value["FullName"] as? String{
                self.curUserInfo!["FullName"] = fullname
            }
            if let userid = value["UserId"] as? String{
                self.curUserInfo!["UserId"] = userid
            }
            if let username = value["UserName"] as? String{
                self.curUserInfo!["UserName"] = username
            }
            if let friends = value["Friends"] as? [String]{
                self.curUserFriends = friends
                
            }else{
                self.curUserFriends = [String]()
            }
            if let imgURL = value["ProfileImgURL"] as? String{
                self.curUserInfo!["ProfileImgURL"] = imgURL
            }
            if let posts = value["Posts"] as? [String : String]{
                let count = String(describing : posts.count)
                self.curUserInfo!["NumPosts"] = count
               // self.curUserPosts = posts
            }
            else{
                self.curUserInfo!["NumPosts"] = "0"
               // self.curUserPosts = [String : String]()
            }
            if let email = value["EmailId"] as? String{
                self.curUserInfo?["EmailId"] = email
            }
            if let pass = value["Password"] as? String{
                self.curUserInfo?["Password"] = pass
            }
            if let name = value["Website"] as? String{
                self.curUserInfo?["Website"] = name
            }
            if let name = value["Bio"] as? String{
                self.curUserInfo?["Bio"] = name
            }
            if let name = value["Phone"] as? String{
                self.curUserInfo?["Phone"] = name
            }
            if let gender = value["Gender"] as? String{
                self.curUserInfo?["Gender"] = gender
            }
            completion("success")
        })
    }
  
    func getUserInfo(uid : String, completion: @escaping completionHandler3){
        var userDict = [String : String]()
        var friendList = [String]()
        var postList = [String : String]()
        self.databaseRef.child(uid).observeSingleEvent(of: .value, with : {(snapshot) in
            guard let value = snapshot.value as? Dictionary<String,Any> else{
               completion(userDict, friendList, postList)
                return
            }
            if let fullname = value["FullName"] as? String{
                userDict["FullName"] = fullname
            }
            if let userid = value["UserId"] as? String{
                userDict["UserId"] = userid
            }
            if let username = value["UserName"] as? String{
                userDict["UserName"] = username
            }
            if let friends = value["Friends"] as? [String]{
                friendList = friends
            }else{
                friendList = [String]()
            }
            if let imgURL = value["ProfileImgURL"] as? String{
                userDict["ProfileImgURL"] = imgURL
            }
            if let posts = value["Posts"] as? [String : String]{
                let count = String(describing : posts.count)
                userDict["NumPosts"] = count
                postList = posts
            }
            else{
               userDict["NumPosts"] = "0"
                postList = [String : String]()
            }
            completion(userDict, friendList, postList)
        })
    }
    
    func getAllPosts(completion: @escaping completionHandler2){
        Database.database().reference().child("Posts").observeSingleEvent(of : .value, with: {(snapshot) in
            guard let value = snapshot.value as? Dictionary<String, Any> else{
                return
            }
           // print(value)
            var posts = [Post]()
            for item in value{
                if let dict = item.value as? Dictionary<String,Any>{
                    let userId = dict["userId"] as! String
                    let imgurl = dict["imgURL"] as! String
                    let time = dict["timeStamp"] as! Double
                    let num = dict["likeCount"] as! Int
                    let postId = dict["postId"] as! String
                    let description = dict["description"] as! String
                    let onePost = Post(timestamp: time, userId: userId, imgURL: imgurl, numLikes: num, description: description, postId : postId)
                    posts.append(onePost)
                }
            }
            completion(posts)
        })
    }
    
    func getPublicUserInfo(uid : String, completion: @escaping completionHandler){
        Database.database().reference().child("Public Users").child(uid).observeSingleEvent(of: .value, with: {(snapshot) in
            guard let value = snapshot.value as? Dictionary<String,Any> else{
                return
            }
           // print(value)
            completion(value["UserName"] as Any, value["ProfileImgURL"] as Any)
           // self.profileImg = value["ProfileImgURL"] as! String
        })
    }
    
    func getPublicUserInfo2(uid : String, completion: @escaping completionHandler3){
        Database.database().reference().child("Public Users").child(uid).observeSingleEvent(of: .value, with: {(snapshot) in
            guard let value = snapshot.value as? Dictionary<String,Any> else{
                return
            }
            //print(value)
            completion(value["UserId"] as Any,value["UserName"] as Any, value["ProfileImgURL"] as Any)
            // self.profileImg = value["ProfileImgURL"] as! String
        })
    }
    
    func uploadImg(image: UIImage){
        self.storageRef = Storage.storage().reference()
        let data = UIImageJPEGRepresentation(image, 0.5)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        let userId = Auth.auth().currentUser?.uid
        let imageName = "UserImage/\(userId!).jpeg"
        self.storageRef = self.storageRef.child(imageName)
        
        self.storageRef.putData(data!, metadata: metadata, completion: {(metadata, error) in
            if let err = error{
               print(err.localizedDescription)
            }
            else{
                //also upload profile url in public users database
                let urlStr = String(describing : (metadata?.downloadURL())!)
                Database.database().reference().child("Public Users").child(userId!).updateChildValues(["ProfileImgURL" : urlStr])
                
                Database.database().reference().child("Users").child(userId!).updateChildValues(["ProfileImgURL" : urlStr])
            }
        })
    }
    
    func getLikeList(pid : String, completion: @escaping completionHandler2){
        Database.database().reference().child("LikeInfo").child(pid).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let value = snapshot.value as? Dictionary<String, Any> else{
                completion(snapshot.value as Any)
                return
            }
           // print(value)
            completion(value)
        })
        
    }
    
    func getAllComments(pid : String, completion: @escaping completionHandler2){
        Database.database().reference().child("Comments").child(pid).observeSingleEvent(of: .value, with: {(snapshot) in
            guard let value = snapshot.value as? Dictionary<String, Any> else{
                completion(snapshot.value as Any)
                return
            }
            var comments = [Comment]()
            for item in value{
                if let dict = item.value as? Dictionary<String,Any>{
                    let time = dict["TimeStamp"] as! Double
                    let userName = dict["UserName"] as! String
                    let content = dict["Content"] as! String
                    let imgurl = dict["ImgURL"] as! String
                    let oneComment = Comment(timestamp: time, imgURL: imgurl, content: content, userName: userName)
                    comments.append(oneComment)
                }
            }
            
            completion(comments)
        })
    }
    
    
    
}
