//
//  BudgetForDay.swift
//  Budget
//
//  Created by Tudor Croitoru on 09.08.2018.
//  Copyright © 2018 Tudor Croitoru. All rights reserved.
//

import Foundation
import UserNotifications

class BudgetForDay: NSObject, NSCoding, Codable {
    
    var totalUsableAmount: Double
    let day: Date
    var currency: String
    var expenses: [Expense]
    
    
    
    init(totalUsableAmount: Double, currency: String?, day: Date, expenses: [Expense]?) {
        self.totalUsableAmount  = totalUsableAmount
        self.day                = day //NOTE: All instances of this class will be created when the recording period begins and they will be updated as time progresses in the period
        self.expenses           = expenses ?? []
        self.currency           = currency ?? ""
    }
    
    
    
    required init(coder aDecoder: NSCoder) {
        totalUsableAmount   = aDecoder.decodeDouble(forKey: "totalUsableAmountKey")
        day                 = aDecoder.decodeObject(forKey: "dayKey") as! Date
        expenses            = aDecoder.decodeObject(forKey: "expensesKey") as! [Expense]
        currency            = aDecoder.decodeObject(forKey: "currencyKey") as! String
    }
    
    
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(totalUsableAmount,    forKey: "totalUsableAmountKey")
        aCoder.encode(day,                  forKey: "dayKey")
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
            
            let _budgets    = budgets.filter({($0.day >= expense.datePurchased) || (Date.areSameDay(date1: $0.day, date2: expense.datePurchased))})
            let budget      = budgets.first(where: {Date.areSameDay(date1: $0.day, date2: expense.datePurchased)})
            
            let expensePriceInCurrency = expense.currency.convert(toCurrency: Currency(isoCode: budget?.currency ?? NSLocale.current.currencyCode!),
                                                                  amount: expense.price)
            let e = Expense(title: expense.title,
                            price: expensePriceInCurrency ?? 0.0,
                            currency: budgets.first?.currency ?? NSLocale.current.currencyCode!,
                            datePurchased: expense.datePurchased)
            
            budget?.expenses.append(e)
            
            
            for b in _budgets {
                b.totalUsableAmount -= expensePriceInCurrency ?? e.price
            }
            
