//
//  BudgetForDay.swift
//  Budget
//
//  Created by Tudor Croitoru on 09.08.2018.
//  Copyright © 2018 Tudor Croitoru. All rights reserved.
//

import Foundation

class BudgetForDay: NSObject, NSCoding {
    
    var totalUsableAmount: Double
    let day: Date
    var checked: Bool
    
    init(totalUsableAmount: Double, day: Date) {
        self.totalUsableAmount = totalUsableAmount
        self.day = day //NOTE: All instances of this class will be created when the recording period begins and they will be updated as time progresses in the period
        self.checked = false
    }
    
    required init(coder aDecoder: NSCoder) {
        totalUsableAmount = aDecoder.decodeDouble(forKey: "totalUsableAmountKey")
        day = aDecoder.decodeObject(forKey: "dayKey") as! Date
        checked = aDecoder.decodeBool(forKey: "checkedKey") 
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(totalUsableAmount, forKey: "totalUsableAmountKey")
        aCoder.encode(day, forKey: "dayKey")
        aCoder.encode(checked, forKey: "checkedKey")
    }
    
    func updateTotalUsableAmount(expense: Expense) { //this gets called everytime the user adds an expense
        self.totalUsableAmount = self.totalUsableAmount - expense.price
    }
}
