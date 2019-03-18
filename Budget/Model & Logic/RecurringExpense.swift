//
//  RecurringExpense.swift
//  Budget
//
//  Created by Tudor Croitoru on 28/02/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//

import Foundation

class RecurringExpense: Expense {
    
    var dayOfMonth: DateComponents = DateComponents()
    
    var calendar = Calendar(identifier: .gregorian)
    
    override init(title: String, price: Double, currency: String, datePurchased: Date?) {
        super.init(title: title, price: price, currency: currency, datePurchased: datePurchased)
        
        self.calendar.timeZone = TimeZone(abbreviation: "UTC")!
        self.dayOfMonth.day = calendar.component(.day, from: self.datePurchased)
    }
    
    required init(from decoder: Decoder) throws {
        do{
            try super.init(from: decoder)
            self.calendar.timeZone = TimeZone(abbreviation: "UTC")!
            self.dayOfMonth.day = calendar.component(.day, from: datePurchased)
        } catch {
            throw error
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.calendar.timeZone = TimeZone(abbreviation: "UTC")!
        self.dayOfMonth.day = calendar.component(.day, from: datePurchased)
    }
    
    func updateDayOfMonth() {
        self.dayOfMonth.day = calendar.component(.day, from: self.datePurchased)
    }
    
    func createExpensesFor(settings: Settings?) -> [Expense] {
        var expenses = [Expense]()
        
        if  let initialDate = settings?.paymentDate,
            let finalDate   = settings?.mustLastUntil {
            
            var calendar        = Calendar(identifier: .gregorian)
            calendar.timeZone   = TimeZone(abbreviation: "UTC")!
            
            var _initialExpense = self.datePurchased
            _initialExpense = calendar.startOfDay(for: _initialExpense)
            
            while _initialExpense < finalDate && _initialExpense > initialDate {
                
                let e = Expense(title: self.title,
                                price: self.price,
                                currency: self.currency.isoCode,
                                datePurchased: _initialExpense)
                
                expenses.append(e)
                print(_initialExpense)
                
                _initialExpense = _initialExpense.getSameDayNextMonth()
            }
            
        }
        return expenses
    }
    
}
