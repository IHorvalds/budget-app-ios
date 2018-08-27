//
//  TodayAvailableCell.swift
//  Budget
//
//  Created by Tudor Croitoru on 26/08/2018.
//  Copyright © 2018 Tudor Croitoru. All rights reserved.
//

import UIKit

class TodayAvailableCell: UITableViewCell {

    let inset = 10.0
    let cornerRadius: CGFloat = 15.0
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set (newFrame) {
            var frame = newFrame
            frame.origin.x += CGFloat(inset)
            frame.size.width -= CGFloat (2 * inset)
            super.frame = frame
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.layer.cornerRadius = cornerRadius
        self.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.masksToBounds = false
        self.clipsToBounds = false
        self.layer.shadowRadius = 4.0
        self.layer.shadowOpacity = 0.7
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
