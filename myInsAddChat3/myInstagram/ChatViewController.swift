//
//  ChatViewController.swift
//  myInstagram
//
//  Created by XIN LIU on 1/18/18.
//  Copyright © 2018 XIN LIU. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class ChatViewController: UIViewController {

    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var recProfileImg: UIImageView!
    
    @IBOutlet weak var msgTextView: UITextView!

    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    @IBOutlet weak var viewBtmConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var collectView: UICollectionView!
    
    var msgArr = [MsgInfo]()
    var receiverId : String?
    var receiverInfo : UserInfo?
    var curUserInfo : UserInfo?
    var databaseRef : DatabaseReference?
    var rootView : String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.msgTextView.delegate = self
        self.collectView.delegate = self
        self.collectView.dataSource = self
        
        self.msgTextView.isScrollEnabled = false
        databaseRef = Database.database().reference()
        self.msgTextView.text = "Type here..."
        self.msgTextView.textColor = UIColor.lightGray
        
        self.setUpInfo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func btnSendAction(_ sender: Any) {
        //set constraint and textview position
        self.msgTextView.resignFirstResponder()
        self.viewBtmConstraint.constant = 0
        
        
        let content = self.msgTextView.text
        let senderName = self.curUserInfo?.username
        let senderId = self.curUserInfo?.userId
        let timestamp = Int(Date().timeIntervalSince1970)
        //append text view text in the msgarr, reload table view
        
        let newMsg = MsgInfo(content: content!, timeStamp: timestamp, senderName: senderName!, senderId: senderId!)
        self.msgArr.append(newMsg)
        self.collectView.reloadData()
        self.msgTextView.text = ""
        //send notification to the receiver, and update database
        let msgDict = ["content" : content!, "senderName" : senderName!, "senderId" : senderId!]
        
        var chatKey = ""
        if let recUserId = self.receiverInfo?.userId{
            if senderId! < recUserId{
                chatKey = senderId! + "" + recUserId
            }else{
                chatKey = recUserId + senderId!
            }
        }
        let time = String(describing : timestamp)
        databaseRef?.child("Conversation").child(chatKey).child(time).updateChildValues(msgDict)
        
        let notificationKey = Database.database().reference().child("notificationRequests").childByAutoId().key
        let dict = ["message" : content!, "username" : (self.receiverInfo?.userId)!]
        Database.database().reference().child("notificationRequests").child(notificationKey).updateChildValues(dict)
        
    }
    
    
    @IBAction func btnBackAction(_ sender: Any) {
        //check rootView of this chat
        if let rootview = self.rootView{
            if rootview == "AppDelegate"{
                let sb = UIStoryboard(name: "Main", bundle: nil)
                let mainTabCont = sb.instantiateViewController(withIdentifier: "TabBarController") as? TabViewController
                let cont = sb.instantiateViewController(withIdentifier: "AllChatViewController") as? AllChatViewController
                var controllers = mainTabCont?.viewControllers
                controllers![4] = cont!
                mainTabCont?.viewControllers = controllers
                mainTabCont?.selectedIndex = 4
                //change uiwindow root view to cont
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let window = appDelegate.window
                window?.rootViewController = mainTabCont
                window?.makeKeyAndVisible()
            }else{
                navigationController?.popViewController(animated: true)
            }
        }else{
            navigationController?.popViewController(animated: true)
        }
        
    }
    
    
}

extension ChatViewController{
    func setUpInfo(){
        if let _ = self.curUserInfo, let _ = self.receiverInfo{
            //do not need to setup user's info, call get all msg function
            let url = URL(string: (self.receiverInfo?.imgUrl)!)
            self.recProfileImg.layer.cornerRadius = (self.recProfileImg.frame.size.width)/2
            self.recProfileImg.clipsToBounds = true
            self.recProfileImg.sd_setImage(with: url!, completed: nil)
            self.titleLabel.text = "Chat with \((self.receiverInfo?.username)!)"
            self.getAllMessages()
        }else{
            if let recId = self.receiverId{
                databaseRef?.child("Public Users").child(recId).observeSingleEvent(of: .value, with: {(snapshot) in
                    guard let value = snapshot.value as? Dictionary<String, Any> else{
                        return
                    }
                    
                    self.receiverInfo = UserInfo(username: value["UserName"] as! String, userId: value["UserId"] as! String, imgUrl: value["ProfileImgURL"] as! String)
                    let url = URL(string: (self.receiverInfo?.imgUrl)!)
                    self.recProfileImg.layer.cornerRadius = (self.recProfileImg.frame.size.width)/2
                    self.recProfileImg.clipsToBounds = true
                    self.recProfileImg.sd_setImage(with: url!, completed: nil)
                    self.titleLabel.text = "Chat with \((self.receiverInfo?.username)!)"
                    self.databaseRef?.child("Users").child((Auth.auth().currentUser?.uid)!).observeSingleEvent(of: .value, with: {(snapshot) in
                        guard let value2 = snapshot.value as? Dictionary<String, Any> else{
                            return
                        }
                        
                        self.curUserInfo = UserInfo(username: value2["UserName"] as! String, userId: value2["UserId"] as! String, imgUrl: value2["ProfileImgURL"] as! String)
                        self.getAllMessages()
                    })
                })
            }
        }
    }
    
    
    func getAllMessages(){
        self.msgArr = [MsgInfo]()
        
        //get the conversation key in database
        var chatKey = ""
        if let curUserId = self.curUserInfo?.userId, let recUserId = self.receiverInfo?.userId{
            if curUserId < recUserId{
                chatKey = curUserId + "" + recUserId
            }else{
                chatKey = recUserId + curUserId
            }
        }
        
        //use chatKey get all message in database
        Database.database().reference().child("Conversation").child(chatKey).queryOrderedByKey().observe(.value, with: { (snapshot) in
            self.msgArr = []
            var tempMsgArr = [MsgInfo]()
            guard let value = snapshot.value as? Dictionary<String, Any> else{
                return
            }
            
            for item in value{
                let msgDict = item.value as? Dictionary<String, String>
                if let senderId = msgDict?["senderId"], let senderName = msgDict?["senderName"], let content = msgDict?["content"]{
                    let time = Int(item.key)
                    let oneMsg = MsgInfo(content: content, timeStamp: time!, senderName: senderName, senderId: senderId)
                    tempMsgArr.append(oneMsg)
                }
            }
            
            self.msgArr = tempMsgArr.sorted(by: { (obj1, obj2) -> Bool in
                
                let ts1 = obj1.timeStamp
                let ts2 = obj2.timeStamp
                
                return(ts1 < ts2)
            })
            
            self.collectView.reloadData()
            if self.msgArr.count != 0{
                let indexpath = IndexPath(item: self.msgArr.count-1, section: 0)
                self.collectView.scrollToItem(at: indexpath, at: .bottom, animated: true)
            }
        })
    }
    
    
}



