//
//  ExpenseCell.swift
//  Budget
//
//  Created by Tudor Croitoru on 24/08/2018.
//  Copyright © 2018 Tudor Croitoru. All rights reserved.
//

import UIKit


class ExpenseCell: UITableViewCell {

    public var secondColor = UIColor(red:0.65, green:0.92, blue:1.00, alpha:1.0)
    public var firstColor = UIColor(red:0.17, green:0.38, blue:0.64, alpha:1.0)

    let inset: CGFloat = 10.0
    let cornerRadius: CGFloat = 15.0
    let gradientLayer = CAGradientLayer()
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set (newFrame) {
            var frame = newFrame
            frame.origin.x += inset
            frame.size.width -= inset
            super.frame = frame
        }
    }
    
//    var firstColor: UIColor?
//    var secondColor: UIColor?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer.colors = [firstColor.cgColor, secondColor.cgColor]
        gradientLayer.frame = self.bounds
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        self.layer.insertSublayer(gradientLayer, at: 0)
        self.clipsToBounds = true
        
        self.layer.cornerRadius = cornerRadius
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        
        let bottomBorder = CALayer()
        let topBorder = CALayer()
        topBorder.frame = CGRect.init(x: 0, y: 0, width: self.frame.width, height: 0.25)
        bottomBorder.frame = CGRect.init(x: 0, y: self.frame.height - 0.25, width: self.frame.width, height: 0.25)
        topBorder.backgroundColor = UIColor.white.cgColor
        bottomBorder.backgroundColor = UIColor.white.cgColor
        self.layer.addSublayer(topBorder)
        self.layer.addSublayer(bottomBorder)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

