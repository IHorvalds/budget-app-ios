//
//  ProfileTableViewCell.swift
//  Budget
//
//  Created by Tudor Croitoru on 11/02/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//

import UIKit

class ProfileTableViewCell: RoundedTableViewCell {
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userPicture: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        indentationLevel                = 0
        userPicture.layer.cornerRadius  = cornerRadius
        userPicture.layer.masksToBounds = true
    }

}
