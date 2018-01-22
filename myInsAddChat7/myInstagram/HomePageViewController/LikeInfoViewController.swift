//
//  LikeInfoViewController.swift
//  myInstagram
//
//  Created by XIN LIU on 1/11/18.
//  Copyright © 2018 XIN LIU. All rights reserved.
//

import UIKit
import SDWebImage

class LikeInfoViewController: UIViewController {

    
    @IBOutlet weak var likeInfoTableView: UITableView!
    
    var postInfo : Post?
    var arrOfUserDict = [[String : String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.likeInfoTableView.delegate = self
        self.likeInfoTableView.dataSource = self
        self.likeInfoTableView.backgroundColor = UIColor.clear
        self.likeInfoTableView.tableFooterView = UIView()
        //get like users
        getLikeUserList()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func btnBackAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func getLikeUserList(){
        if let pid = self.postInfo?.postId{
            AccessFirebase.sharedAccess.getLikeList(pid: pid){ (result) in
                if let likeList = result as? [String : Any]{
                    for item in likeList{
                        if let user = item.value as? [String : String]{
                            var oneUser = [String : String]()
                            if let name = user["UserName"] {
                                oneUser["UserName"] = name
                            }
                            if let imgurl = user["ProfileImgURL"]{
                                oneUser["ProfileImgURL"] = imgurl
                            }
                            self.arrOfUserDict.append(oneUser)
                        }
                    }
                    self.likeInfoTableView.reloadData()
                }
                
            }
        }
        
    }
    
}


extension LikeInfoViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrOfUserDict.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LikeInfoCell") as? LikeInfoTableViewCell
        cell?.backgroundColor = UIColor.clear
        let oneUser = arrOfUserDict[indexPath.row]
        cell?.usernameLabel.text = oneUser["UserName"]
        cell?.profileImg.layer.cornerRadius = (cell?.profileImg.frame.size.width)!/2
        cell?.profileImg.clipsToBounds = true
        let url = URL(string: oneUser["ProfileImgURL"]!)
        cell?.profileImg.sd_setImage(with: url, completed: nil)
        return cell!
    }
}
