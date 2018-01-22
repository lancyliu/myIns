//
//  CommentTableViewCell.swift
//  myInstagram
//
//  Created by XIN LIU on 1/11/18.
//  Copyright © 2018 XIN LIU. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    
    @IBOutlet weak var profileImgView: UIImageView!
    
    @IBOutlet weak var commentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
