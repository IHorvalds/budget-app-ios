//
//  Keys.swift
//  Budget
//
//  Created by Tudor Croitoru on 09.08.2018.
//  Copyright © 2018 Tudor Croitoru. All rights reserved.
//

import Foundation

let userDefaults = UserDefaults.init(suiteName: "horvalds.budget.app")
let defaults = UserDefaults(suiteName: "horvalds.budget.app")


//MARK: - UserDefaults keys
let dateReceivedKey = "dateReceived"
let lastsUntilKey = "lastsUntil"
let notificationsAccessKey = "notificationAccess"
let rentDueDateKey = "rentDueDate"
let budgetKey = "moneyReceived"
let rentAmountKey = "rentAmount"
let sentCurrencyKey = "sentCurrency"
let localCurrencyKey = "localCurrency"
let budgetForThisMonthKey = "budgetForThisMonth"
let expensesKey = "expensesThisMonth"
