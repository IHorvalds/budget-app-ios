//
//  BudgetCalculatingFunctions.swift
//  Budget
//
//  Created by Tudor Croitoru on 05.08.2018.
//  Copyright © 2018 Tudor Croitoru. All rights reserved.
//

import Foundation

extension Date {
    static func areSameDay(date1: Date, date2: Date) -> Bool {
        let comparison = Calendar.autoupdatingCurrent.compare(date1, to: date2, toGranularity: .day)
        
        if comparison == .orderedSame {
            return true
        }
        
        return false
    }
}

func isWithinBudget() -> String {
    
    let today = Date()
    
    if  let budgetData = defaults.value(forKey: budgetForThisMonthKey) as? Data,
        let budgets = NSKeyedUnarchiver.unarchiveObject(with: budgetData) as? [BudgetForDay],
        let budget = budgets.first(where: {Date.areSameDay(date1: $0.day, date2: today)}) {
        print("set shit up")
        if budget.totalUsableAmount > 0 {
            return "In Budget"
        } else {
            return "Over Budget"
        }
    }
    return "Budget"
}

//MARK: - What doesn't get spent in a day will be added to the next day's budget. The rest of the days until the end of the period will have the same budget. Savings at the end of the last day of the period will be added as monthly savings and exported as such
func calculateDailyBudget(startingFrom: Date, endingOn: Date) {
    
    var BudgetsForThisMonth = [BudgetForDay]()
    
    
    //calculate the number of days
    let calendar = Calendar.autoupdatingCurrent
    let numberOfDays = calendar.dateComponents([Calendar.Component.day], from: startingFrom, to: endingOn)
    
    if let curr = defaults.value(forKey: sentCurrencyKey) as? String,
        let curr2 = defaults.value(forKey: localCurrencyKey) as? String,
        let totalAmount = defaults.value(forKey: budgetKey) as? String,
        let rentAmount = defaults.value(forKey: rentAmountKey) as? String {
        let initialCurr = Currency.init(isoCode: curr)
        let localCurr = Currency.init(isoCode: curr2)
        if let quantity = initialCurr.convert(toCurrency: localCurr, amount: Double(totalAmount)!) {
            let quantityAfterRent = quantity - Double(rentAmount)!
            let dailyAverageTotal = quantityAfterRent/Double(numberOfDays.day! + 1)
            
            //populate the budgetsformonth array with budgets
            for i in 0...(numberOfDays.day!) {
                let budget = BudgetForDay.init(totalUsableAmount: dailyAverageTotal, day: (startingFrom + TimeInterval(i * 86400)))
                BudgetsForThisMonth.append(budget)
            }
            
            //save it to UserDefaults
            defaults.set(archiveBudgetsAsData(budgets: BudgetsForThisMonth), forKey: budgetForThisMonthKey)
        }
    }
}