            saveBudgetsToDefaults(budgets: budgets)
        }
    }
    
    static func removeExpense(expense: Expense, budgets: [BudgetForDay]?) {
        if  let budgets = budgets {
            let _budgets    = budgets.filter({($0.day >= expense.datePurchased) || (Date.areSameDay(date1: $0.day, date2: expense.datePurchased))})
            
//            let budget      = budgets.first(where: {$0.expenses.contains(expense)}) //this fails because of calendar mismatching
            let budget      = budgets.first { (b) -> Bool in
                var found = false
                b.expenses.forEach({ (e) in
                    if e == expense {
                        found = true
                    }
                })

                return found
            }
            if  let budget  = budget,
                let index   = budget.expenses.firstIndex(where: {$0 == expense}) {
                budget.expenses.remove(at: index)
            }
            
            let expensePriceInCurrency = expense.currency.convert(toCurrency: Currency(isoCode: budget?.currency ?? NSLocale.current.currencyCode!),
                                                                  amount: expense.price)
            for b in _budgets {
                b.totalUsableAmount += expensePriceInCurrency ?? expense.price
            }
            
            saveBudgetsToDefaults(budgets: budgets)
            
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
        let notificationCenter = UNUserNotificationCenter.current()
        
        if let budgets = budgets {
            for b in budgets {
                let eList = expenseList.filter({Date.areSameDay(date1: $0.datePurchased, date2: b.day)})
                
                var uuids: [String] = []
                for expense in eList {
                    uuids.append(expense.notificationUuid)
                    removeExpense(expense: expense, budgets: budgets)
                }
                
                notificationCenter.removePendingNotificationRequests(withIdentifiers: uuids)
            }
        }
    }
    
    ///Returns an array of budgets given the settings the user has input.
    ///
    ///Only call this at the beginning of the recording period.
    ///You can call this multiple times throughout the period, but it's cleaner to only call it once.
    static func generateBudgets(given settings: Settings) -> [BudgetForDay] {
        
        var budgets = [BudgetForDay]()
        
//        var calendar        = Calendar(identifier: .gregorian)
//        calendar.timeZone   = TimeZone(abbreviation: "UTC")!

        let calendar        = NSLocale.autoupdatingCurrent.calendar
        
        if  let initialDate = settings.paymentDate,
            let finalDate   = settings.mustLastUntil {
            
            let initialDate = calendar.startOfDay(for: initialDate)
            let finalDate   = calendar.startOfDay(for: finalDate)
            
            let numberOfDays        = (calendar.dateComponents([.day], from: initialDate, to: finalDate).day ?? 0) + 1 //+ 1 to accommodate for the first day
            
            let dailyUseableAmount  = (settings.incomeAmount-settings.savingsTarget)/Double(numberOfDays)
            
            var expenseList = [Expense]()
            settings.recurringExpenses.forEach { (e) in
                let eList = e.createExpensesFor(settings: settings)
                expenseList.append(contentsOf: eList)
            }
            
            for i in 0..<numberOfDays {
                let date = initialDate + TimeInterval(i * 86400)
                let b = BudgetForDay(totalUsableAmount: dailyUseableAmount * Double(i+1), currency: settings.incomeCurrency, day: date, expenses: nil)
                
                budgets.append(b)
            }
            
            addExpensesToMatchingBudget(expenseList: expenseList, budgets: budgets)
            
        }
//        for b in budgets {
//            print(b.totalUsableAmount, b.day.description(with: .current))
//        }
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
    static func newDayExport(settings: inout Settings) -> [BudgetForDay] {
        
//        var calendar        = Calendar(identifier: .gregorian)
//        calendar.timeZone   = TimeZone(abbreviation: "UTC")!

        let calendar = NSLocale.autoupdatingCurrent.calendar
        
        var budgets = (try? getBudgetsFromDefaults()) ?? generateBudgets(given: settings)
        
        if  let initialDate = settings.paymentDate,
            let finalDate   = settings.mustLastUntil {
            
            let today = Date()
            
            print(initialDate.description(with: .current), finalDate.description(with: .current))// Ah HA!
            
            if finalDate.compare(today) == .orderedAscending && !Date.areSameDay(date1: today, date2: finalDate) {
                //TODO: export here!
                let exportData = BudgetExportData(budgets: budgets, settings: settings)
                do {
                    try exportData.exportCurrentPeriod()
                } catch let error {
                    print(error)
                }
                
                
                if settings.recurringPayment {
                    let numberOfDays        = calendar.dateComponents([.day], from: initialDate, to: finalDate).day ?? 1
                    settings.paymentDate    = finalDate.addingTimeInterval(86400) //Day right after the last day
                    settings.mustLastUntil  = calendar.date(byAdding: .day, value: numberOfDays, to: settings.paymentDate!)
                    budgets = generateBudgets(given: settings)
                    
                } else {
                    settings = Settings.standardSettings
                }
                
                settings.saveSettingsToDefaults() //To actually save the settings when I update them. D'oh.....
            }
            
        }
        
        if budgets.count != 0 {
            saveBudgetsToDefaults(budgets: budgets)
        }
        return budgets
    }
    
    
    static func settingsDidChange(budgets: [BudgetForDay]?, settings: Settings) -> [BudgetForDay] {
        
        let calendar    = NSLocale.autoupdatingCurrent.calendar
        
        if  var budgets = budgets,
            let initialDate = settings.paymentDate,
            let finalDate   = settings.mustLastUntil {
            
            var allTheExpenses = [Expense]()
            budgets.forEach { (b) in
                allTheExpenses.append(contentsOf: b.expenses)
            }
            
            let initialDate = calendar.startOfDay(for: initialDate)
            let finalDate   = calendar.startOfDay(for: finalDate)
            
            let numberOfDays        = (calendar.dateComponents([.day], from: initialDate, to: finalDate).day ?? 0) + 1 //+ 1 to accommodate for the first day
            
            budgets = []
            let dailyUseableAmount = (settings.incomeAmount - settings.savingsTarget)/Double(numberOfDays)
            
            for i in 0..<numberOfDays {
                let date = initialDate + TimeInterval(i * 86400)
                let b = BudgetForDay(totalUsableAmount: dailyUseableAmount * Double(i+1), currency: settings.incomeCurrency, day: date, expenses: nil)
                budgets.append(b)
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
