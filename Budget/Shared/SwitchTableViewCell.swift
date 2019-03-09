//
//  SwitchTableViewCell.swift
//  Budget
//
//  Created by Tudor Croitoru on 18/02/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//

import UIKit

class SwitchTableViewCell: RoundedTableViewCell {

    @IBOutlet weak var uiSwitch: UISwitch!
    let detailInfoButton = UIButton(type: .detailDisclosure)
    
    override func awakeFromNib() {
        accessoryView = detailInfoButton
    }
    
}
