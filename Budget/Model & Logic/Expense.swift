//
//  Expense.swift
//  Budget
//
//  Created by Tudor Croitoru on 05.08.2018.
//  Copyright © 2018 Tudor Croitoru. All rights reserved.
//

import Foundation

class Expense: NSObject, NSCoding, Codable {
    
    let title: String
    var price: Double
    let datePurchased: Date
    
    init(title: String, price: Double){
        self.title = title
        self.price = price
        self.datePurchased = Date()
        
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: "expenseTitleKey")
        aCoder.encode(price, forKey: "expensePriceForeverKey")
        aCoder.encode(datePurchased, forKey: "expenseDateKey")
    }
    
    required init(coder aDecoder: NSCoder) {
        title = aDecoder.decodeObject(forKey: "expenseTitleKey") as! String
        price = aDecoder.decodeDouble(forKey: "expensePriceForeverKey")
        datePurchased = aDecoder.decodeObject(forKey: "expenseDateKey") as! Date
    }
    
    
}
