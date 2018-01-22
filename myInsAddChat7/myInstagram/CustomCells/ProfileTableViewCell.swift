//
//  ProfileTableViewCell.swift
//  myInstagram
//
//  Created by XIN LIU on 1/8/18.
//  Copyright © 2018 XIN LIU. All rights reserved.
//

import UIKit

class ProfileTableViewCell: UITableViewCell{

    
    @IBOutlet weak var cellLable: UILabel!
    
    @IBOutlet weak var cellTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

}
