//
//  AddPostViewController.swift
//  myInstagram
//
//  Created by XIN LIU on 1/9/18.
//  Copyright © 2018 XIN LIU. All rights reserved.
//

import UIKit
import Firebase
import TWMessageBarManager

class AddPostViewController: BaseViewController, UITextFieldDelegate{

    
    @IBOutlet weak var addImgView: UIImageView!
    
    @IBOutlet weak var descriptionTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.descriptionTextField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnCancelAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnPostAction(_ sender: Any) {
        //save cur time,,,,,, to database/storage
        let time = (Date().timeIntervalSince1970)
        let userId = Auth.auth().currentUser?.uid
        let key = Database.database().reference().child("Posts").childByAutoId().key
        //save image use key, then get the imgurl
        var storageRef = Storage.storage().reference()
        let image = self.addImgView.image
        let data = UIImageJPEGRepresentation(image!, 0.5)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        let imageName = "PostsImage/\(key).jpeg"
        storageRef = storageRef.child(imageName)
        storageRef.putData(data!, metadata: metadata, completion: {(metadata, error) in
            if let err = error{
                print(err.localizedDescription)
            }
            else{
                let urlStr = String(describing : (metadata?.downloadURL())!)
                //upload it to database
                Database.database().reference().child("Posts").child(key).updateChildValues(["timeStamp" : time, "userId" : userId!, "imgURL" : urlStr, "likeCount" : 0, "description" :self.descriptionTextField.text!, "postId" : key])
                
                Database.database().reference().child("Users").child(userId!).child("Posts").updateChildValues([key : urlStr])
                
                TWMessageBarManager.sharedInstance().showMessage(withTitle: "Success", description: "Post a new feed", type: .info)
                let nc = NotificationCenter.default
                AccessFirebase.sharedAccess.getCurUserInfo(){ (res) in
                    guard res is String else{
                        return
                    }
                    let notification = Notification(name: Notification.Name(rawValue: "NewFeedAdded"), object: self)
                    nc.post(notification)
                    self.navigationController?.popViewController(animated: true)
                }
                
            }
        })
        
    }
    
    @IBAction func btnTakePic(_ sender: Any) {
        self.getPicture()
    }
    
    //imagePickerController delegate methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        picker.dismiss(animated: true)
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        //show the picture you just choose
        self.addImgView.image = image
    }
    
}