extension ChatViewController : UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == self.msgTextView{
            textView.becomeFirstResponder()
            self.viewBtmConstraint.constant = self.viewBtmConstraint.constant - 220
        }
        
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let oldheight = textView.frame.size.height
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        textView.frame = newFrame
        if(textView.frame.size.height != oldheight){
            self.viewHeight.constant = self.viewHeight.constant + textView.frame.size.height - oldheight
        }
        if self.msgArr.count != 0{
            let indexpath = IndexPath(item: self.msgArr.count-1, section: 0)
            self.collectView.scrollToItem(at: indexpath, at: .bottom, animated: true)
        }
        
    }
}


extension ChatViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.msgArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OneCollectCell", for: indexPath) as? MsgCollectionViewCell
        let oneMsg = self.msgArr[indexPath.row]
        
        cell?.msgLabel.text = oneMsg.content
        
        if oneMsg.senderId != (self.curUserInfo?.userId)! {
            //not sender
            cell?.msgImg.image = UIImage(named: "recMsg")?.resizableImage(withCapInsets: UIEdgeInsetsMake(40, 40, 40, 40)).withRenderingMode(.alwaysTemplate)
            cell?.msgImg.tintColor = UIColor(white: 0.90, alpha: 1.0)
            let size = CGSize(width: 220, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let estimatedFrame = NSString(string : (oneMsg.content)!).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 17)], context:nil)
            cell?.msgImg.frame = CGRect(x: 35, y: 15 , width: estimatedFrame.width+60, height: estimatedFrame.height+20)
            cell?.msgLabel.frame = CGRect(x: 75, y: 15, width: estimatedFrame.width, height: estimatedFrame.height+10)
            cell?.nameLabel.text = (self.receiverInfo?.username)!
            cell?.nameLabel.frame = CGRect(x: 10, y: 0, width: 80, height: 10)
            let url = URL(string : (self.curUserInfo?.imgUrl)!)
            cell?.profileImg.sd_setImage(with: url!, completed: nil)
            cell?.profileImg.frame = CGRect(x: 10, y: 15, width: 30, height: 30)
            
        }else{
            //is sender
            cell?.msgImg.image = UIImage(named: "sendMsg")?.resizableImage(withCapInsets: UIEdgeInsetsMake(40, 40, 40, 40)).withRenderingMode(.alwaysTemplate)
            cell?.msgImg.tintColor = UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 1.0)
            let size = CGSize(width: 220, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let estimatedFrame = NSString(string : (oneMsg.content)!).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 17)], context:nil)
            cell?.msgImg.frame = CGRect(x: view.frame.width - estimatedFrame.width - 80, y: 15 , width: estimatedFrame.width+50, height: estimatedFrame.height+20)
            cell?.msgLabel.frame = CGRect(x: view.frame.width - estimatedFrame.width - 60, y: 15 , width: estimatedFrame.width, height: estimatedFrame.height+10)
            cell?.nameLabel.text = "You"
            cell?.nameLabel.frame = CGRect(x: view.frame.width - 120, y: 0, width: 80, height: 10)
            let url = URL(string : (self.curUserInfo?.imgUrl)!)
            cell?.profileImg.sd_setImage(with: url!, completed: nil)
            cell?.profileImg.frame = CGRect(x: view.frame.width - 40, y: estimatedFrame.height+10, width: 30, height: 30)
           
        }
        
        return cell!
    }
    
    //layour
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let oneMsg = self.msgArr[indexPath.row]
        
        let size = CGSize(width: 220, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let estimatedFrame = NSString(string : (oneMsg.content)!).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 17)], context:nil)
        
        return CGSize(width: view.frame.width, height: estimatedFrame.height + 70)
    }
    
    
}


