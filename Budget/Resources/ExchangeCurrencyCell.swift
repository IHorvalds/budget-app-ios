//
//  ExchangeCurrencyCell.swift
//  Budget
//
//  Created by Tudor Croitoru on 27/08/2018.
//  Copyright © 2018 Tudor Croitoru. All rights reserved.
//

import UIKit

class ExchangeCurrencyCell: RoundedTableViewCell {

    @IBOutlet weak var exchangeCurrencyAmount: UILabel!
    @IBOutlet weak var exchangeCurrencyLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
