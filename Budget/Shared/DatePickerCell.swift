//
//  DatePickerCell.swift
//  Budget
//
//  Created by Tudor Croitoru on 01/05/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//

import UIKit

class DatePickerCell: RoundedTableViewCell {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    var initialDate: Date?
    var finalDate: Date?
    override func awakeFromNib() {
        super.awakeFromNib()
        datePicker.minimumDate = initialDate
        datePicker.maximumDate = finalDate
    }
    
    

}
