//
//  BudgetForDay.swift
//  Budget
//
//  Created by Tudor Croitoru on 09.08.2018.
//  Copyright © 2018 Tudor Croitoru. All rights reserved.
//

import Foundation

class BudgetForDay: NSObject, NSCoding, Codable {
    
    var totalUsableAmount: Double
    let day: Date
    var checked: Bool
    var currency: String
    var expenses: [Expense]
    
    
    
    init(totalUsableAmount: Double, currency: String?, day: Date, expenses: [Expense]?) {
        self.totalUsableAmount  = totalUsableAmount
        self.day                = day //NOTE: All instances of this class will be created when the recording period begins and they will be updated as time progresses in the period
        self.checked            = false
        self.expenses           = expenses ?? []
        self.currency           = currency ?? ""
    }
    
    
    
    required init(coder aDecoder: NSCoder) {
        totalUsableAmount   = aDecoder.decodeDouble(forKey: "totalUsableAmountKey")
        day                 = aDecoder.decodeObject(forKey: "dayKey") as! Date
        checked             = aDecoder.decodeBool(forKey: "checkedKey")
        expenses            = aDecoder.decodeObject(forKey: "expensesKey") as! [Expense]
        currency            = aDecoder.decodeObject(forKey: "currencyKey") as! String
    }
    
    
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(totalUsableAmount,    forKey: "totalUsableAmountKey")
        aCoder.encode(day,                  forKey: "dayKey")
        aCoder.encode(checked,              forKey: "checkedKey")
        aCoder.encode(expenses,             forKey: "expensesKey")
        aCoder.encode(currency,             forKey: "currencyKey")
    }
    
    
    
    
