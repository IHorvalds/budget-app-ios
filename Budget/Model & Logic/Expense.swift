//
//  Expense.swift
//  Budget
//
//  Created by Tudor Croitoru on 05.08.2018.
//  Copyright © 2018 Tudor Croitoru. All rights reserved.
//

import Foundation

class Expense: NSObject, NSCoding, Codable {
    
    
    var title: String
    var price: Double
    var currency: Currency
    var datePurchased: Date
    var notificationsOn = false
    
    init(title: String, price: Double, currency: String, datePurchased: Date?) {
        self.title           = title
        self.price           = price
        self.datePurchased   = (datePurchased != nil) ? datePurchased! : Date()
        self.currency        = Currency(isoCode: currency)
    }
    
    /// <#Description#>
    ///
    /// - Parameter onOrOff:
    ///     - true - turns notifications on for this expense
    ///     - false - turns notifications off for this specific expense
    func turnNotifications(onOrOff: Bool) {
        
        self.notificationsOn = onOrOff
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: "expenseTitleKey")
        aCoder.encode(price, forKey: "expensePriceForeverKey")
        aCoder.encode(datePurchased, forKey: "expenseDateKey")
        aCoder.encode(currency.isoCode, forKey: "currencyKey")
        aCoder.encode(notificationsOn, forKey: "notificationsOnKey")
    }
    
    required init(coder aDecoder: NSCoder) {
        title           = aDecoder.decodeObject(forKey: "expenseTitleKey") as! String
        price           = aDecoder.decodeDouble(forKey: "expensePriceForeverKey")
        datePurchased   = aDecoder.decodeObject(forKey: "expenseDateKey") as! Date
        currency        = Currency(isoCode: aDecoder.decodeObject(forKey: "currencyKey") as! String)
        notificationsOn = aDecoder.decodeBool(forKey: "notificationsOnKey")
    }
    
    func recurringExpense() -> RecurringExpense {
        return RecurringExpense(title: self.title,
                                price: self.price,
                                currency: self.currency.isoCode,
                                datePurchased: self.datePurchased)
    }

}
