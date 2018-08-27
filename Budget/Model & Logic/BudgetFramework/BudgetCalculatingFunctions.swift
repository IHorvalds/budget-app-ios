//
//  BudgetCalculatingFunctions.swift
//  Budget
//
//  Created by Tudor Croitoru on 05.08.2018.
//  Copyright © 2018 Tudor Croitoru. All rights reserved.
//

import Foundation

let today = Date()
let day = Calendar.current.dateComponents([.year, .month, .day], from: today)
let dayOfToday = Calendar.current.date(from: day)

func isWithinBudget() -> String {
    
    let calendar = Calendar.current
    let today = Date()
    let dateComponents = calendar.dateComponents([.year, .month, .day], from: today)
    let dayOfToday = calendar.date(from: dateComponents)!
    
    if  let budgetData = defaults.value(forKey: budgetForThisMonthKey) as? Data,
        let budgets = NSKeyedUnarchiver.unarchiveObject(with: budgetData) as? [BudgetForDay],
        let budget = budgets.first(where: {$0.day == dayOfToday}) {
        print("set shit up")
        if budget.totalUsableAmount > 0 {
            return "In Budget"
        } else {
            return "Over Budget"
        }
    }
    return "Budget ???"
}

//MARK: - What doesn't get spent in a day will be added to the next day's budget. The rest of the days until the end of the period will have the same budget. Savings at the end of the last day of the period will be added as monthly savings and exported as such
func calculateDailyBudget(startingFrom: Date, endingOn: Date) {
    
    var BudgetsForThisMonth = [BudgetForDay]()
    

    //calculate the number of days
    let calendar = Calendar.current
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
    
    
    if let budgetData = defaults.value(forKey: budgetForThisMonthKey) as? Data {
        if let budgets = NSKeyedUnarchiver.unarchiveObject(with: budgetData) as? [BudgetForDay] {
            
            if let lastBudgetDay = budgets.last?.day {
                if dayOfToday! > lastBudgetDay {
                    //TODO: - export everything as JSON
                    
                    //After json export, reset all settings.
                    //MARK: - Uncomment when ready to finish up
//                    defaults.set(nil, forKey: budgetForThisMonthKey)
//                    defaults.set(nil, forKey: dateReceivedKey)
//                    defaults.set(nil, forKey: lastsUntilKey)
//                    defaults.set(nil, forKey: sentCurrencyKey)
//                    defaults.set(nil, forKey: localCurrencyKey)
//                    defaults.set(nil, forKey: budgetKey)
//                    defaults.set(nil, forKey: rentAmountKey)
//                    defaults.set(nil, forKey: rentDueDateKey)
                } else {
                    let x = budgets.index(where: {$0.day == dayOfToday!})
                    for a in 0...(x! - 1) {
                        if budgets[a].checked != true {
                            budgets[x!].totalUsableAmount += budgets[a].totalUsableAmount
                            budgets[a].checked = true
                        }
                    }
                }
                defaults.set(archiveBudgetsAsData(budgets: budgets), forKey: budgetForThisMonthKey)
            }

            
            for budget in budgets {
                print("New Budget")
                print("Total for this budget: \(budget.totalUsableAmount)")
                print("Budget for day: \(budget.day)")
                print("Budget was checked: \(budget.checked)")
            }
        }
    }
    
}

func archiveBudgetsAsData(budgets: [BudgetForDay]) -> Data {
    let archivedBudgets = NSKeyedArchiver.archivedData(withRootObject: budgets)
    return archivedBudgets
}
