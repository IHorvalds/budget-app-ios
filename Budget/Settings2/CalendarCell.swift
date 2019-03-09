//
//  CalendarCell.swift
//  Budget
//
//  Created by Tudor Croitoru on 24/02/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//

import UIKit
import KDCalendar

class CalendarCell: RoundedTableViewCell, CalendarViewDataSource {
    
    @IBOutlet weak var calendarView: CalendarView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.indentationLevel = 0
        self.calendarView.dataSource = self
    }
    
    func startDate() -> Date {
        return Date()
    }
    
    func endDate() -> Date {
        return Date()
    }

}

extension CalendarHeaderView {
    override open func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        
        self.backgroundColor = UIColor(red: 218/255, green: 102/255, blue: 102/255, alpha: 1.00)
    }
    
}


extension CalendarDayCell {
    
    override open var isSelected: Bool {
        didSet {
            switch isSelected {
            case true:
                self.bgView.backgroundColor = CalendarView.Style.cellSelectedColor
            case false:
                break
            }
        }
    }
}
