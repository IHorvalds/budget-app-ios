//
//  TodayAvailableCell.swift
//  Budget
//
//  Created by Tudor Croitoru on 26/08/2018.
//  Copyright © 2018 Tudor Croitoru. All rights reserved.
//

import UIKit

class TodayAvailableCell: UITableViewCell {
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set (newFrame) {
            var frame = newFrame
            frame.origin.x      += inset
            frame.size.width    -= 2 * inset
            super.frame         = frame
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.layer.cornerRadius     = cornerRadius
        self.layer.shadowOffset     = CGSize(width: 0.0, height: 2.0)
        self.layer.shadowColor      = UIColor.black.cgColor
        self.layer.masksToBounds    = false
        self.clipsToBounds          = false
        self.layer.shadowRadius     = 5.0
        self.layer.shadowOpacity    = 0.2
//        backgroundColor = #colorLiteral(red: 0.1923936307, green: 0.2181482315, blue: 0.2418812215, alpha: 1)
    }


}