//    func updateTotalUsableAmount(expense: Expense) { //this gets called everytime the user adds an expense
//        expenses?.append(expense)
//        let expensePriceInCurrency = expense.currency.convert(toCurrency: Currency(isoCode: currency), amount: expense.price)
//        self.totalUsableAmount = self.totalUsableAmount - (expensePriceInCurrency ?? expense.price)
//    }
    
    static func updateTotalUsableAmount(expense: Expense, budgets: [BudgetForDay]?) {
        if  let budgets = budgets {
            
            let _budgets    = budgets.filter({$0.day >= expense.datePurchased})
            let budget      = budgets.first(where: {Date.areSameDay(date1: $0.day, date2: expense.datePurchased)})
            budget?.expenses.append(expense)
            
            let expensePriceInCurrency = expense.currency.convert(toCurrency: Currency(isoCode: budget?.currency ?? NSLocale.current.currencyCode!),
                                                                  amount: expense.price)
            for b in _budgets {
                b.totalUsableAmount -= expensePriceInCurrency ?? expense.price
            }
            
        }
    }
    
    static func removeExpense(expense: Expense, budgets: [BudgetForDay]?) {
        if  let budgets = budgets {
            
            let _budgets    = budgets.filter({$0.day >= expense.datePurchased})
            let budget      = budgets.first(where: {Date.areSameDay(date1: $0.day, date2: expense.datePurchased)})
            if let index    = budget?.expenses.firstIndex(of: expense) {
                budget?.expenses.remove(at: index)
            }
            
            let expensePriceInCurrency = expense.currency.convert(toCurrency: Currency(isoCode: budget?.currency ?? NSLocale.current.currencyCode!),
                                                                  amount: expense.price)
            for b in _budgets {
                b.totalUsableAmount += expensePriceInCurrency ?? expense.price
            }
            
        }
    }
    
    static func saveBudgetsToDefaults(budgets: [BudgetForDay]) {
        let budgetData = NSKeyedArchiver.archivedData(withRootObject: budgets)
        
        defaults.set(budgetData, forKey: budgetForThisMonthKey)
    }
    
    
    
    static func getBudgetsFromDefaults() throws -> [BudgetForDay] {
        let error: NSError = NSError(domain: NSErrorDomain.init(string: "Unable to get settings from UserDefaults.") as String, code: -1, userInfo: nil)
        
        guard   let budgetData = defaults.value(forKey: budgetForThisMonthKey) as? Data,
                let budgets = NSKeyedUnarchiver.unarchiveObject(with: budgetData) as? [BudgetForDay] else { throw error }
        
        return budgets
    }
    
    static func addExpensesToMatchingBudget(expenseList: [Expense], budgets: [BudgetForDay]?) {
        if let budgets = budgets {
            for b in budgets {
                let eList = expenseList.filter({Date.areSameDay(date1: $0.datePurchased, date2: b.day)})
                
                for expense in eList {
                    updateTotalUsableAmount(expense: expense, budgets: budgets)
                }
            }
        }
    }
    
    static func removeExpensesFromMatchingBudget(expenseList: [Expense], budgets: [BudgetForDay]?) {
        if let budgets = budgets {
            for b in budgets {
                let eList = expenseList.filter({Date.areSameDay(date1: $0.datePurchased, date2: b.day)})
                
                for expense in eList {
                    removeExpense(expense: expense, budgets: budgets)
                }
            }
        }
    }
    
    ///Returns an array of budgets given the settings the user has input.
    ///
    ///Only call this at the beginning of the recording period.
    ///You can call this multiple times throughout the period, but it's cleaner to only call it once.
    static func generateBudgets(given settings: Settings) -> [BudgetForDay] {
        
        var budgets = [BudgetForDay]()
        
        var calendar        = Calendar(identifier: .gregorian)
        calendar.timeZone   = TimeZone(abbreviation: "UTC")!
        
        if  let initialDate = settings.paymentDate,
            let finalDate   = settings.mustLastUntil {
            
            let initialDate = calendar.startOfDay(for: initialDate)
            let finalDate   = calendar.startOfDay(for: finalDate)
            
            let numberOfDays        = calendar.dateComponents([.day], from: initialDate, to: finalDate).day ?? 1
            
            let dailyUseableAmount  = (settings.incomeAmount-settings.savingsTarget)/Double(numberOfDays)
            
            var expenseList = [Expense]()
            settings.recurringExpenses.forEach { (e) in
                let eList = e.createExpensesFor(settings: settings)
                expenseList.append(contentsOf: eList)
            }
            
            for i in 0...numberOfDays {
                let date = initialDate + TimeInterval(i * 86400)
                let b = BudgetForDay(totalUsableAmount: dailyUseableAmount * Double(i), currency: settings.incomeCurrency, day: date, expenses: nil)
                
                budgets.append(b)
            }
            
            addExpensesToMatchingBudget(expenseList: expenseList, budgets: budgets)
            
        }
        for b in budgets {
            print(b.totalUsableAmount)
        }
        return budgets
        
    }
    
    
    static func getBudgetForDate(date: Date) -> BudgetForDay? {
        
        let budgets = try? getBudgetsFromDefaults()
        
        let budget = budgets?.filter({Date.areSameDay(date1: $0.day, date2: date)})
        
        return budget?.first
    }
    
    
    ///Change budget when the calendar day changes.
    ///
    ///Call this when the calendar day changes. I.e: Add a property observer to know when the calendar day changes.
    static func newDayExport(settings: Settings) -> [BudgetForDay] {
        
        var calendar        = Calendar(identifier: .gregorian)
        calendar.timeZone   = TimeZone(abbreviation: "UTC")!
        
        var budgets = (try? getBudgetsFromDefaults()) ?? generateBudgets(given: settings)
        
        if  let initialDate = settings.paymentDate,
            let finalDate   = settings.mustLastUntil {
            
            if finalDate < Date() {
                //TODO: export here!
                if settings.recurringPayment {
                    let numberOfDays        = calendar.dateComponents([.day], from: initialDate, to: finalDate).day ?? 1
                    settings.paymentDate    = finalDate.addingTimeInterval(86400) //Day right after the last day
                    settings.mustLastUntil  = calendar.date(byAdding: .day, value: numberOfDays, to: settings.paymentDate!)
                    budgets = generateBudgets(given: settings)
                }
            }
            
        }
        
        if budgets.count != 0 {
            saveBudgetsToDefaults(budgets: budgets)
        }
        return budgets
    }
    
    
    static func settingsDidChange(budgets: [BudgetForDay]?, settings: Settings) -> [BudgetForDay] {
        
        var calendar        = Calendar(identifier: .gregorian)
        calendar.timeZone   = TimeZone(abbreviation: "UTC")!
        
        if  var budgets = budgets,
            let initialDate = settings.paymentDate,
            let finalDate   = settings.mustLastUntil {
            
            var allTheExpenses = [Expense]()
            budgets.forEach { (b) in
                allTheExpenses.append(contentsOf: b.expenses)
            }
            
            let initialDate = calendar.startOfDay(for: initialDate)
            let finalDate   = calendar.startOfDay(for: finalDate)
            
            let numberOfDays        = calendar.dateComponents([.day], from: initialDate, to: finalDate).day ?? 1
            
            if budgets.count == numberOfDays {
                let dailyUseableAmount = (settings.incomeAmount - settings.savingsTarget)/((budgets.count > 0) ? Double(budgets.count) : 1.0)
                
                
                for (index, b) in budgets.enumerated() {
                    b.totalUsableAmount = dailyUseableAmount * Double(index)
                }
            } else {
                budgets = []
                let dailyUseableAmount = (settings.incomeAmount-settings.savingsTarget)/Double(numberOfDays)
                
                for i in 0...numberOfDays {
                    let date = initialDate + TimeInterval(i * 86400)
                    let b = BudgetForDay(totalUsableAmount: dailyUseableAmount * Double(i), currency: settings.incomeCurrency, day: date, expenses: nil)
                    budgets.append(b)
                }
            }
            
            addExpensesToMatchingBudget(expenseList: allTheExpenses, budgets: budgets)
            if budgets.count != 0 {
                saveBudgetsToDefaults(budgets: budgets)
            }
            return budgets
        }
        return []
    }
}
