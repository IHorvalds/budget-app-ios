//
//  OverViewTableViewCell.swift
//  Budget
//
//  Created by Tudor Croitoru on 04.08.2018.
//  Copyright © 2018 Tudor Croitoru. All rights reserved.
//

import UIKit

protocol OverviewCollectionViewCellDelegate {
    func didTapBudgetDate(dateString: String)
    var moneyLeft: Double? {get}
}

@IBDesignable
class OverViewCollectionViewCell: UICollectionViewCell {
    
    let lineLayer = CAShapeLayer()
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set (newFrame) {
            var frame = newFrame
            frame.origin.x   += inset
            frame.size.width -= 2 * inset
            super.frame = frame
        }
    }
    
    var delegate: OverviewCollectionViewCellDelegate?
    
    @IBAction func pressedDate(_ sender: UIButton) {
        delegate?.didTapBudgetDate(dateString: sender.titleLabel?.text ?? "")
    }
    
    @IBOutlet weak var isInOrOverBudget: UILabel!
    
    @IBOutlet weak var spentToday: UILabel!
    @IBOutlet weak var remainingToday: UILabel!
    @IBOutlet weak var checkBox: UIImageView!
    @IBOutlet weak var dateButton: UIButton!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.cornerRadius     = cornerRadius
        self.layer.shadowOffset     = CGSize(width: 0.0, height: 5.0)
        self.layer.shadowColor      = UIColor.black.cgColor
        self.layer.masksToBounds    = false
        self.clipsToBounds          = false
        self.layer.shadowRadius     = 8.5
        self.layer.shadowOpacity    = 0.2
        
        let lineWidth: CGFloat = 0.5
        
        lineLayer.removeFromSuperlayer()
        let line                = UIBezierPath()
        line.move(to: CGPoint(x: frame.width * (1/2 - 0.325), y: frame.height/2))
        line.addLine(to: CGPoint(x: frame.width * (1/2 + 0.325), y: frame.height/2))
        lineLayer.path          = line.cgPath
        lineLayer.strokeColor   = UIColor.black.cgColor
        lineLayer.lineWidth     = lineWidth
        self.layer.addSublayer(lineLayer)
        
    }
    

}
