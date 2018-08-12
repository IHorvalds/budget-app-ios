//
//  OverViewTableViewCell.swift
//  Budget
//
//  Created by Tudor Croitoru on 04.08.2018.
//  Copyright © 2018 Tudor Croitoru. All rights reserved.
//

import UIKit

protocol OverviewTableViewCellDelegate {
    func didTapMoneyLeft()
    var moneyLeft: Double? {get}
}

@IBDesignable
class OverViewTableViewCell: UITableViewCell {
    
    @IBAction func didTapMoneyLeft(_ sender: UIButton) {
        delegate?.didTapMoneyLeft()
    }
    
    @IBOutlet weak var isInOrOverBudget: UILabel!
    
    @IBOutlet weak var budgetThisMonth: UILabel!
    @IBOutlet weak var moneyLeftThisMonth: UIButton!
    
    var delegate: OverviewTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
