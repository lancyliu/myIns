//
//  DataType.swift
//  myInstagram
//
//  Created by XIN LIU on 1/9/18.
//  Copyright © 2018 XIN LIU. All rights reserved.
//

import Foundation
import UIKit

struct Post{
    var timestamp : Double
    var userId : String
    var imgURL : String
    var numLikes : Int
    var description : String
    var postId : String
}

struct Comment{
    var timestamp : Double
//    var userId : String
    var imgURL : String
    var content : String
    var userName : String
//    var postId : String
}

struct UserInfo{
    var username : String?
    var userId : String?
    var imgUrl : String?
    var fullName : String?
    var numOfPosts : Int?
    
    init(){}
    init(uname : String, id: String, url : String){
        username = uname
        userId = id
        imgUrl = url
    }
}


struct MsgInfo{
   // var isSender : Bool?
    var content : String?
    var timeStamp : Int
    var senderName : String
    var senderId : String
}


class Downloader {
    
    class func downloadImageWithURL(url:String) -> UIImage! {
        
        
        do {
            let data = try NSData(contentsOf: NSURL(string: url)! as URL, options: NSData.ReadingOptions())
            //print(data)
            return UIImage(data: data as Data)
        } catch {
            print(error)
        }
        return UIImage()
    }
}
