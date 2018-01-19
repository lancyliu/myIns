//
//  ChatViewController.swift
//  myInstagram
//
//  Created by XIN LIU on 1/16/18.
//  Copyright © 2018 XIN LIU. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class Chat2ViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var recProfileImg: UIImageView!
    
    @IBOutlet weak var msgTableView: UITableView!
    @IBOutlet weak var msgTextView: UITextView!
    @IBOutlet weak var tableViewBottom: NSLayoutConstraint!
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    @IBOutlet weak var viewBtmConstraint: NSLayoutConstraint!
    
    
    var msgArr = [MsgInfo]()
    var receiverId : String?
    var receiverInfo : UserInfo?
    var curUserInfo : UserInfo?
    var databaseRef : DatabaseReference?
    var rootView : String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.msgTextView.delegate = self
        self.msgTableView.delegate = self
        self.msgTableView.dataSource = self
        self.msgTextView.isScrollEnabled = false
        databaseRef = Database.database().reference()
        self.msgTextView.text = "Type here..."
        self.msgTextView.textColor = UIColor.lightGray

//        let oneMsg = MsgInfo(isSender: true, content: "How does one change the height of a UITextView's frame depending on the text that is currently being displayed by the text view? I have tried a ton of suggested solutions and looked around quite a bit for help, but can't seem to find anything that works.")
//
//        let twoMsg = MsgInfo(isSender: false, content: "I have tried a ton of suggested solutions and looked around quite a bit for help, but can't seem to find anything that works.")
//
//        self.msgArr.append(oneMsg)
//        self.msgArr.append(twoMsg)
        
        //get all messages, and show it in the tableview
        self.setUpInfo()
        self.getAllMessages()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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
        self.msgTableView.reloadData()
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
        
       // print(uid)
        //        let notificationkey = Database.database().reference().child("notificationRequests").childByAutoId().key
        //
        //        //make the dictionary
        //        let dict = ["username" : uid, "message" : "Test Msg"]
        //        //let notifyupdate = ["/notificationRequests/\(notificationkey)" : dict]
        //        Database.database().reference().child("notificationRequests").child(notificationkey).updateChildValues(dict)
        //       // Database.database().reference().updateChildValues(notifyupdate)
        
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

extension Chat2ViewController : UITextViewDelegate{
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
            self.msgTableView.scrollToRow(at: indexpath, at: .bottom, animated: true)
        }
        
    }
}

extension Chat2ViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.msgArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let oneMsg = self.msgArr[indexPath.row]
        
        if oneMsg.senderId != (self.curUserInfo?.userId)! {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell") as? MessageTableViewCell
            cell?.nameLabel.text = self.receiverInfo?.username
            cell?.contentLabel.text = oneMsg.content
            
            cell?.backgroundImg.image = UIImage(named : "recMsg")?.resizableImage(withCapInsets:UIEdgeInsetsMake(40, 40, 40, 40)).withRenderingMode(.alwaysTemplate)
            //set it to grey
            cell?.backgroundImg.tintColor = UIColor(white: 0.90, alpha: 1.0)
            var newframe = (cell?.contentLabel.frame)!
            newframe.size = CGSize(width: newframe.size.width+10, height: newframe.size.height+15)
            cell?.backgroundImg.frame = newframe
            
//            if (cell?.contentLabel.text?.count)! > 30{
//                var newframe = (cell?.contentLabel.frame)!
//                newframe.size = CGSize(width: newframe.size.width+10, height: newframe.size.height+15)
//                cell?.backgroundImg.frame = newframe
//            }else{
//                let less = CGFloat( 30 - (cell?.contentLabel.text?.count)!)
//                var newframe = (cell?.contentLabel.frame)!
//                newframe.size = CGSize(width: newframe.size.width+10, height: newframe.size.height+15)
//                cell?.backgroundImg.frame = newframe
//                cell?.contentLabel.frame = newframe
//
//                cell?.msgImgPos.constant += 8*less
//                cell?.contentLabelPos.constant += 8*less
//            }
            
            return cell!
            
        }else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "sendMsgCell") as? SendMsgTableViewCell
        
            cell?.nameLabel.text = "You"
            cell?.contentCell.text = oneMsg.content
            
            cell?.backgroundImg.image = UIImage(named : "sendMsg")?.resizableImage(withCapInsets: UIEdgeInsetsMake(40, 40, 40, 40)).withRenderingMode(.alwaysTemplate)
           cell?.backgroundImg.tintColor = UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 1.0)
            
            var newframe = (cell?.contentCell.frame)!
            newframe.size = CGSize(width: newframe.size.width+10, height: newframe.size.height+15)
            cell?.backgroundImg.frame = newframe
            
//            if (cell?.contentCell.text?.count)! > 30{
//                var newframe = (cell?.contentCell.frame)!
//                newframe.size = CGSize(width: newframe.size.width+10, height: newframe.size.height+15)
//                cell?.backgroundImg.frame = newframe
//            }else{
//                let less = CGFloat( 30 - (cell?.contentCell.text?.count)!)
//                var newframe = (cell?.contentCell.frame)!
//                newframe.size = CGSize(width: newframe.size.width+10, height: newframe.size.height+15)
//                cell?.backgroundImg.frame = newframe
//                cell?.contentCell.frame = newframe
//
//                cell?.imgPos.constant += 8*less
//                cell?.contentPos.constant += 8*less
//            }
            
            return cell!
        }
    }
}