func endOfDayExport() {
    //If there is a day in the recording period after today, then add to the total of tomorrow what's left from today. It can be a negative amount
    
    let today = Date()
    var savePath: URL?
    
    if let budgetData = defaults.value(forKey: budgetForThisMonthKey) as? Data {
        if var budgets = NSKeyedUnarchiver.unarchiveObject(with: budgetData) as? [BudgetForDay] {
            
            if let lastBudgetDay = budgets.last?.day {
                if lastBudgetDay.compare(today) == .orderedAscending && !Date.areSameDay(date1: lastBudgetDay, date2: today) {
                    //MARK: - export everything as JSON
                    var exportDataDocument: BudgetExportDocument?
                    
                    if  let dateReceived = defaults.value(forKey: dateReceivedKey) as? String,
                        let lastDay = defaults.value(forKey: lastsUntilKey) as? String,
                        let totalSend = defaults.value(forKey: budgetKey) as? String,
                        let rentAmount = defaults.value(forKey: rentAmountKey) as? String,
                        let localCurr = defaults.value(forKey: localCurrencyKey) as? String,
                        let sentCurr = defaults.value(forKey: sentCurrencyKey) as? String {
                        
                        
                        print("In the saving thing")
                        let localCurrency = Currency.init(isoCode: localCurr)
                        let sentCurrency = Currency.init(isoCode: sentCurr)
                        let totalInLocalCurrency = sentCurrency.convert(toCurrency: localCurrency,
                                                                        amount: Double(totalSend)!)
                        var totalSpent = 0.0
                        var expenses: [Expense]?
                        if let expenseData = defaults.value(forKey: expensesKey) as? Data {
                            expenses = NSKeyedUnarchiver.unarchiveObject(with: expenseData) as? [Expense]
                            expenses?.forEach({ totalSpent += $0.price })
                        }
                        
                        let amountRemaining = totalInLocalCurrency! - Double(rentAmount)! - totalSpent
                        
                        //Gotta get the month from texts
                        dateFormatter.dateStyle = .medium
                        let calendar = Calendar.autoupdatingCurrent
                        let initialMonth = dateFormatter.date(from: dateReceived)!
                        let finalMonth = dateFormatter.date(from: lastDay)!
                        
                        let initialMonthNumber = calendar.component(.month, from: initialMonth)
                        let finalMonthNumber = calendar.component(.month, from: finalMonth)
                        let initMonth = calendar.monthSymbols[initialMonthNumber - 1]
                        let finMonth = calendar.monthSymbols[finalMonthNumber - 1]
                        
                        savePath = try? FileManager.default.url(for: .documentDirectory,
                                                                in: .userDomainMask,
                                                                appropriateFor: nil,
                                                                create: true).appendingPathComponent(initMonth + "-" + finMonth + ".bdg")
                        if savePath != nil {
                            //for debugging purposes
                            //print("----------------------------------------------")
                            exportDataDocument = BudgetExportDocument(fileURL: savePath!)
                            exportDataDocument?.budgetExport = BudgetExportData.init(expenses: expenses,
                                                                                     dateReceived: dateReceived,
                                                                                     lastDay: lastDay,
                                                                                     totalSent: totalInLocalCurrency!,
                                                                                     rentAmount: Double(rentAmount)!,
                                                                                     amountSpent: totalSpent,
                                                                                     amountRemaining: amountRemaining,
                                                                                     sentCurrency: sentCurr,
                                                                                     localCurrency: localCurr)
                            if !FileManager.default.fileExists(atPath: (savePath?.path)!) {
                                exportDataDocument?.save(to: savePath!,
                                                         for: .forCreating,
                                                         completionHandler: nil)
                            }
                            
                        }
                        
                        
                        //After json export, reset all settings.
                        budgets = []
                        defaults.set(nil, forKey: budgetForThisMonthKey)
                        defaults.set(nil, forKey: dateReceivedKey)
                        defaults.set(nil, forKey: lastsUntilKey)
                        defaults.set(nil, forKey: sentCurrencyKey)
                        defaults.set(nil, forKey: localCurrencyKey)
                        defaults.set(nil, forKey: budgetKey)
                        defaults.set(nil, forKey: rentAmountKey)
                        defaults.set(nil, forKey: expensesKey)
                        //for debugging purposes
//                        print("date Received !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
//                        print(defaults.value(forKey: dateReceivedKey))
//                        print("Just reset everything")
                    }
                } else {
                    if let x = budgets.index(where: {Date.areSameDay(date1: $0.day, date2: today)}) {
                        if x != 0 {
                            for a in 0...(x - 1) {
                                if budgets[a].checked != true {
                                    budgets[x].totalUsableAmount += budgets[a].totalUsableAmount
                                    budgets[a].checked = true
                                }
                            }
                        }
                        defaults.set(archiveBudgetsAsData(budgets: budgets), forKey: budgetForThisMonthKey)
                    } else {
                        print("You're before the recording period")
                    }
                    
                }
                
            }
            
            //for debugging purposes
//            for budget in budgets {
//                print("New Budget")
//                print("Total for this budget: \(budget.totalUsableAmount)")
//                print("Budget for day: \(budget.day)")
//                print("Budget was checked: \(budget.checked)")
//            }
        }
    }
}

func archiveBudgetsAsData(budgets: [BudgetForDay]) -> Data {
    let archivedBudgets = NSKeyedArchiver.archivedData(withRootObject: budgets)
    return archivedBudgets
}
