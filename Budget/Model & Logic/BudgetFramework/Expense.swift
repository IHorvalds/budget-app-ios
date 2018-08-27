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
        let date = Date()
        let day = Calendar.current.dateComponents([.year, .month, .day], from: date)
        self.datePurchased = Calendar.current.date(from: day)!// + TimeInterval(86400) //the time interval is added because for some reason, Date() initializez 1 day early in Denmark. See Also BudgedViewController and for the same delta added to the date
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
