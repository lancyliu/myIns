//
//  AllUsersTableViewCell.swift
//  myInstagram
//
//  Created by XIN LIU on 1/8/18.
//  Copyright © 2018 XIN LIU. All rights reserved.
//

import UIKit

class AllUsersTableViewCell: UITableViewCell {

    
    @IBOutlet weak var cellImgView: UIImageView!
    
    @IBOutlet weak var cellAddFriendBtn: UIButton!
    
    @IBOutlet weak var cellUserNameLable: UILabel!
    
    
    @IBOutlet weak var showFeedsBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
}
